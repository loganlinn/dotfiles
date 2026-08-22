# /// script
# requires-python = ">=3.12"
# dependencies = ["boto3>=1.34", "click>=8.1", "pydantic>=2.7", "rich>=13.7"]
# ///
"""Tests for bin/aws-org. Run: uv run test/test_aws_org.py"""

from __future__ import annotations

import contextlib
import importlib.machinery
import importlib.util
import io
import json
import sys
import tempfile
import unittest
from datetime import datetime, timezone
from pathlib import Path
from unittest import mock

from click.testing import CliRunner
from rich.console import Console

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "bin" / "aws-org"


def load_cli():
    loader = importlib.machinery.SourceFileLoader("aws_org_cli", str(SCRIPT))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    if spec is None:
        raise RuntimeError("Could not load aws-org")
    module = importlib.util.module_from_spec(spec)
    sys.modules[loader.name] = module
    loader.exec_module(module)
    return module


CLI = load_cli()
START_URL = "https://example.awsapps.com/start"


def ou(id: str, name: str, parent_id: str | None, path: str) -> object:
    return CLI.OrgUnit(id=id, name=name, parent_id=parent_id, path=path)


def account(id: str, name: str, ou_id: str | None, status: str | None = None) -> object:
    return CLI.Account(id=id, name=name, email=f"{name}@example.com", ou_id=ou_id, status=status)


def role(account_id: str, name: str) -> object:
    return CLI.RoleAssignment(account_id=account_id, role_name=name)


def org_data(
    *, ous: list, accounts: list, roles: list = (), management_account_id: str | None = None
) -> object:
    roles = list(roles)
    return CLI.OrgData(
        generated_at=datetime.now(timezone.utc),
        start_url=START_URL,
        region="us-east-1",
        accounts=accounts,
        ous=ous,
        roles=roles,
        assignments_hash=CLI.hash_assignments(roles),
        management_account_id=management_account_id,
    )


def sample_org() -> object:
    """Landing zone: `shared` and `sandbox-1` have no permission set; `Empty` OU has no accounts."""
    return org_data(
        ous=[
            ou("r-abcd", "Root", None, "Root"),
            ou("ou-abcd-emp", "Empty", "r-abcd", "Root/Empty"),
            ou("ou-abcd-inf", "Infrastructure", "r-abcd", "Root/Infrastructure"),
            ou("ou-abcd-sbx", "Sandbox", "r-abcd", "Root/Sandbox"),
            ou("ou-abcd-sec", "Security", "r-abcd", "Root/Security"),
            ou("ou-abcd-wl", "Workloads", "r-abcd", "Root/Workloads"),
            ou("ou-abcd-prod", "Prod", "ou-abcd-wl", "Root/Workloads/Prod"),
        ],
        accounts=[
            account("222222222222", "audit", "r-abcd", "ACTIVE"),
            account("111111111111", "management", "r-abcd", "ACTIVE"),
            account("333333333333", "log-archive", "ou-abcd-sec", "ACTIVE"),
            account("444444444444", "security-tooling", "ou-abcd-sec", "ACTIVE"),
            account("555555555555", "network", "ou-abcd-inf", "ACTIVE"),
            account("666666666666", "app-a-prod", "ou-abcd-prod", "ACTIVE"),
            account("777777777777", "shared", "ou-abcd-wl", "ACTIVE"),
            account("888888888888", "orphan", None),
            account("999999999999", "sandbox-1", "ou-abcd-sbx", "SUSPENDED"),
        ],
        roles=[
            role("111111111111", "AdministratorAccess"),
            role("222222222222", "AdministratorAccess"),
            *(
                role(id, "ReadOnlyAccess")
                for id in (
                    "111111111111", "222222222222", "333333333333", "444444444444",
                    "555555555555", "666666666666", "888888888888",
                )
            ),
        ],
        management_account_id="111111111111",
    )


def render(trees: list) -> str:
    console = Console(file=io.StringIO(), width=120, force_terminal=False, color_system=None)
    for tree in trees:
        console.print(tree)
    return strip_lines(console.file.getvalue())


def strip_lines(text: str) -> str:
    return "\n".join(line.rstrip() for line in text.splitlines())


