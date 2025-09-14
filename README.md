#### **ИГРОВОЙ ИНФОРМАЦИОННЫЙ ПОРТАЛ**

**"GameStats Hub"**

**Функционал:**
- Статистика игроков (выбрать одну игру)
- Рейтинги и лидерборды
- Гайды и builds
- Новости и патч-ноуты
- Турнирная сетка
- Сравнение игроков

**API варианты:**
- **Dota 2:** OpenDota API
- **CS:GO:** Steam API
- **League of Legends:** Riot API
- **Fortnite:** Fortnite API
- **Chess:** Chess.com API
  
**Технические особенности:**
- Микросервисная архитектура
- PostgreSQL/MySQL для хранения исторических данных
- Grafana для визуализации (Опционально)


## 🚀 Продакшен-развертывание и CI/CD

### Развертывание в продакшене (GCP)

1.  **Инфраструктура автоматизирована** с помощью Terraform:
    ```bash
    cd infrastructure/terraform
    terraform apply
    ```
    *Создает VPC, firewall rules и виртуальную машину в GCP*

2.  **Конфигурация сервера** автоматизирована с помощью Ansible:
    ```bash
    cd infrastructure/ansible  
    ansible-playbook -i inventory.ini playbook.yml
    ```
    *Устанавливает Docker, настраивает окружение и запускает контейнеры*

3.  **Доступ к приложению:**
    *   Production Frontend: http://35.210.251.54
    *   Production Backend: http://35.210.251.54:5001

### 🤖 Автоматический CI/CD Pipeline

При любом пуше в ветку `main` автоматически:
1.  **Собираются Docker образы** и пушатся в GitHub Container Registry
2.  **Развертывается новая версия** на продакшен-сервере в GCP  
3.  **Присылается уведомление** в Telegram о успешном деплое

### 🛠 Локальная разработка

1.  Клонируйте репозиторий:
    ```bash
    git clone <your-repo-url>
    cd GameStatsHub
    ```

2.  Запустите сборку и запуск контейнеров:
    ```bash
    docker-compose up --build
    ```

3.  Откройте в браузере:
    *   Локальный Frontend: `http://localhost:5000`
    *   Локальный Backend: `http://localhost:5001`

### 🌐 Доступные окружения

| Окружение | Frontend | Backend | Доступ |
|-----------|----------|---------|---------|
| **Локальное** | http://localhost:5000 | http://localhost:5001 | Разработка |
| **Прод** | http://35.210.251.54 | http://35.210.251.54:5001 | Production |

**CI/CD полностью автоматизирован** - код из `main` ветки автоматически становится продакшен-версией! 🎉