#### **ИГРОВОЙ ИНФОРМАЦИОННЫЙ ПОРТАЛ**

**"GameStats Hub"**

**Функционал:**
- **Статистика игроков**
- **Рейтинги и лидерборды**
- **Новости и патч-ноуты**
- **Сравнение игроков**

**API:**
- **Dota 2:** OpenDota API

**Технологии:**
- **VCS:** GitHub
- **Контейнеризация:** Docker
- **Веб-приложение:** Python Flask, HTML + CSS + JS, Bootstrap
- **CI/CD:** GitHub Actions
- **IaC:** Terraform, Ansible
- **Мониторинг:** Prometheus, Grafana, AlertManager,Cadvisor
- **Логирование:** ELK Stack (Elasticsearch, Kibana, LogstashбFilebeat)
- **Веб-серверы:** Nginx
- **Бекапы:** scp -r 
- **Уведомления:** Telegram Bot
- **Облачные платформы:** GCP
- **CDN:** Cloudflare


##  Продакшен-развертывание и CI/CD

### Развертывание в продакшене (GCP)

1.  **Инфраструктура автоматизирована** с помощью Terraform:
    ```bash
    cd infrastructure/terraform
    terraform apply
    ```
    *Создает VPC, firewall rules и виртуальные машины в GCP*

2.  **Конфигурация сервера** автоматизирована с помощью Ansible:
    ```bash
    cd infrastructure/ansible  
    ansible-playbook -i inventory.ini playbook.yml ssh-playbook.yml monitoring-playbook.yml node_exporter_install.yml logging-playbook.yml ngnix-reverse-proxy.yml backup.yml --ask-vault-password 
    ```
    *Устанавливает Docker, настраивает окружение и запускает контейнеры(frontend,backend)*
    *Запрещает доступ по паролю (доступ по ssh ключу)*
    *Устанавливает и настраивает стек мониторинга : prometheus,grafana,alertmanager,cadvisor*
    *Устанавливает и настраивает node_exporter*
    *Устанавливает и настраивает стек логирования : elasticsearch,kibana,logstash,filebeat*
    *Устанавливает и настраивает reverse-proxy*
    *Настраивае backup docker volume *

3.  **Доступ к приложению:**
    *   Production Frontend: https://gamestats.svdbel.org
    *   Production Backend: http://localhost:5001

###  Автоматический CI/CD Pipeline

При любом пуше в ветку `main` автоматически:
1.  **Собираются Docker образы** и пушатся в GitHub Container Registry
2.  **Развертывается новая версия** на продакшен-сервере в GCP  
3.  **Присылается уведомление** в Telegram о успешном деплое

###  Локальная разработка

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

###  Доступные окружения

| Окружение | Frontend | Backend | Доступ |
|-----------|----------|---------|---------|
| **Локальное** | http://localhost:5000        | http://localhost:5001 | Разработка |
| **Прод**      | https://gamestats.svdbel.org |                       | Production |

**CI/CD полностью автоматизирован** - код из `main` ветки автоматически становится продакшен-версией!

