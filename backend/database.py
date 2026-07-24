import sqlite3
import os
from datetime import datetime

DEFAULT_DB_PATH = os.path.join(os.path.dirname(__file__), "database.db")

def get_connection(db_path=DEFAULT_DB_PATH):
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    return conn

def init_db(db_path=DEFAULT_DB_PATH):
    """Veritabanı tablolarını ilklendirir."""
    conn = get_connection(db_path)
    cursor = conn.cursor()
    
    # 1. Sorgular tablosu
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS queries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            question TEXT NOT NULL,
            final_response TEXT NOT NULL,
            created_at TEXT NOT NULL
        )
    """)
    
    # 2. Model Cevapları tablosu
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS model_responses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            query_id INTEGER NOT NULL,
            model_name TEXT NOT NULL,
            response TEXT NOT NULL,
            FOREIGN KEY (query_id) REFERENCES queries(id) ON DELETE CASCADE
        )
    """)
    
    # 3. Süreç Logları tablosu
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS process_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            query_id INTEGER NOT NULL,
            step_description TEXT NOT NULL,
            created_at TEXT NOT NULL,
            FOREIGN KEY (query_id) REFERENCES queries(id) ON DELETE CASCADE
        )
    """)
    
    conn.commit()
    conn.close()

def save_query(question: str, final_response: str, db_path=DEFAULT_DB_PATH) -> int:
    """Yeni bir sorguyu kaydeder ve ID'sini döner."""
    conn = get_connection(db_path)
    cursor = conn.cursor()
    created_at = datetime.now().isoformat()
    cursor.execute(
        "INSERT INTO queries (question, final_response, created_at) VALUES (?, ?, ?)",
        (question, final_response, created_at)
    )
    query_id = cursor.lastrowid
    conn.commit()
    conn.close()
    return query_id

def save_model_response(query_id: int, model_name: str, response: str, db_path=DEFAULT_DB_PATH):
    """Modelin verdiği cevabı kaydeder."""
    conn = get_connection(db_path)
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO model_responses (query_id, model_name, response) VALUES (?, ?, ?)",
        (query_id, model_name, response)
    )
    conn.commit()
    conn.close()

def save_process_log(query_id: int, step_description: str, db_path=DEFAULT_DB_PATH):
    """İşlem adımını veritabanına log olarak yazar."""
    conn = get_connection(db_path)
    cursor = conn.cursor()
    created_at = datetime.now().isoformat()
    cursor.execute(
        "INSERT INTO process_logs (query_id, step_description, created_at) VALUES (?, ?, ?)",
        (query_id, step_description, created_at)
    )
    conn.commit()
    conn.close()

def get_history(db_path=DEFAULT_DB_PATH):
    """Geçmiş tüm sorguları, model cevapları ve loglarıyla birlikte çeker."""
    conn = get_connection(db_path)
    cursor = conn.cursor()
    
    cursor.execute("SELECT * FROM queries ORDER BY created_at DESC")
    queries = [dict(row) for row in cursor.fetchall()]
    
    for q in queries:
        query_id = q["id"]
        
        cursor.execute("SELECT model_name, response FROM model_responses WHERE query_id = ?", (query_id,))
        q["model_responses"] = [dict(row) for row in cursor.fetchall()]
        
        cursor.execute("SELECT step_description, created_at FROM process_logs WHERE query_id = ? ORDER BY created_at ASC", (query_id,))
        q["process_logs"] = [dict(row) for row in cursor.fetchall()]
        
    conn.close()
    return queries
