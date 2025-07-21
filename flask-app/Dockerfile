FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY flask_app/ flask_app/

ENV FLASK_APP=flask_app.main

CMD ["flask", "run", "--host=0.0.0.0", "--port=8080"]
