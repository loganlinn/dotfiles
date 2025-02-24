import click
import os

from rich import print
import jmapc
from jmapc.methods import IdentityGet, IdentityGetResponse
import onepassword.client


@click.group()
@click.version_option()
@click.option("--host", envvar="JMAP_HOSTNAME", default="api.fastmail.com")
@click.option("--api-token", envvar="JMAP_API_TOKEN")
@click.pass_context
def cli(ctx, host, api_token):
    ctx.ensure_object(dict)
    ctx.obj["jmap"] = jmapc.Client.create_with_api_token(
        host=host,
        api_token=api_token,
    )


@cli.command(name="create")
@click.pass_obj
def create_cli(obj):
    print(obj["jmap"].request(IdentityGet()))
