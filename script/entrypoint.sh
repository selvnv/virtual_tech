#!/bin/sh
# Устанавливаем флаг, означающий остановку выполнения скрипта,
# если при выполнении команды произошла ошибка 
# (по умолчанию bash игнорирует ошибки)
set -e

# Вывод информации о текущем пользователе
echo "Current user: $(whoami)"

# Переключаемся в контекст непривилегированного пользователя
# exec gosu myuser12 "$@"
# gosu myuser12 python server.py
exec python create_db.py
exec python server.py

echo "Current user: $(whoami)"

# myuser: имя пользователя, под которым будет запущена команда
# Этот пользователь создается в Docker-образе с помощью команды useradd в Dockerfile

# "$@": спец. переменная оболочки, которая содержит все аргументы, переданные скрипту при его вызове. 
# Таким образом, команда exec gosu myuser "$@" выполнит команду, указанную при запуске контейнера, от имени пользователя myuser