# Konsolide Veri Analiz ve Karar Destek Sistemi

Bu proje, kullanıcının girdiği bir analiz konusunu 5 farklı bağımsız analiz modülüne eşzamanlı olarak gönderen, bu modüllerden gelen bulguları Konsolidasyon Modülü aracılığıyla sentezleyip tek bir konsolide rapor haline getiren ve tüm süreci SQLite yerel veritabanına kaydeden kapsamlı bir sistemdir.

## 🎥 Proje Tanıtım Videosu (Demo)

### [▶ PROJE TANITIM VİDEOSUNU İZLEMEK İÇİN BURAYA TIKLAYIN](/gizemkagba/multi_llm_project/raw/main/demo_video.mp4)

*(Not: Bu bağlantı tarayıcınızın kendi video oynatıcısını açacaktır. Sayfada otomatik Türkçe çeviri aktifse bağlantı adresi bozulabilir. Hata alırsanız çeviriyi kapatıp tıklayabilirsiniz).*

## Proje Klasör Yapısı

```text
multi_llm_project/
├── backend/                  # Python FastAPI Sunucusu
│   ├── database.db           # SQLite Veritabanı (ilk çalıştırmada oluşur)
│   ├── database.py           # Veritabanı okuma/yazma işlemleri
│   ├── llm_service.py        # Veri Sentez Modülü & Simülasyon Akışı
│   ├── main.py               # Sunucu başlangıç ve uç noktaları (endpoints)
│   ├── requirements.txt      # Python bağımlılıkları
│   └── .env                  # Veri Servisi Erişim Anahtarı (İsteğe bağlı)
└── frontend/                 # Flutter Mobil Uygulaması
    ├── lib/
    │   ├── main.dart         # Uygulama başlangıcı ve tema ayarları
    │   ├── providers/
    │   │   └── api_provider.dart # Durum yönetimi ve API bağlantısı
    │   └── screens/
    │       ├── home_screen.dart     # Analiz talebi ve rapor görüntüleme ekranı
    │       ├── history_screen.dart  # Geçmiş raporları listeleme ekranı
    │       └── settings_screen.dart # Bağlantı ayarları ekranı
    └── pubspec.yaml          # Flutter bağımlılıkları
```

---

## 1. Adım: Backend (Python FastAPI) Kurulumu ve Çalıştırılması

Sunucuyu başlatmak için terminalden aşağıdaki adımları takip edin:

1. **Temiz backend dizinine gidin:**
   ```bash
   cd /Users/gizemkagba/multi_llm_project/backend
   ```

2. **Python sanal ortamı (virtual environment) oluşturun:**
   ```bash
   python3 -m venv venv
   ```

3. **Sanal ortamı aktif edin:**
   ```bash
   source venv/bin/activate
   ```

4. **Gerekli paketleri kurun:**
   ```bash
   pip install -r requirements.txt
   ```

5. **Sunucuyu başlatın:**
   ```bash
   python main.py
   ```
   *Sunucunuz `http://localhost:8000` adresinde çalışmaya başlayacaktır. API dokümantasyonuna tarayıcınızdan `http://localhost:8000/docs` adresinden erişebilirsiniz.*

---

## 2. Adım: Frontend (Flutter) Kurulumu ve Çalıştırılması

Uygulamayı çalıştırmak için yeni bir terminal sekmesi açarak şu adımları uygulayın:

1. **Frontend dizinine gidin:**
   ```bash
   cd /Users/gizemkagba/multi_llm_project/frontend
   ```

2. **Platform dosyalarını üretmek ve Flutter projesini hazır hale getirmek için (İlk sefer için):**
   ```bash
   flutter create --org com.antigravity.consolidatedsystem --project-name frontend --platforms android,ios,macos,web .
   ```
   *(Bu komut, yazdığımız Dart kodlarını bozmadan gerekli mobil altyapı klasörlerini oluşturur).*

3. **Flutter bağımlılıklarını indirin:**
   ```bash
   flutter pub get
   ```

4. **Uygulamayı çalıştırın:**
   ```bash
   flutter run
   ```

---

## Simülasyon Modu (Erişim Anahtarı Olmadan Test Etme)

- Erişim anahtarı girilmediğinde sistem otomatik olarak **Simülasyon Modu**na geçer. Verilerin işlenme adımlarını simüle eder, adımları tek tek işlem günlüğüne kaydeder ve veritabanına mock (taslak) raporları basar.
- Gerçek veri kaynaklarını bağlamak istediğinizde, mobil uygulamadaki sağ üstte yer alan **Ayar** simgesine tıklayarak erişim anahtarınızı tanımlayabilirsiniz.
