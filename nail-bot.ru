from telegram import ReplyKeyboardMarkup, ReplyKeyboardRemove, Update
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters, ConversationHandler, CallbackContext

# Этапы диалога
NAME, PHONE, DATE, TIME = range(4)

# Список доступного времени
AVAILABLE_TIMES = ["10:00", "12:00", "14:00", "16:00", "18:00"]

# Замените на свой Telegram ID (чтобы бот присылал заявки только вам)
ADMIN_CHAT_ID = 5341387687

def start(update: Update, context: CallbackContext) -> int:
    update.message.reply_text("Здравствуйте! Как вас зовут?")
    return NAME

def get_name(update: Update, context: CallbackContext) -> int:
    context.user_data["name"] = update.message.text
    update.message.reply_text("Введите, пожалуйста, ваш номер телефона:")
    return PHONE

def get_phone(update: Update, context: CallbackContext) -> int:
    context.user_data["phone"] = update.message.text
    update.message.reply_text("Выберите дату записи (в формате ДД.ММ):")
    return DATE

def get_date(update: Update, context: CallbackContext) -> int:
    context.user_data["date"] = update.message.text
    reply_markup = ReplyKeyboardMarkup([[t] for t in AVAILABLE_TIMES], one_time_keyboard=True)
    update.message.reply_text("Выберите удобное время:", reply_markup=reply_markup)
    return TIME

def get_time(update: Update, context: CallbackContext) -> int:
    context.user_data["time"] = update.message.text
    data = context.user_data

    # Сообщение мастеру
    message = (
        f"📥 Новая заявка:\n\n"
        f"👤 Имя: {data['name']}\n"
        f"📞 Телефон: {data['phone']}\n"
        f"📅 Дата: {data['date']}\n"
        f"🕒 Время: {data['time']}"
    )

    # Отправка мастеру
    context.bot.send_message(chat_id=ADMIN_CHAT_ID, text=message)

    # Подтверждение пользователю
    update.message.reply_text("Спасибо! Ваша заявка принята 💅", reply_markup=ReplyKeyboardRemove())
    return ConversationHandler.END

def cancel(update: Update, context: CallbackContext) -> int:
    update.message.reply_text("Заявка отменена.", reply_markup=ReplyKeyboardRemove())
    return ConversationHandler.END

def main():
    # Вставьте сюда свой токен
    TOKEN = "7370182688:AAHmLe6ezP-SXVwoT2kubCy0qT72VV9DDZ4"

    updater = Updater(TOKEN)
    dispatcher = updater.dispatcher

    conv_handler = ConversationHandler(
        entry_points=[CommandHandler("start", start)],
        states={
            NAME: [MessageHandler(Filters.text & ~Filters.command, get_name)],
            PHONE: [MessageHandler(Filters.text & ~Filters.command, get_phone)],
            DATE: [MessageHandler(Filters.text & ~Filters.command, get_date)],
            TIME: [MessageHandler(Filters.text & ~Filters.command, get_time)],
        },
        fallbacks=[CommandHandler("cancel", cancel)],
    )

    dispatcher.add_handler(conv_handler)

    updater.start_polling()
    updater.idle()

if __name__ == "__main__":
    main()
