#### **ИГРОВОЙ ИНФОРМАЦИОННЫЙ ПОРТАЛ**

**"GameStats Hub"**

Игровой информационный портал для статистики, рейтингов игроков и аналитики,а также свежих новостей с мира Dota 2.

**Функционал:**
- **Статистика игроков**
- **Рейтинги и лидерборды**
- **Новости и патч-ноуты**
- **Сравнение героев и игроков**

## Архитектура приложения:

```
FRONTEND (HTML/CSS/JS + Bootstrap)
├─ base.html (базовый шаблон)
├─ index.html (главная)
├─ about.html (о проекте)
└─ metrics.html (метрики)
    ↓
BACKEND (Python Flask)
├─ Маршрутизация
├─ Рендеринг шаблонов  
└─ (потенциально REST API)
```

## Архитектура проекта:

```mermaid
graph TD
    subgraph "Infrastructure Provisioning"
        Terraform[Terraform] -- "Creates & Configures" --> GCPServer[GCP Server]
    end

    subgraph "Configuration Management"
        Ansible[Ansible] -- "Installs Docker Runtime & Configures" --> GCPServer
    end

    subgraph "CI/CD Pipeline"
        GitHub[GitHub Repository] -- "Triggers" --> GitHubActions[GitHub Actions CI/CD]
        GitHubActions -- "Builds & Pushes Image" --> DockerRegistry[GitHub Container Registry]
        GitHubActions -- "Pipeline" --> DeployTask[Deploy Application]
        DeployTask -- "Deploys to" --> AppServer[App Server]
    end

    subgraph "GCP Server Environment"
        GCPServer -- "Hosts" --> DockerContainers[Docker Containers]
    end

    subgraph "Running Docker Containers"
        DockerContainers --> NginxProxy[Nginx Reverse Proxy]
        DockerContainers --> MonitoringStack[Monitoring Stack]
        DockerContainers --> AppServer
    end

    subgraph "DNS & Routing"
        Cloudflare[Cloudflare DNS] -- "Proxies traffic to" --> NginxProxy
        NginxProxy -- "Routes Traffic to" --> AppServer
        NginxProxy -- "Routes Traffic to" --> MonitoringStack
    end

    subgraph "Application Services"
        AppServer --> Frontend[Frontend Container]
        AppServer --> Backend[Backend Container]
        Frontend -- "API Calls" --> Backend
        Backend -- "External Data" --> OpenDotaAPI[OpenDota API]
    end

    subgraph "Monitoring Stack"
        MonitoringStack --> Prometheus[Prometheus]
        MonitoringStack --> Grafana[Grafana]
        MonitoringStack --> AlertManager[AlertManager]
        MonitoringStack --> Cadvisor[cAdvisor]
        MonitoringStack --> NodeExporter[Node Exporter]
        Prometheus -- "Monitors" --> AppServer
        Prometheus -- "Monitors" --> GCPServer
        Grafana -- "Visualizes Data from" --> Prometheus
        AlertManager -- "Alerts" --> TelegramBot[Telegram Bot]
    end

    subgraph "Logging Stack"
        LoggingStack[Logging Stack] --> Elasticsearch[Elasticsearch]
        LoggingStack --> Kibana[Kibana]
        LoggingStack --> Logstash[Logstash]
        LoggingStack --> Filebeat[Filebeat]
        Filebeat -- "Collects Logs from" --> AppServer
        Filebeat -- "Collects Logs from" --> GCPServer
        Kibana -- "Visualizes Logs from" --> Elasticsearch
    end

    subgraph "Backup System"
        GCPServer -- "Backs up" --> VM[vm backup]
    end

    %% Define Styles
    style Terraform fill:#623CE4,stroke:#333,stroke-width:1px,color:#fff
    style Ansible fill:#EE0000,stroke:#333,stroke-width:1px,color:#fff
    style GCPServer fill:#4285F4,stroke:#333,stroke-width:1px,color:#fff
    style GitHub fill:#181717,stroke:#333,stroke-width:1px,color:#fff
    style GitHubActions fill:#2088FF,stroke:#333,stroke-width:1px,color:#fff
    style DockerContainers fill:#2496ED,stroke:#333,stroke-width:1px,color:#fff
    style DockerRegistry fill:#2496ED,stroke:#333,stroke-width:1px,color:#fff
    style NginxProxy fill:#009639,stroke:#333,stroke-width:1px,color:#fff
    style AppServer fill:#009639,stroke:#333,stroke-width:1px,color:#fff
    style Frontend fill:#FF6D00,stroke:#333,stroke-width:1px,color:#fff
    style Backend fill:#FF6D00,stroke:#333,stroke-width:1px,color:#fff
    style OpenDotaAPI fill:#1DA1F2,stroke:#333,stroke-width:1px,color:#fff
    style MonitoringStack fill:#f9f9f9,stroke:#333,stroke-width:1px,color:#333
    style Prometheus fill:#E6522C,stroke:#333,stroke-width:1px,color:#fff
    style Grafana fill:#F46800,stroke:#333,stroke-width:1px,color:#fff
    style AlertManager fill:#FF9900,stroke:#333,stroke-width:1px,color:#fff
    style Cadvisor fill:#2496ED,stroke:#333,stroke-width:1px,color:#fff
    style NodeExporter fill:#8E44AD,stroke:#333,stroke-width:1px,color:#fff
    style LoggingStack fill:#f9f9f9,stroke:#333,stroke-width:1px,color:#333
    style Elasticsearch fill:#005571,stroke:#333,stroke-width:1px,color:#fff
    style Kibana fill:#005571,stroke:#333,stroke-width:1px,color:#fff
    style Logstash fill:#005571,stroke:#333,stroke-width:1px,color:#fff
    style Filebeat fill:#005571,stroke:#333,stroke-width:1px,color:#fff
    style TelegramBot fill:#0088CC,stroke:#333,stroke-width:1px,color:#fff
    style Cloudflare fill:#F38020,stroke:#333,stroke-width:1px,color:#fff
    style VM fill:#795548,stroke:#333,stroke-width:1px,color:#fff
```