graph TD
    %% Infrastructure Provisioning & Configuration
    subgraph "I. Инфраструктура как код (IaC)"
        Terraform["fa:fa-code Terraform"] -- "Создает VPC, VM, Firewall" --> GCP["fab:fa-google GCP Cloud"]
        Ansible["fa:fa-wrench Ansible"] -- "Конфигурирует сервер" --> GCP
    end

    %% CI/CD Pipeline
    subgraph "II. CI/CD Pipeline (GitHub Actions)"
        GitHub["fab:fa-github GitHub Main"] -- "Push/Merge" --> GitHubActions["fab:fa-github-actions GitHub Actions"]
        GitHubActions -- "Сборка образов" --> DockerBuild["fab:fa-docker Build Images"]
        DockerBuild -- "Публикация" --> GHCR["fa:fa-database GitHub Container Registry"]
        GitHubActions -- "Деплой на сервер" --> ProductionVM["fa:fa-server Production VM"]
        GitHubActions -- "Уведомление" --> TelegramBot["fab:fa-telegram Telegram Bot"]
    end

    %% Production Environment
    subgraph "III. Продакшен окружение"
        ProductionVM -- "Запускает" --> DockerContainers["fab:fa-docker Docker Containers"]
        
        DockerContainers --> Frontend["fa:fa-desktop Frontend Container"]
        DockerContainers --> Backend["fa:fa-cogs Backend Container"]
        DockerContainers --> Nginx["fa:fa-share-alt Nginx Reverse Proxy"]
        
        Nginx -- "https://gamestats.svdbel.org" --> Frontend
        Frontend -- "API запросы" --> Backend
        Backend -- "Внешние данные" --> OpenDotaAPI["fa:fa-gamepad OpenDota API"]
    end

    %% Monitoring Stack
    subgraph "IV. Стек мониторинга"
        MonitoringStack["fa:fa-chart-line Monitoring Stack"] --> Prometheus["fa:fa-fire Prometheus"]
        MonitoringStack --> Grafana["fa:fa-chart-bar Grafana"]
        MonitoringStack --> AlertManager["fa:fa-bell AlertManager"]
        MonitoringStack --> Cadvisor["fa:fa-docker Cadvisor"]
        MonitoringStack --> NodeExporter["fa:fa-microchip Node Exporter"]
        
        Prometheus -- "Сбор метрик" --> ProductionVM
        Grafana -- "Визуализация" --> Prometheus
        AlertManager -- "Алерты" --> TelegramBot
    end

    %% Logging Stack
    subgraph "V. Стек логирования (ELK)"
        LoggingStack["fa:fa-stream Logging Stack"] --> Elasticsearch["fa:fa-search Elasticsearch"]
        LoggingStack --> Kibana["fa:fa-book Kibana"]
        LoggingStack --> Logstash["fa:fa-inbox Logstash"]
        LoggingStack --> Filebeat["fa:fa-file-alt Filebeat"]
        
        Filebeat -- "Сбор логов" --> ProductionVM
        Kibana -- "Аналитика логов" --> Elasticsearch
    end

    %% Backup
    subgraph "VI. Резервное копирование"
        Backup["fa:fa-save Backup System"] -- "scp -r docker volumes" --> BackupStorage["fa:fa-database Backup Storage"]
    end

    %% Local Development
    subgraph "VII. Локальная разработка"
        LocalDev["fa:fa-laptop Local Machine"] --> DockerCompose["fab:fa-docker docker-compose up --build"]
        DockerCompose --> LocalFrontend["http://localhost:5000"]
        DockerCompose --> LocalBackend["http://localhost:5001"]
    end

    %% Define Styles
    style Terraform fill:#623CE4,stroke:#333,stroke-width:1px,color:#fff
    style Ansible fill:#EE0000,stroke:#333,stroke-width:1px,color:#fff
    style GCP fill:#4285F4,stroke:#333,stroke-width:1px,color:#fff
    style GitHub fill:#181717,stroke:#333,stroke-width:1px,color:#fff
    style GitHubActions fill:#2088FF,stroke:#333,stroke-width:1px,color:#fff
    style GHCR fill:#2496ED,stroke:#333,stroke-width:1px,color:#fff
    style ProductionVM fill:#34A853,stroke:#333,stroke-width:1px,color:#fff
    style Frontend fill:#FF6D00,stroke:#333,stroke-width:1px,color:#fff
    style Backend fill:#FF6D00,stroke:#333,stroke-width:1px,color:#fff
    style Nginx fill:#009639,stroke:#333,stroke-width:1px,color:#fff
    style OpenDotaAPI fill:#1DA1F2,stroke:#333,stroke-width:1px,color:#fff
    style Prometheus fill:#E6522C,stroke:#333,stroke-width:1px,color:#fff
    style Grafana fill:#F46800,stroke:#333,stroke-width:1px,color:#fff
    style AlertManager fill:#FF9900,stroke:#333,stroke-width:1px,color:#fff
    style Cadvisor fill:#2496ED,stroke:#333,stroke-width:1px,color:#fff
    style NodeExporter fill:#8E44AD,stroke:#333,stroke-width:1px,color:#fff
    style Elasticsearch fill:#005571,stroke:#333,stroke-width:1px,color:#fff
    style Kibana fill:#005571,stroke:#333,stroke-width:1px,color:#fff
    style Logstash fill:#005571,stroke:#333,stroke-width:1px,color:#fff
    style Filebeat fill:#005571,stroke:#333,stroke-width:1px,color:#fff
    style TelegramBot fill:#0088CC,stroke:#333,stroke-width:1px,color:#fff
    style Backup fill:#795548,stroke:#333,stroke-width:1px,color:#fff
    style LocalDev fill:#9C27B0,stroke:#333,stroke-width:1px,color:#fff