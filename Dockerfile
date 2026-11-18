FROM python:3.11-slim

ENV PORT=5000

WORKDIR /app

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py .

RUN useradd -m appuser && chown -R appuser:appuser /app /home/appuser
USER appuser

EXPOSE 5000

HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
  CMD curl -f http://localhost:${PORT}/health || exit 1

CMD exec gunicorn -w 2 --threads 2 --timeout 60 --keep-alive 5 -b 0.0.0.0:${PORT} app:app