EXPECTED_DEFAULT = """\
Root (r-abcd)
├── management (111111111111)
├── audit (222222222222)
├── orphan (888888888888)
│
├── Infrastructure (ou-abcd-inf)
│   └── network (555555555555)
│
├── Security (ou-abcd-sec)
│   ├── log-archive (333333333333)
│   └── security-tooling (444444444444)
│
└── Workloads (ou-abcd-wl)
    └── Prod (ou-abcd-prod)
        └── app-a-prod (666666666666)"""

EXPECTED_ALL = """\
Root (r-abcd)
├── management (111111111111)
├── audit (222222222222)
├── orphan (888888888888)
│
├── Empty (ou-abcd-emp)
│
├── Infrastructure (ou-abcd-inf)
│   └── network (555555555555)
│
├── Sandbox (ou-abcd-sbx)
│   └── sandbox-1 (999999999999)
│
├── Security (ou-abcd-sec)
│   ├── log-archive (333333333333)
│   └── security-tooling (444444444444)
│
└── Workloads (ou-abcd-wl)
    ├── shared (777777777777)
    └── Prod (ou-abcd-prod)
        └── app-a-prod (666666666666)"""


class ViewTests(unittest.TestCase):
    def test_default_hides_unassigned_accounts_and_their_ous(self) -> None:
        view = sample_org().view()
        self.assertNotIn("shared", [a.name for a in view.accounts])
        self.assertNotIn("sandbox-1", [a.name for a in view.accounts])
        self.assertEqual(
            [o.name for o in view.ous], ["Root", "Infrastructure", "Security", "Workloads", "Prod"]
        )

    def test_all_returns_everything(self) -> None:
        data = sample_org()
        self.assertIs(data.view(include_all=True), data)

    def test_roots_always_kept(self) -> None:
        data = org_data(ous=[ou("r-abcd", "Root", None, "Root")], accounts=[account("1", "a", "r-abcd")])
        self.assertEqual([o.id for o in data.view().ous], ["r-abcd"])
        self.assertEqual(data.view().accounts, [])


class MergeAccountsTests(unittest.TestCase):
    def test_sso_accounts_gain_org_data_and_org_only_accounts_are_added(self) -> None:
        sso = [
            {"accountId": "2", "accountName": "beta", "emailAddress": "b@example.com"},
            {"accountId": "1", "accountName": "alpha", "emailAddress": "a@example.com"},
        ]
        org = [
            account("1", "alpha", "ou-x", "ACTIVE"),
            account("3", "gamma", "ou-y", "SUSPENDED"),
        ]
        merged = CLI.merge_accounts(sso, org)
        self.assertEqual([a.id for a in merged], ["1", "2", "3"])
        alpha, beta, gamma = merged
        self.assertEqual((alpha.ou_id, alpha.status, alpha.email), ("ou-x", "ACTIVE", "a@example.com"))
        self.assertEqual((beta.ou_id, beta.status), (None, None))
        self.assertEqual((gamma.name, gamma.ou_id, gamma.status), ("gamma", "ou-y", "SUSPENDED"))

    def test_without_org_data(self) -> None:
        sso = [{"accountId": "1", "accountName": "alpha"}]
        self.assertEqual([a.id for a in CLI.merge_accounts(sso, [])], ["1"])


class BuildTreesTests(unittest.TestCase):
    def test_layout(self) -> None:
        self.assertEqual(render(CLI.build_trees(sample_org())), EXPECTED_ALL)
        self.assertEqual(render(CLI.build_trees(sample_org().view())), EXPECTED_DEFAULT)

    def test_styles(self) -> None:
        (tree,) = CLI.build_trees(sample_org())
        management, audit, *_, workloads = tree.children

        def styles(node) -> list[tuple[str, str]]:
            return [(node.label.plain[sp.start : sp.end], sp.style) for sp in node.label.spans]

        styled_id = CLI.TREE_STYLES["id"]
        self.assertEqual(styles(tree), [("Root", CLI.TREE_STYLES["root"]), (" (r-abcd)", styled_id)])
        self.assertEqual(
            styles(management),
            [("management", CLI.TREE_STYLES["management"]), (" (111111111111)", styled_id)],
        )
        self.assertEqual(styles(audit)[0], ("audit", CLI.TREE_STYLES["account"]))
        self.assertEqual(styles(workloads)[0], ("Workloads", CLI.TREE_STYLES["ou"]))

    def test_no_management_account_keeps_alphabetical_order(self) -> None:
        data = sample_org()
        data.management_account_id = None
        (tree,) = CLI.build_trees(data)
        self.assertEqual(
            [c.label.plain for c in tree.children[:2]],
            ["audit (222222222222)", "management (111111111111)"],
        )
        self.assertTrue(
            all(c.label.spans[0].style == CLI.TREE_STYLES["account"] for c in tree.children[:3])
        )

    def test_accounts_only_at_root_get_no_spacing(self) -> None:
        data = org_data(
            ous=[ou("r-abcd", "Root", None, "Root")],
            accounts=[account("1", "a", "r-abcd"), account("2", "b", "r-abcd")],
        )
        self.assertEqual(render(CLI.build_trees(data)), "Root (r-abcd)\n├── a (1)\n└── b (2)")

    def test_no_roots(self) -> None:
        data = org_data(ous=[], accounts=[account("1", "a", None)])
        self.assertEqual(CLI.build_trees(data), [])


