#!/bin/bash
# Скрипт автоматического бэкапа Docker volumes
# Ansible: backup_docker_volumes.sh

# Настройки (заменяются Ansible)
DEST_HOST="{{ groups['backup'][0] }}"
DEST_PATH_NAME="{{ inventory_hostname }}"

# Константы
SOURCE_DIR="/var/lib/docker/volumes/"
BASE_BACKUP_DIR="/var/backups/cp_manual"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
FINAL_DEST_DIR="$BASE_BACKUP_DIR/$DEST_PATH_NAME/$TIMESTAMP"

# Логирование
LOG_FILE="/var/log/backup_docker_volumes.log"
echo "$(date '+%Y-%m-%d %H:%M:%S'): Начало бэкапа Docker volumes" >> $LOG_FILE
echo "$(date '+%Y-%m-%d %H:%M:%S'): Хост назначения: $DEST_HOST" >> $LOG_FILE
echo "$(date '+%Y-%m-%d %H:%M:%S'): Директория назначения: $FINAL_DEST_DIR" >> $LOG_FILE

# Проверка существования исходной директории
if [ ! -d "$SOURCE_DIR" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S'): ОШИБКА: Исходная директория $SOURCE_DIR не существует!" >> $LOG_FILE
    exit 1
fi

# Создание директории на backup-хосте
echo "$(date '+%Y-%m-%d %H:%M:%S'): Создание директории на backup-хосте..." >> $LOG_FILE
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$DEST_HOST "sudo mkdir -p $FINAL_DEST_DIR && sudo chown ubuntu:ubuntu $FINAL_DEST_DIR"

if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S'): ОШИБКА: Не удалось создать директорию на backup-хосте" >> $LOG_FILE
    exit 1
fi

# Копирование volumes
echo "$(date '+%Y-%m-%d %H:%M:%S'): Начало копирования Docker volumes..." >> $LOG_FILE
scp -r -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $SOURCE_DIR ubuntu@$DEST_HOST:$FINAL_DEST_DIR

if [ $? -eq 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Копирование успешно завершено" >> $LOG_FILE
    
    # Обновление симлинка latest
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Обновление симлинка 'latest'..." >> $LOG_FILE
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$DEST_HOST "cd $BASE_BACKUP_DIR/$DEST_PATH_NAME && sudo ln -snf $TIMESTAMP latest"
    
    # Очистка старых бэкапов (храним последние 7 версий)
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Очистка старых бэкапов (оставляем последние 7 версий)..." >> $LOG_FILE
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$DEST_HOST "cd $BASE_BACKUP_DIR/$DEST_PATH_NAME && ls -1t | tail -n +8 | sudo xargs -r rm -rf"
    
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Бэкап успешно завершен: $FINAL_DEST_DIR" >> $LOG_FILE
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Симлинк 'latest' обновлен" >> $LOG_FILE
else
    echo "$(date '+%Y-%m-%d %H:%M:%S'): ОШИБКА при выполнении копирования!" >> $LOG_FILE
    exit 1
fi