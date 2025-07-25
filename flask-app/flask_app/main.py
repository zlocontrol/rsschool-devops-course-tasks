from flask import Flask, Response
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

# Создаём счётчик запросов
REQUEST_COUNT = Counter('app_requests_total', 'Total number of requests to the root endpoint')

@app.route("/")
def index():
    REQUEST_COUNT.inc()  # Увеличиваем счётчик каждый раз, когда вызывается /
    return "Hello, Flask!"

# Новый endpoint — метрики Prometheus
@app.route("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)
