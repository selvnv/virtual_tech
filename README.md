# Технологии виртуализации

## Запуск

| # | Команда для запуска | Описание |
|---|---|---|
| 1 | `docker build -t server-app .` | Команда используется для создания Docker-образа из Dockerfile, который находится в текущей директории (.) |
|  | `docker build` |  Это команда Docker для создания Docker-образов |
|  | `-t server-app` | Опция -t используется для задания тега (или имени) образа. В данном случае мы задаем имя образа как `server-app` |
|  | `.` | Это путь к контексту сборки. В текущем контексте сборки должен находиться Dockerfile, который будет использован для создания образа |
| 2 | `docker run -p 8000:8000 server-app` | Команда используется для запуска контейнера из Docker-образа `server-app` |
|  | `docker run` | Это команда Docker для запуска контейнера |
|  | `-p 8000:8000` |  Опция `-p` используется для проброса портов между хостом и контейнером. В данном случае мы пробрасываем порт 8000 хоста на порт 8000 контейнера |
|  | `server-app` | Это имя Docker-образа, из которого будет запущен контейнер |

Таким образом, после выполнения команды #2, будет запущен контейнер из Docker-образа server-app, и порт 8000 на хосте будет привязан к порту 8000 внутри контейнера, что позволит вам обращаться к приложению, которое работает в контейнере, через порт 8000 на вашем хосте

## Хост

В контексте веб-серверов, таких как Flask, `хост` обозначает сетевой интерфейс, на котором сервер прослушивает входящие соединения и обрабатывает запросы. Указание хоста определяет, на каких сетевых интерфейсах сервер будет слушать входящие запросы.

Когда вы запускаете веб-приложение, вы можете указать хост, на котором оно будет доступно. Например:

+ `'127.0.0.1'` или `'localhost'` указывает на то, что сервер будет доступен только локально на том же компьютере, где он запущен.
+ `'0.0.0.0'` указывает на то, что сервер будет доступен на всех сетевых интерфейсах, доступных на устройстве. Это означает, что он будет слушать входящие запросы извне, включая запросы из локальной сети или из интернета.

В контексте Docker, указание хоста `'0.0.0.0'` важно, чтобы серверное приложение в контейнере было доступно извне контейнера.

<details>
<summary>Что, если...</summary>

Если запустить серверное приложение на базе Flask в Docker контейнере и не указать `host='0.0.0.0'`, Flask по умолчанию будет прослушивать только локальный IP-адрес контейнера. Это означает, что Flask приложение будет доступно только внутри контейнера и не будет доступно извне.

Для того чтобы Flask приложение было доступно извне контейнера, например, для обработки входящих запросов из интернета или из других контейнеров в той же сети, нужно явно указать host='0.0.0.0', чтобы Flask прослушивал все сетевые интерфейсы в контейнере.

</details>

## Непрерывная интеграция (CI)

Файл .gitlab-ci.yml определяет набор инструкций для GitLab CI/CD, которые выполняются при каждом коммите в репозиторий

| Этап | Код                                                                                                                                                      | Описание                                                                                                                                                                                                                     |
|-|----------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|Определение переменных окружения| `variables: DOCKER_IMAGE_TAG: $CI_COMMIT_SHA`                                                                                                            | Здесь определяется переменная DOCKER_IMAGE_TAG, которая используется для тегирования Docker-образа. Этот тег устанавливается равным хэшу коммита Git ($CI_COMMIT_SHA), что гарантирует уникальность тега для каждого коммита |
|Определение стадий| `stages: - build - push - cleanup`                                                                                                                       | Определяем три этапа: сборка, публикация и очистка. Каждый этап содержит связанные с ним задачи                                                                                                                              |
|Задача сборки Docker-образа| `build: stage: build script: - docker build -t $CI_REGISTRY_IMAGE:$DOCKER_IMAGE_TAG .`                                                                   | В этой задаче используется инструкция docker build для сборки Docker-образа. Тегируем этот образ с помощью переменной DOCKER_IMAGE_TAG                                                                                       |
|Задача публикации Docker-образа| `push: stage: push script: - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY - docker push $CI_REGISTRY_IMAGE:$DOCKER_IMAGE_TAG` | После сборки используем docker push, чтобы загрузить собранный образ в GitLab Registry                                                                                                                                       |
|Задача для очистки| `cleanup: stage: cleanup script: - docker rmi $CI_REGISTRY_IMAGE:$DOCKER_IMAGE_TAG`| В этой задаче используется docker rmi, чтобы удалить собранный образ с GitLab Runner-а после его публикации в GitLab Registry|

Таким образом, при каждом коммите GitLab CI автоматически выполняет эти задачи, что позволяет автоматизировать процесс сборки, тестирования и публикации Docker-образов

### Правила
Для задач, связанных со сборкой, публикацией и очисткой образа, используются правила, чтобы эти задачи выполнялись только в случае наличия тега коммита. Это означает, что эти задачи будут запускаться автоматически только тогда, когда вы создаете тег для коммита. Для этого нужно использовать команду git tag

В блоке rules можно определить несколько правил, которые будут проверяться в порядке их объявления, и задача будет выполняться, если хотя бы одно из правил оценивается как истинное

### Многоэтапная сборка (Multistage Building)

| Этап                                                 | Определение (начало) этапа | Описание                                                                                                                                                  |
|------------------------------------------------------|----------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| Компиляция / Сборка                                  | `FROM golang:1.21 AS build`        | На этом этапе формируется образ с исходным кодом, подключенными библиотеками и т.д.                                                                       |
| Копирование артефакта компиляции и запуск приложения | `FROM scratch AS run`       | В отрыве от этапа компиляции, этот этап позволяет получить легковесный образ (скомпилированное приложение только с используемым кодом) |

### Сравнение размеров образов при обычной сборке и multistage

Образ `hello_full` - результат сборки в один этап, `hello_multistage` - легковесный образ, собранный в 2 этапа

![Сравнение размеров образов](/doc/compare_image_size.png)
