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
    %% Subgraphs and Components Definition
    subgraph "I. Инфраструктура и Настройка (IaC)"
        TF(fa:fa-file-code Terraform) -- "1. Создает VPC, VM, Firewall в GCP" --> GCP(fab:fa-google GCP Cloud)
        ANSIBLE(fa:fa-wrench Ansible) -- "2. Конфигурирует VM" --> GCP
        ANSIBLE -- "Устанавливает" --> Docker(fab:fa-docker Docker Runtime)
        ANSIBLE -- "Настраивает Стек" --> MONITORING_STACK(fa:fa-chart-line Мониторинг)
        ANSIBLE -- "Настраивает Стек" --> LOGGING_STACK(fa:fa-stream Логирование)
        ANSIBLE -- "Настраивает" --> NGINX(fa:fa-share-alt Nginx Reverse Proxy)
        ANSIBLE -- "Настраивает" --> BACKUP(fa:fa-save Backup: scp -r)
    end

    subgraph "II. CI/CD Pipeline (GitHub Actions)"
        GH_VCS(fab:fa-github GitHub Main Branch) -- "Push/Merge" --> GH_ACTIONS(fab:fa-github-actions GitHub Actions)
        GH_ACTIONS -- "3. Собирает Образы" --> DOCKER_BUILD(fab:fa-docker Build Frontend/Backend)
        DOCKER_BUILD -- "4. Пушит Образы" --> GITHUB_CR(fa:fa-database GitHub Container Registry)
        GH_ACTIONS -- "5. Деплой (SSH/Deploy)" --> PROD_VM(fa:fa-server Продакшен VM (GCP))
        GH_ACTIONS -- "6. Уведомление" --> TELEGRAM(fab:fa-telegram Telegram Bot)
    end

    subgraph "III. Продакшен Окружение (PROD_VM)"
        PROD_VM -- "Запускает" --> FRONTEND(fa:fa-desktop Frontend Container)
        PROD_VM -- "Запускает" --> BACKEND(fa:fa-cogs Backend Container)
        PROD_VM -- "Хостит" --> MONITORING_STACK
        PROD_VM -- "Хостит" --> LOGGING_STACK
        PROD_VM -- "Хостит" --> NGINX
        NGINX -- "https://gamestats.svdbel.org" --> FRONTEND
    end

    subgraph "IV. Сервисы Мониторинга и Логирования"
        MONITORING_STACK -- "Стек" --> PROM(fa:fa-fire Prometheus)
        MONITORING_STACK -- "Стек" --> GRAFANA(fa:fa-chart-bar Grafana)
        MONITORING_STACK -- "Стек" --> ALERT_M(fa:fa-bell AlertManager)
        MONITORING_STACK -- "Стек" --> CADVISOR(fa:fa-docker Cadvisor)
        MONITORING_STACK -- "Стек" --> NODE_EXP(fa:fa-microchip Node Exporter)

        LOGGING_STACK -- "Стек" --> ELASTIC(fa:fa-search Elasticsearch)
        LOGGING_STACK -- "Стек" --> KIBANA(fa:fa-book Kibana)
        LOGGING_STACK -- "Стек" --> LOGSTASH(fa:fa-inbox Logstash)
        LOGGING_STACK -- "Стек" --> FILEBEAT(fa:fa-file-alt Filebeat)
    end

    %% Data Flow
    FRONTEND -- "API Calls" --> BACKEND
    BACKEND -- "Использует API" --> DOTA_API(fa:fa-gamepad OpenDota API)

    %% Styling (Для лучшей наглядности)
    classDef infra fill:#DDEBF7,stroke:#333,stroke-width:2px;
    class GCP,TF,ANSIBLE infra;

    classDef ci_cd fill:#FFF2CC,stroke:#333,stroke-width:2px;
    class GH_VCS,GH_ACTIONS,GITHUB_CR ci_cd;

    classDef prod fill:#E2F0D9,stroke:#333,stroke-width:2px;
    class PROD_VM,FRONTEND,BACKEND,NGINX prod;

    classDef tools fill:#FBE4D5,stroke:#333,stroke-width:2px;
    class MONITORING_STACK,LOGGING_STACK,TELEGRAM,DOTA_API tools;