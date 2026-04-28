FROM python:3.13-alpine

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN addgroup -S app && adduser -S -G app -h /app app

COPY pyproject.toml README.md ./
COPY src ./src

RUN pip install --no-cache-dir --root-user-action=ignore .

USER app

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/healthz', timeout=2).read()"

CMD ["uvicorn", "chatops_guard_summariser.main:app", "--host", "0.0.0.0", "--port", "8080"]
