# Используем официальный легкий образ Python
FROM python:3.11-slim-bullseye

# Устанавливаем рабочую директорию в контейнере
WORKDIR /app

# Копируем файл с зависимостями и устанавливаем их
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем весь код проекта в рабочую директорию
COPY . .

# Открываем порт, на котором запустится приложение
EXPOSE 5000

# Команда для запуска приложения
CMD ["python", "app.py"]