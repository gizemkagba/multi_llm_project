from PIL import Image

source_path = "/Users/gizemkagba/.gemini/antigravity/brain/2b3a25cd-2e0d-41f7-9c61-82da8e2fd1c7/ziraat_app_icon_1784903355098.jpg"
target_path = "/Users/gizemkagba/multi_llm_project/ziraat_app_icon_cropped.png"

try:
    img = Image.open(source_path)
    width, height = img.size
    
    # Kırmızı alanı tam olarak merkezden kırpalım (Kenardaki beyaz boşluğu atmak için)
    # Görselin yaklaşık %76'lık orta kısmını alıyoruz
    crop_width = int(width * 0.76)
    crop_height = int(height * 0.76)
    
    left = (width - crop_width) // 2
    top = (height - crop_height) // 2
    right = left + crop_width
    bottom = top + crop_height
    
    cropped_img = img.crop((left, top, right, bottom))
    cropped_img.save(target_path, "PNG")
    print(f"Kırpılmış Ziraat logosu başarıyla kaydedildi: {target_path}")
except Exception as e:
    print(f"Hata oluştu: {e}")
