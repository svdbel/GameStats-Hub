from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def index():
    # Позже сюда будем подставлять данные из бэкенда
    return render_template('index.html', title='Главная')

@app.route('/about')
def about():
    return render_template('about.html', title='О проекте')

@app.route('/metrics')
def metrics():
    # Заглушка для страницы с метриками
    return render_template('metrics.html', title='Метрики')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')