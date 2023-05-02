import logging
import os
import re
import click
import requests
import json
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

# Set up the DALL-E API endpoint and key
DALLE_API_URL = "https://api.openai.com/v1/images/generations"
DALLE_API_KEY = get_secret("dali-poo-dalle-token")


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


# Define a function to generate DALL-E images
def generate_image(prompt):
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {DALLE_API_KEY}",
    }
    data = {
        "model": "image-alpha-001",
        "prompt": prompt,
        "num_images": 1,
        "size": "512x512",
        "response_format": "url",
    }
    response = requests.post(DALLE_API_URL, headers=headers, data=json.dumps(data))
    if response.status_code == 200:
        return response.json()["data"][0]["url"]
    else:
        return None

# Define a function to post an image in a Slack channel
def post_image(image_url, channel):
    slackbot.client.chat_postMessage(
        channel=channel,
        blocks=[
            {
                "type": "image",
                "title": {"type": "plain_text", "text": "DALL-E image"},
                "image_url": image_url,
                "alt_text": "DALL-E image",
            }
        ],
    )

# Define a new command that triggers the DALL-E image generation and posting
@slackbot.command("/dalle")
def generate_and_post_image(ack, respond, command):
    prompt = command["text"]
    image_url = generate_image(prompt)
    if image_url:
        post_image(image_url, command["channel_id"])
        respond(f"Here's your DALL-E image based on the prompt '{prompt}': {image_url}")
    else:
        respond("Sorry, I couldn't generate an image based on that prompt.")


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
