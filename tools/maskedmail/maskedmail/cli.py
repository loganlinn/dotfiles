import logging

import click
import jmapc
import jmapc.logging
from jmapc.fastmail import (
    MaskedEmail,
    MaskedEmailGet,
    MaskedEmailGetResponse,
    MaskedEmailSet,
    MaskedEmailSetResponse,
    MaskedEmailState,
)
from jmapc.methods import CoreEcho, IdentityGet, IdentityGetResponse
from rich import inspect
from rich.console import Console
from rich.logging import RichHandler

logging.basicConfig(
    level="NOTSET",
    format="%(message)s",
    datefmt="[%X]",
    handlers=[RichHandler(rich_tracebacks=True)],
)


# Set jmapc log level to DEBUG
jmapc.logging.log.setLevel(logging.DEBUG)

console = Console()


@click.group()
@click.version_option()
@click.option("--host", envvar="JMAP_HOSTNAME", default="api.fastmail.com")
@click.option("--api-token", envvar="JMAP_API_TOKEN")
@click.pass_context
def cli(ctx, host, api_token):
    ctx.ensure_object(dict)
    ctx.obj["jmap_client"] = jmapc.Client.create_with_api_token(
        host=host,
        api_token=api_token,
    )


@cli.command(name="create")
@click.pass_obj
def create_cli(obj):
    jmap_client = obj["jmap_client"]
    inspect(jmap_client.requests_session)
    inspect(jmap_client.request(MaskedEmailGet()))
    # print(obj["jmap"].request(IdentityGet()))
    # print(obj["jmap"].request(IdentityGet()))


if __name__ == "__main__":
    cli()
