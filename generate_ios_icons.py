import os
import shutil
import subprocess

# Kaynak resim yolu (Yeni Yaratıcı 3D İkon)
SOURCE_IMAGE = "/Users/gizemkagba/multi_llm_project/creative_icon_cropped.png"
PROJECT_ROOT = "/Users/gizemkagba/multi_llm_project"
TARGET_DIR = os.path.join(PROJECT_ROOT, "frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset")

# Gerekli dosya isimleri ve piksel boyutları
ICON_SIZES = {
    "Icon-App-20x20@1x.png": 20,
    "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58,
    "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40,
    "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120,
    "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180,
    "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,  # (83.5 * 2 = 167)
    "Icon-App-1024x1024@1x.png": 1024
}

def generate_icons():
    # Kaynak resmi proje köküne kopyala
    temp_source = os.path.join(PROJECT_ROOT, "app_icon_temp.jpg")
    shutil.copy(SOURCE_IMAGE, temp_source)
    print(f"Kaynak görsel geçici olarak kopyalandı: {temp_source}")

    if not os.path.exists(TARGET_DIR):
        print(f"Hata: Target dizini bulunamadı! {TARGET_DIR}")
        return

    # macOS'un yerel 'sips' aracını kullanarak görselleri yeniden boyutlandır
    for filename, size in ICON_SIZES.items():
        out_path = os.path.join(TARGET_DIR, filename)
        # sips -s format png --resampleWidth {size} {temp_source} --out {out_path}
        cmd = [
            "sips",
            "-s", "format", "png",
            "--resampleWidth", str(size),
            temp_source,
            "--out", out_path
        ]
        
        try:
            subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            print(f"Oluşturuldu: {filename} ({size}x{size})")
        except Exception as e:
            print(f"Hata oluştu ({filename}): {e}")

    # Geçici dosyayı temizle
    if os.path.exists(temp_source):
        os.remove(temp_source)
        print("Geçici dosyalar temizlendi.")

if __name__ == "__main__":
    generate_icons()
