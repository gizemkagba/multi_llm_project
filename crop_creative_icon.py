from PIL import Image

source_path = "/Users/gizemkagba/.gemini/antigravity/brain/2b3a25cd-2e0d-41f7-9c61-82da8e2fd1c7/creative_analysis_icon_1784905806938.jpg"
target_path = "/Users/gizemkagba/multi_llm_project/creative_icon_cropped.png"

try:
    img = Image.open(source_path)
    width, height = img.size
    
    # 3D logoyu çevreleyen buzlu cam kareyi kırpalım
    # x=100 ile x=924 arası (yaklaşık %80 orta alan)
    left = 100
    top = 100
    right = 924
    bottom = 924
    
    cropped_img = img.crop((left, top, right, bottom))
    resized_img = cropped_img.resize((1024, 1024), Image.Resampling.LANCZOS)
    resized_img.save(target_path, "PNG")
    print(f"Buzlu cam tasarımlı 3D ikon başarıyla kırpıldı ve kaydedildi: {target_path}")
except Exception as e:
    print(f"Hata oluştu: {e}")
