# ---------- STAGE 1: builder ----------
FROM python:3.12-slim AS builder

WORKDIR /app

ENV PIP_NO_CACHE_DIR=1

# Если нужны бинарные зависимости (psycopg2, pillow и т.п.)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
  && rm -rf /var/lib/apt/lists/*

# Сначала только зависимости
COPY requirements.txt .

# Ставим их в отдельный префикс /install
RUN pip install --prefix=/install -r requirements.txt


# ---------- STAGE 2: runtime ----------
FROM python:3.12-slim AS runtime

WORKDIR /app

ENV PYTHONUNBUFFERED=1

# Копируем только установленное из builder'а
COPY --from=builder /install /usr/local

# Копируем сам проект
COPY . .

# Если у тебя FastAPI на Uvicorn:
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
