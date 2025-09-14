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


## Локальный запуск для разработки

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
    *   Frontend: `http://localhost:5000`
    *   Backend: `http://localhost:5001`

