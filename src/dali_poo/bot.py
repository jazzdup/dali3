import logging
import os
import re
import click
from slack_bolt import App
from slack_bolt.adapter.socket_mode import SocketModeHandler

from dali_poo.google_secrets import get_secret

logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"), format="%(levelname)s: %(message)s"
)

slackbot = App(
    token=get_secret("dali-poo-bot-token"),
    signing_secret=get_secret("dali-poo-signing-secret"),
    token_verification_enabled=os.getenv("SLACK_TOKEN_VERIFICATION_ENABLED", "true") == "true"
)


def command_help(respond, ack):
    ack()
    respond(
        """
        Please add the commands available.
        """
    )


def mention_help(event, say):
    say(
        """
        Please add the mentions
        """,
        thread_ts=event["ts"]
    )


@click.command(help="starts dali poo")
@click.option(
    "--socket-mode/--no-socket-mode", default=True, help="connection to Slack"
)
def main(socket_mode):
    """
    starts dali poo
    """
    slackbot.event(
        "app_mention",
    )(mention_help)

    slackbot.command("/dali")(command_help)

    if socket_mode:
        app_token = get_secret("dali-poo-app-token")
        handler = SocketModeHandler(slackbot, app_token)
        handler.start()
    else:
        slackbot.start(port=int(os.getenv("PORT", 8080)), path="/slack/events")


if __name__ == "__main__":
    main()