##  Технологический стек:

- **Frontend**: HTML/CSS/JavaScript, Bootstrap
- **Backend**: Python Flask, REST API
- **API интеграция**: OpenDota API
- **Контроль версий**: GitHub
- **Контейнеризация**: Docker, Docker Compose
- **CI/CD**: GitHub Actions
- **Инфраструктура как код**: Terraform, Ansible
- **Облачная платформа**: Google Cloud Platform (GCP)
- **CDN**: Cloudflare
- **Мониторинг**: Prometheus, Grafana, AlertManager, cAdvisor, Node Exporter
- **Логирование**: ELK Stack (Elasticsearch, Kibana, Logstash, Filebeat)
- **Веб-сервер**: Nginx (Reverse Proxy)
- **Бэкапы**: Автоматическое резервное копирование томов с SCP
- **Уведомления**: Telegram Bot
- **Безопасность SSH**: Только аутентификация по ключу


### Локальное развертывание

1. **Клонируйте репозиторий**:
   ```bash
   git clone <your-repo-url>
   cd GameStatsHub
   ```

2. **Запустите приложение**:
   ```bash
   docker-compose up --build
   ```

3. **Доступ к приложению**:
   - Frontend: `http://localhost:5000`
   - Backend: `http://localhost:5001`

### Продакшен развертывание

Продакшен окружение автоматизировано через CI/CD. Любой пуш в ветку `main` запускает:

1. **Автоматическую сборку** Docker образов
2. **Публикацию в GitHub Container Registry**
3. **Деплой на продакшен серверы** в GCP
4. **Уведомление в Telegram** об успешном деплое

## Структура проекта

```
GameStatsHub/
├── frontend/                # Frontend приложение
├── backend/                 # Backend API
├── backup                   # Backup(cron + scp)
├── infrastructure/
│   ├── terraform/           # Provisioning инфраструктуры
│   └── ansible/             # Конфигурация серверов
├── monitoring/              # Конфиги стека мониторинга
├── logging/                 # Конфиги ELK стека
├── reverse-proxy/           # Nginx конфигурации
├── docker-compose.yml       # Локальная разработка
├── docker-compose.prod.yml  # Продакшен сервисы
├── docker-compose.monitoring.yml  # Стек мониторинга
└── docker-compose.logging.yml     # Стек логирования
```

##  Управление инфраструктурой

### Terraform (Provisioning инфраструктуры)

```bash
cd infrastructure/terraform
terraform init
terraform plan
terraform apply
```

Создает в GCP:
- VPC сеть и подсеть
- Firewall правила
- Виртуальные машины (Продакшен и Бэкап)
- Статические IP адреса

### Ansible (Конфигурация серверов)

```bash
cd infrastructure/ansible
ansible-playbook -i inventory.ini playbook.yml ssh-playbook.yml monitoring-playbook.yml node_exporter_install.yml logging-playbook.yml ngnix-reverse-proxy.yml backup.yml --ask-vault-password
```

Настраивает:
- Установку Docker и Docker Compose
- Деплой приложения
- Стек мониторинга (Prometheus, Grafana, AlertManager)
- Стек логирования (ELK)
- Nginx reverse proxy
- Систему бэкапов
- Усиление безопасности SSH

### Компоненты мониторинга
- **Prometheus**: Сбор и хранение метрик
- **Grafana**: Визуализация и дашборды
- **AlertManager**: Управление и маршрутизация алертов
- **cAdvisor**: Метрики контейнеров
- **Node Exporter**: Системные метрики

### Компоненты логирования
- **Elasticsearch**: Хранение и индексация логов
- **Kibana**: Визуализация и анализ логов
- **Logstash**: Пайплайн обработки логов
- **Filebeat**: Сбор и отправка логов

## Функции безопасности

- Только аутентификация по SSH ключу (пароли отключены)
- Безопасное управление секретами через Ansible Vault
- Reverse proxy с Nginx
- Изоляция приложений через контейнеризацию

## Система бэкапов

- Резервное копирование томов с использованием SCP
- Использование *cron* для автоматизации РК
- Безопасная аутентификация по SSH ключу между серверами

## Окружения

| Окружение | Frontend | Backend | Назначение |
|-----------|----------|---------|------------|
| **Локальное** | http://localhost:5000 | http://localhost:5001 | Разработка |
| **Продакшен** | https://gamestats.svdbel.org | http://localhost:5001 | Продакшен деплой |

## Интеграция с API

Приложение интегрируется с:
- **OpenDota API**: Для статистики игроков Dota 2, данных матчей и информации о героях

## CI/CD Пайплайн

1. **Тестирование и сборка**: На каждом pull request
2. **Деплой в продакшен**: При мерже в main ветку
3. **Container Registry**: Автоматическая публикация в GitHub Container Registry
4. **Уведомления**: Telegram алерты о статусе деплоя

## Алертинг

- Алерты системных ресурсов (CPU, Memory, Disk)
- Health checks приложения
- Мониторинг статуса контейнеров
- Все алерты отправляются в Telegram