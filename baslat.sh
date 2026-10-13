#!/bin/bash
# ==========================================
# Konsolide Analiz Sistemi - Tek Tıkla Başlatıcı
# ==========================================

echo "=========================================="
echo "🚀 1/3 Backend (FastAPI) Sunucusu Başlatılıyor..."
echo "=========================================="
cd /Users/gizemkagba/multi_llm_project/backend

# Eski çalışan işlem varsa 8000 portunu temizle
kill -9 $(lsof -t -i:8000) 2>/dev/null

# Sanal ortamı aktif et ve arka planda başlat
source venv/bin/activate
python main.py > backend.log 2>&1 &
BACKEND_PID=$!
echo "✅ Backend arka planda başlatıldı (PID: $BACKEND_PID - Log: backend/backend.log)"

echo ""
echo "=========================================="
echo "📱 2/3 iPhone Simülatörü Başlatılıyor..."
echo "=========================================="
open -a Simulator
sleep 3

echo ""
echo "=========================================="
echo "✨ 3/3 Mobil Uygulama (Flutter) Açılıyor..."
echo "=========================================="
cd /Users/gizemkagba/multi_llm_project/frontend
flutter run

# Flutter'dan çıkıldığında backend'i de temiz kapat
echo ""
echo "🛑 Uygulama kapatıldı. Backend sunucusu durduruluyor..."
kill $BACKEND_PID 2>/dev/null
echo "👋 Görüşmek üzere!"
