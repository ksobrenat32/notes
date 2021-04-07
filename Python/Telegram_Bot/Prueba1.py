#!/usr/bin/python3
# -*- coding: utf-8 -*-

import logging

from telegram.ext import Updater, CommandHandler, MessageHandler, Filters

# Enable logging
logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                    level=logging.INFO)
logger = logging.getLogger(__name__)

# Define a few command handlers. These usually take the two arguments update and
# context. Error handlers also receive the raised TelegramError object in error.
def error(update, context):
    """Log Errors caused by Updates."""
    logger.warning('Update "%s" caused error "%s"', update, context.error)

def start(update, context):
    """/start"""
    update.message.reply_text('Hola, Identificate c:')

def help(update, context):
    """/help"""
    txthelp = 'Hola Familia Calderon Olalde,\nPara ingresar escribe /tunombre y yo te podre atender de forma personalizada'
    update.message.reply_text(txthelp)

def yo(update, context):
    """/yo"""
    update.message.reply_text('Hola bro, en que te ayudo?')

def notext(update, context):
    """Respuesta a no comandos"""
    update.message.reply_text('Jajajaja soy un bot, no te entiendo.\n \nSi necesitas ayuda dime: /help')

def main():
    """Start the bot."""
    # Create the Updater and pass it your bot's token.
    # Make sure to set use_context=True to use the new context based callbacks
    updater = Updater("1360723607:AAE7OpQ_m2egI-TzdYhDPcRTN1cOwBVHpg4", use_context=True)

    # Get the dispatcher to register handlers
    dp = updater.dispatcher

    # Respuesta a los comandos
    dp.add_handler(CommandHandler("start", start))
    dp.add_handler(CommandHandler("help", help))
    dp.add_handler(CommandHandler("yo", yo))

    # Respuesta a los no comandos
    dp.add_handler(MessageHandler(Filters.text, notext))


    # log all errors
    dp.add_error_handler(error)
    # Start the Bot
    updater.start_polling()
    # Run the bot until you press Ctrl-C or the process receives SIGINT,
    updater.idle()


if __name__ == '__main__':
    main()