class CommandTestBase(unittest.TestCase):
    """Temp config + cache dir; no test methods of its own."""

    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        root = Path(self.tmp.name)
        self.cache_dir = root / "cache"
        self.config = root / "config.toml"
        self.config.write_text(
            f'[sso]\nstart_url = "{START_URL}"\nregion = "us-east-1"\n'
            f'[cache]\ndirectory = "{self.cache_dir}"\n'
        )

    def invoke(self, *args: str, data: object | None = None):
        CLI.CacheStore(self.cache_dir).write(data or sample_org())
        result = CliRunner().invoke(CLI.cli, ["-C", str(self.config), *args])
        return result

    def invoke_json(self, *args: str, data: object | None = None):
        result = self.invoke(*args, "-o", "json", data=data)
        self.assertEqual(result.exit_code, 0, result.output)
        return json.loads(result.output)


class CommandTests(CommandTestBase):
    def test_tree_default_and_all(self) -> None:
        result = self.invoke("tree")
        self.assertEqual(result.exit_code, 0, result.output)
        self.assertEqual(strip_lines(result.output), EXPECTED_DEFAULT)
        result = self.invoke("tree", "-a")
        self.assertEqual(result.exit_code, 0, result.output)
        self.assertEqual(strip_lines(result.output), EXPECTED_ALL)

    def test_tree_no_ou_data_exits_1(self) -> None:
        data = org_data(ous=[], accounts=[account("1", "a", None)], roles=[role("1", "X")])
        result = self.invoke("tree", data=data)
        self.assertEqual(result.exit_code, 1)
        self.assertIn("no OU data cached", result.output)

    def test_get_account_default_and_all(self) -> None:
        names = [r["name"] for r in self.invoke_json("get", "accounts", "-f", "name")]
        self.assertEqual(len(names), 7)
        self.assertNotIn("shared", names)
        rows = self.invoke_json("get", "account", "-a", "-f", "name,status,ou,roles")
        self.assertEqual(len(rows), 9)
        by_name = {r["name"]: r for r in rows}
        self.assertEqual(by_name["shared"], {"name": "shared", "status": "ACTIVE", "ou": "Root/Workloads", "roles": []})
        self.assertEqual(by_name["sandbox-1"]["status"], "SUSPENDED")
        self.assertEqual(by_name["audit"]["roles"], ["AdministratorAccess", "ReadOnlyAccess"])

    def test_get_ou_default_and_all(self) -> None:
        rows = self.invoke_json("get", "ou", "-f", "name,accounts")
        self.assertEqual(
            rows,
            [
                {"name": "Root", "accounts": 2},
                {"name": "Infrastructure", "accounts": 1},
                {"name": "Security", "accounts": 2},
                {"name": "Workloads", "accounts": 0},
                {"name": "Prod", "accounts": 1},
            ],
        )
        rows = {r["name"]: r["accounts"] for r in self.invoke_json("get", "ou", "-a", "-f", "name,accounts")}
        self.assertEqual(rows["Empty"], 0)
        self.assertEqual(rows["Sandbox"], 1)
        self.assertEqual(rows["Workloads"], 1)

    def test_get_permission_set_and_aliases(self) -> None:
        expected = [
            {"name": "AdministratorAccess", "accounts": 2},
            {"name": "ReadOnlyAccess", "accounts": 7},
        ]
        for noun in ("permission-set", "permission-sets", "pm"):
            self.assertEqual(self.invoke_json("get", noun), expected, noun)
        rows = self.invoke_json("get", "pm", "Admin*", "-f", "name,account_names,account_ids")
        self.assertEqual(
            rows,
            [
                {
                    "name": "AdministratorAccess",
                    "account_names": ["audit", "management"],
                    "account_ids": ["111111111111", "222222222222"],
                }
            ],
        )
        rows = self.invoke_json("get", "pm", "--account", "audit", "-f", "name")
        self.assertEqual([r["name"] for r in rows], ["AdministratorAccess", "ReadOnlyAccess"])

    def test_cache_info_counts_assigned_and_known(self) -> None:
        result = self.invoke("cache", "info")
        self.assertEqual(result.exit_code, 0, result.output)
        self.assertIn("7 assigned to you, 9 known", result.output)

    def test_old_schema_cache_is_invalid(self) -> None:
        self.cache_dir.mkdir(parents=True)
        raw = json.loads(sample_org().model_dump_json())
        raw["schema_version"] = 1
        (self.cache_dir / "org.json").write_text(json.dumps(raw))
        result = CliRunner().invoke(CLI.cli, ["-C", str(self.config), "cache", "info"])
        self.assertEqual(result.exit_code, CLI.EXIT_CACHE_INVALID)
        self.assertIn("schema version 1, expected 2", result.output)


