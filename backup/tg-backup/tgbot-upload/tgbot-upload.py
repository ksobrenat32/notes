#!/usr/bin/python3
# -*- coding: utf8 -*-

# Python script to upload files to telegram as a bot
# without the limits of 50MB, using telethon library.

from os import getenv
from telethon import TelegramClient
import argparse

# Bot configuration through enviroment variables
bot_token = getenv("bot_token")
api_id = getenv("api_id")
api_hash = getenv("api_hash")
channel_id = getenv("channel_id")

# Convert channel to integer
channel_id=int(channel_id)

# Start client
bot = TelegramClient('bot', api_id, api_hash).start(bot_token=bot_token)

# Get the file to upload through argument
parser = argparse.ArgumentParser(
    description="Script to upload files Telegram Channel.")
parser.add_argument(
        "-f","--file",
        type=str,
        dest='file',
        help=
        'File to be uploaded',
        )
args = parser.parse_args()

async def main():
    await bot.send_file(channel_id, args.file)
with bot:
    bot.loop.run_until_complete(main())
