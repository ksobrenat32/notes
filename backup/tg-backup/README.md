# Telegram Backup

This is a script that helps to backup a directory
 in telegram which is kinda unlimited storage for
 free, at least at the moment of writing this.

## Obtain keys

Before working with Telegram’s API, you need to
 get your own API ID and hash:

1. [Login to your Telegram](https://my.telegram.org/)
 account with the phone number of the account to use.
2. Click under API Development tools.
3. A Create new application window will appear.
 Fill in your application details. There is no need
 to enter any URL, and only the first two fields
 (App title and Short name) can currently be changed later.
4. Click on Create application at the end. Remember
 that your API hash is secret and Telegram won’t
 let you revoke it. Don’t post it anywhere!

You will also need a telegram bot:

1. Open a conversation with @BotFather in Telegram
2. Use the /newbot command to create a new bot.
 The BotFather will ask you for a name and username,
 then generate an authorization token for your new bot.
3. The name of your bot is displayed in contact details
 and elsewhere.
4. The Username is a short name, to be used in mentions and
 telegram.me links. Usernames are 5-32 characters long and
 are case insensitive, but may only include Latin characters,
 numbers, and underscores. Your bot's username must end in
 ‘bot’, e.g. ‘tetris_bot’ or ‘TetrisBot’.
5. The token is a string along the lines of
 110201543:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw
 that is required to authorize the bot and send requests to
 the Bot API. Keep your token secure and store it safely, it
 can be used by anyone to control your bot.

## Install requirements

This script depends on various things. From your package
 manager, you should install 7zip

    sudo apt install p7zip-full

And with python pip you should go to ./tgbot-upload and
run as the user you want to backup:

    pip install -r requirements

## How to use

You need to define some environment variables (you
 can also define it inside both scripts).

- tgbot_dir='/path/to/tgbot-upload.py/dir'
- dir='/path/to/backup/dir'
- bup_dir='/path/to/save/backup/dir'
- filename='name_of_encrypted_files'
- pass='super strong password for encrypted drives'
- bot_token='Telegram bot token from BotFather'
- api_id='Telegram API ID'
- api_hash='Telegram API HASH'
- channel_id='The channel ID or user ID where files are sended'

Now you can just add to the crontab of the user
 that runs the backup:

    0 4 * * * /path/to/tg-backup

So it runs the backup daily at 4am

## Notes

- Try to have more than one user on the channel so that
 telegram does not see it as suspicious.
- DO NOT ABUSE, seriously.
