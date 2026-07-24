import os
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
from dotenv import load_dotenv

from database import init_db, get_history
from llm_service import orchestrate_multi_llm

load_dotenv()

app = FastAPI(
    title="Consolidated Data Analysis API",
    description="5 Analiz Modülü ve 1 Konsolidasyon Modülü yönetim servisi",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class QueryRequest(BaseModel):
    question: str
    api_key: Optional[str] = None

class QueryResponse(BaseModel):
    query_id: int
    question: str
    final_response: str
    worker_responses: dict
    logs: List[str]

@app.on_event("startup")
def startup_event():
    init_db()
    print("Veritabanı başarıyla ilklendirildi.")

@app.post("/api/ask", response_model=QueryResponse)
async def ask_question(request: QueryRequest):
    if not request.question.strip():
        raise HTTPException(status_code=400, detail="Talep içeriği boş olamaz.")
    
    api_key = request.api_key or os.getenv("OPENROUTER_API_KEY")
    
    try:
        result = await orchestrate_multi_llm(request.question, api_key)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"İşlem sırasında hata oluştu: {str(e)}")

@app.get("/api/history")
def get_query_history():
    try:
        history = get_history()
        return history
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Geçmiş yüklenirken hata oluştu: {str(e)}")

@app.get("/api/health")
def health_check():
    return {"status": "healthy", "database": "connected"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
