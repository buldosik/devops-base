import os
import psycopg2
from fastapi import FastAPI
from fastapi.responses import JSONResponse
from pydantic import BaseModel

app = FastAPI()


def get_db_conn():
    conn = psycopg2.connect(
        dbname=os.getenv("POSTGRES_DB", "appdb"),
        user=os.getenv("POSTGRES_USER", "appuser"),
        password=os.getenv("POSTGRES_PASSWORD", "apppass"),
        host=os.getenv("POSTGRES_HOST", "devops-postgres"),
        port=int(os.getenv("POSTGRES_PORT", "5432")),
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


class Item(BaseModel):
    name: str


@app.post("/items")
def create_item(item: Item):
    conn = get_db_conn()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO items (name) VALUES (%s) RETURNING id;",
        (item.name,),
    )
    new_id = cur.fetchone()[0]
    conn.commit()
    conn.close()
    return {"id": new_id, "name": item.name}


@app.get("/items")
def get_items():
    conn = get_db_conn()
    cur = conn.cursor()
    cur.execute("SELECT id, name FROM items;")
    rows = cur.fetchall()
    conn.close()
    return [{"id": r[0], "name": r[1]} for r in rows]
    