class DisableCacheTests(CommandTestBase):
    """--disable-cache: AWS is the only source; disk is never read or written."""

    def setUp(self) -> None:
        super().setUp()
        self.live = org_data(
            ous=[ou("r-live", "Root", None, "Root")],
            accounts=[account("1", "live-account", "r-live")],
            roles=[role("1", "ReadOnlyAccess")],
        )
        patcher = mock.patch.object(CLI.AwsOrgSource, "load", return_value=self.live)
        self.aws_load = patcher.start()
        self.addCleanup(patcher.stop)

    def test_ignores_disk_cache_and_does_not_write_it(self) -> None:
        CLI.CacheStore(self.cache_dir).write(sample_org())
        before = (self.cache_dir / "org.json").read_bytes()
        result = CliRunner().invoke(CLI.cli, ["-C", str(self.config), "--disable-cache", "tree"])
        self.assertEqual(result.exit_code, 0, result.output)
        self.assertIn("live-account (1)", result.output)
        self.assertNotIn("management", result.output)
        self.assertEqual((self.cache_dir / "org.json").read_bytes(), before)
        self.aws_load.assert_called_once()

    def test_no_cache_file_is_created(self) -> None:
        result = CliRunner().invoke(CLI.cli, ["-C", str(self.config), "--disable-cache", "get", "account"])
        self.assertEqual(result.exit_code, 0, result.output)
        self.assertIn("cache disabled; loading from AWS", result.output)
        self.assertFalse(self.cache_dir.exists())

    def test_env_var_enables_flag(self) -> None:
        result = CliRunner().invoke(
            CLI.cli, ["-C", str(self.config), "get", "account"], env={"AWS_ORG_DISABLE_CACHE": "1"}
        )
        self.assertEqual(result.exit_code, 0, result.output)
        self.assertIn("live-account", result.output)
        self.assertFalse(self.cache_dir.exists())

    def test_in_memory_for_process_lifetime(self) -> None:
        app = CLI.App(self.config, disable_cache=True)
        with contextlib.redirect_stderr(io.StringIO()) as stderr:
            self.assertIs(app.org_data(), app.org_data())
        self.assertIn("cache disabled", stderr.getvalue())
        self.aws_load.assert_called_once()
        self.assertFalse(self.cache_dir.exists())

    def test_cache_commands_refuse(self) -> None:
        for args in (["cache", "info"], ["cache", "refresh"], ["cache", "clear"], ["cache", "check"]):
            result = CliRunner().invoke(CLI.cli, ["-C", str(self.config), "--disable-cache", *args])
            self.assertEqual(result.exit_code, 2, args)
            self.assertIn("unavailable with --disable-cache", result.output)
        self.aws_load.assert_not_called()


class MemoryOrgSourceTests(unittest.TestCase):
    def test_loads_once(self) -> None:
        inner = mock.Mock(spec=CLI.OrgSource)
        inner.load.return_value = sample_org()
        source = CLI.MemoryOrgSource(inner)
        self.assertIs(source.load(), source.load())
        inner.load.assert_called_once()


if __name__ == "__main__":
    unittest.main()
