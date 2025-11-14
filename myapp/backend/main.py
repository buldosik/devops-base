import os
import psycopg2
from fastapi import FastAPI
from fastapi.responses import JSONResponse

app = FastAPI()


def get_db_conn():
    conn = psycopg2.connect(
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT"),
    )
    return conn


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/db-check")
def db_check():
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        cur.execute("SELECT 1;")
        cur.fetchone()
        conn.close()
        return {"db": "ok"}
    except Exception as e:
        return JSONResponse(status_code=500, content={"db": "error", "detail": str(e)})
