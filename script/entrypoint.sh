#!/bin/sh
# Устанавливаем флаг, означающий остановку выполнения скрипта,
# если при выполнении команды произошла ошибка 
# (по умолчанию bash игнорирует ошибки)
set -e

# Вывод информации о текущем пользователе
echo "Current user: $(whoami)"

# Ждем доступности порта PostgreSQL с использованием ncat
while ! ncat -z postgres 5432; do
  echo "Ждем доступности порта PostgreSQL..."
  sleep 1
done

# Переключаемся в контекст непривилегированного пользователя
# myuser12: имя пользователя, под которым будет запущена команда
# "$@": спец. переменная оболочки, которая содержит все аргументы, переданные скрипту при его вызове. 
# Таким образом, команда exec gosu myuser "$@" выполнит команду, указанную при запуске контейнера, от имени пользователя myuser (см. README)
# exec gosu myuser12 "$@"

# exec, заменяет текущий процесс новым процессом, и выполнение скрипта завершается, когда новый процесс завершается. Поэтому его не использую
python create_db.py
python server.py
#gosu myuser12 python server.py

echo "Current user: $(whoami)"