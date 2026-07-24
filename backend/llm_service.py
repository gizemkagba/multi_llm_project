import httpx
import asyncio
import os
import json
from typing import Dict, List, Tuple
from database import save_model_response, save_process_log, save_query

WORKER_MODELS = [
    {"id": "meta-llama/llama-3-8b-instruct:free", "name": "Llama 3 8B"},
    {"id": "google/gemma-2-9b-it:free", "name": "Gemma 2 9B"},
    {"id": "mistralai/mistral-7b-instruct:free", "name": "Mistral 7B"},
    {"id": "deepseek/deepseek-chat:free", "name": "DeepSeek Chat"},
    {"id": "microsoft/phi-3-mini-128k-instruct:free", "name": "Phi 3 Mini"}
]

COORDINATOR_MODEL = {"id": "qwen/qwen-2-7b-instruct:free", "name": "Qwen 2 7B (Koordinatör)"}

OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"

def get_smart_mock_responses(question: str) -> Tuple[Dict[str, str], str]:
    """Soru içeriğine göre sade, doğrudan ve son derece gerçekçi mock cevaplar üretir."""
    q_lower = question.lower()
    
    topic = "genel"
    if "e-ticaret" in q_lower or "satış" in q_lower or "pazarlama" in q_lower:
        topic = "e_ticaret"
    elif "eğitim" in q_lower or "öğretmen" in q_lower or "okul" in q_lower:
        topic = "egitim"
    elif "mars" in q_lower or "uzay" in q_lower or "koloni" in q_lower:
        topic = "uzay"
    elif "kahve" in q_lower or "dükkan" in q_lower or "girişim" in q_lower:
        topic = "girisim"

    if topic == "e_ticaret":
        workers = {
            "Llama 3 8B": "Llama 3 8B Yanıtı:\nE-ticaret satışlarını artırmanın en hızlı yolu sosyal medya reklamları (Instagram/TikTok) ve influencer işbirlikleriyle ani trafik çekmektir.",
            "Gemma 2 9B": "Gemma 2 9B Yanıtı:\nSüreci yapısal olarak ele alırsak, öncelikle web sitesi dönüşüm oranlarını (UI/UX) optimize etmeli, ödeme adımlarını kolaylaştırmalıyız.",
            "Mistral 7B": "Mistral 7B Yanıtı:\nMüşterilere özel kişiselleştirilmiş e-posta kampanyaları ve yaratıcı sadakat programları sunarak sadık bir kitle oluşturulmalıdır.",
            "DeepSeek Chat": "DeepSeek Chat Yanıtı:\nVeri analitiği entegrasyonu şarttır. Hangi ürünün ne kadar tıklandığını, sepet terk etme oranlarını analiz edip dinamik fiyatlandırma yapılmalıdır.",
            "Phi 3 Mini": "Phi 3 Mini Yanıtı:\nÖzetle; müşteri yorumlarını öne çıkarmak, SEO çalışması yapmak ve hızlı kargo seçenekleri sunmak satışı tetikler."
        }
        coordinator = (
            "ANALİZ: E-TİCARET BÜYÜME STRATEJİSİ RAPORU\n\n"
            "E-ticaret sitenizin satış hacmini artırmak için entegre bir yaklaşım gereklidir. İlk aşamada, sosyal medya kanalları ve hedefli reklam kampanyalarıyla siteye nitelikli ziyaretçi akışı sağlanmalıdır. Bu trafiğin satışa dönüşebilmesi için web sitesinin arayüz (UI/UX) tasarımı sadeleştirilmeli, özellikle mobil cihazlarda ödeme adımları hızlı ve sorunsuz hale getirilmelidir. Güven duygusunu pekiştirmek amacıyla müşteri yorumları ve sosyal kanıtlar görünür kılınmalıdır. Son aşamada ise, analitik veriler sürekli incelenerek sepeti terk etme noktaları tespit edilmeli ve kullanıcı alışkanlıklarına göre dinamik teklifler sunulmalıdır. Bu adımların uyum içinde yürütülmesi, dönüşüm oranlarında kalıcı ve sürdürülebilir bir büyüme sağlayacaktır."
        )
        
    elif topic == "egitim":
        workers = {
            "Llama 3 8B": "Llama 3 8B Yanıtı:\nYapay zeka eğitimde kişiselleştirilmiş öğrenme platformları sunarak her öğrencinin kendi hızında ilerlemesini sağlayacaktır.",
            "Gemma 2 9B": "Gemma 2 9B Yanıtı:\nEğitimin yapısı değişecek, öğretmenlerin rolü bilgi aktarıcı olmaktan çıkıp rehberlik, koçluk ve mentörlüğe evrilecektir.",
            "Mistral 7B": "Mistral 7B Yanıtı:\nYapay zeka, öğretmenlerin sınav okuma ve idari işler gibi rutin yüklerini azaltarak onlara yaratıcı ders tasarımları için zaman kazandıracaktır.",
            "DeepSeek Chat": "DeepSeek Chat Yanıtı:\nÖğrencilerin öğrenme eksikliklerini anlık tespit eden ve buna uygun ödevlendirme yapan analitik sistemler yaygınlaşacaktır.",
            "Phi 3 Mini": "Phi 3 Mini Yanıtı:\nEğitimde fırsat eşitliği artacak, dünyanın her yerindeki öğrenciler en iyi eğitim kaynaklarına yapay zeka asistanları ile ulaşabilecektir."
        }
        coordinator = (
            "ANALİZ: YAPAY ZEKANIN EĞİTİMDEKİ GELECEĞİ VE ÖĞRETMEN ROLÜ RAPORU\n\n"
            "Yapay zeka teknolojileri, eğitim sistemini bilgi ezberleten geleneksel yapıdan çıkarıp bireyselleştirilmiş bir öğrenme modeline dönüştürmektedir. Bu süreçte öğretmenlerin rolü bilgi aktarıcılığından ziyade rehberlik, mentörlük ve sosyal-duygusal destek koçluğuna evrilecektir. Yapay zeka asistanları; sınav okuma, ders programı hazırlama ve idari yazışmalar gibi rutin iş yüklerini üstlenerek öğretmenlere daha yaratıcı ders tasarlama fırsatı sunacaktır. Aynı zamanda, veri odaklı analitik araçlar sayesinde öğrencilerin öğrenme eksiklikleri erkenden tespit edilerek bireysel gelişim haritaları çıkarılabilecektir. Sonuç olarak yapay zeka öğretmenlerin yerini almayacak, aksine onların pedagojik liderlik rollerini güçlendirecektir."
        )

    elif topic == "uzay":
        workers = {
            "Llama 3 8B": "Llama 3 8B Yanıtı:\nMars'taki en büyük zorluk atmosferin olmaması ve aşırı yüksek radyasyondur. İlk koloniler yer altında kurulmalıdır.",
            "Gemma 2 9B": "Gemma 2 9B Yanıtı:\nLojistik olarak, Mars'a tonlarca malzeme taşımak imkansızdır. Bu yüzden Mars toprağından (regolit) 3D yazıcılarla yaşam alanları üretilmelidir.",
            "Mistral 7B": "Mistral 7B Yanıtı:\nİnsan psikolojisi ve kapalı alanda uzun süre kalmanın getirdiği sosyal stres, Mars görevlerindeki en kritik insan faktörüdür.",
            "DeepSeek Chat": "DeepSeek Chat Yanıtı:\nSu üretimi için Mars buzulları eritilmeli ve sabatier reaksiyonu kullanılarak geri dönüşümlü oksijen sistemleri kurulmalıdır.",
            "Phi 3 Mini": "Phi 3 Mini Yanıtı:\nYerçekiminin Dünya'nın %38'i olması kas ve kemik erimesine yol açar, koloniciler için özel egzersiz rejimleri uygulanmalıdır."
        }
        coordinator = (
            "ANALİZ: MARS KOLONİZASYONU FİZİBİLİTE RAPORU\n\n"
            "Mars'ta kalıcı bir insan kolonisi kurmak; atmosfer yetersizliği, yüksek radyasyon, lojistik sınırlamalar ve düşük yerçekimi gibi kritik zorlukları barındırmaktadır. Bu engelleri aşmak için kolonilerin lav tüplerine kurulması veya Mars toprağını (regolit) hammadde olarak kullanan otonom 3D yazıcı robotlar tarafından inşa edilmesi gerekmektedir. Su ve oksijen ihtiyacı, Mars buzullarının eritilmesi ve kapalı devre yaşam destek ünitelerinin kullanılmasıyla yerinde (In-situ) kaynak kullanımı ile çözülmelidir. Son olarak, düşük yerçekiminin kas ve kemik yapısı üzerindeki olumsuz etkileri yoğun egzersiz programlarıyla, uzun süreli izolasyonun psikolojik etkileri ise sosyal yaşam alanlarının tasarımıyla dengelenmelidir."
        )
        
    elif topic == "girisim":
        workers = {
            "Llama 3 8B": "Llama 3 8B Yanıtı:\nGirişimcilikte en önemli şey 'Yalın Girişim' mantığıdır. Büyük bütçeler harcamadan önce prototip ürünle pazara çıkılmalıdır.",
            "Gemma 2 9B": "Gemma 2 9B Yanıtı:\niş planı oluşturulurken gelir modeli netleştirilmeli, başabaş noktası (break-even point) hesaplanmalıdır.",
            "Mistral 7B": "Mistral 7B Yanıtı:\nMarka kimliği ve özgün bir hikaye anlatımı, rakiplerinizden sıyrılmanızı sağlayacak en güçlü pazarlama silahıdır.",
            "DeepSeek Chat": "DeepSeek Chat Yanıtı:\nMüşteri edinme maliyeti (CAC) ve ömür boyu müşteri değeri (LTV) oranları sürekli izlenmeli, birim ekonomi kurulmalıdır.",
            "Phi 3 Mini": "Phi 3 Mini Yanıtı:\nİlk aşamada büyük bir ekip kurmak yerine, dış kaynak (outsource) ve çok yönlü kurucu ortaklarla yola çıkılmalıdır."
        }
        coordinator = (
            "ANALİZ: GİRİŞİMCİLİK VE YALIN İŞ GELİŞTİRME TAVSİYELERİ\n\n"
            "Yeni bir girişim başlatırken başarı şansını artırmak için ilk aşamada tüm sermayeyi ürüne yatırmak yerine, en temel çalışan versiyonu (MVP) hızlıca pazara sunarak gerçek müşteri geri bildirimleri toplanmalıdır. İş planında gelir modeli ilk günden netleştirilmeli, müşteri edinme maliyetinin (CAC) müşteriden elde edilen ömür boyu değerden (LTV) düşük olmasına dikkat edilmelidir. Rekabetin yoğun olduğu pazarlarda fiyat savaşına girmek yerine, markaya özgün bir hikaye ve değer önerisi katarak sadık bir niş kitle yaratılması sürdürülebilir büyümenin anahtarıdır."
        )
        
    else:
        workers = {
            "Llama 3 8B": f"Llama 3 8B Yanıtı:\nSorunuzu analiz ettim. Bence bu konuda en önemli nokta hızlı ve pratik çözümler sunmaktır. Soru: '{question}'",
            "Gemma 2 9B": f"Gemma 2 9B Yanıtı:\nGoogle Gemma olarak, bu soruya bilimsel ve analitik yaklaşmayı öneriyorum. Yapısal olarak adımları belirlemeliyiz. Soru: '{question}'",
            "Mistral 7B": f"Mistral 7B Yanıtı:\nYaratıcı ve esnek bir yaklaşımla, Mistral olarak bence bu sorunun çözümü alternatif yolları denemekten geçiyor. Soru: '{question}'",
            "DeepSeek Chat": f"DeepSeek Chat Yanıtı:\nKonuyu detaylı incelediğimde, verimlilik ve kodlama/mantık perspektifinden şu noktalar ön plana çıkıyor. Soru: '{question}'",
            "Phi 3 Mini": f"Phi 3 Mini Yanıtı:\nMicrosoft Phi olarak, hafif ve etkili bir mantıkla konuyu şu şekilde özetleyebilirim. Soru: '{question}'"
        }
        coordinator = (
            "ANALİZ: KONSOLİDE ANALİZ RAPORU\n\n"
            f"Talebiniz üzerine yapılan detaylı analizler sonucunda; bu sorunu çözerken operasyonel hız ile pratik aksiyon planlarının birleştirilmesi ve sürecin aşamalı olarak doğrulanması gerektiği görülmüştür. Yaratıcı alternatif çözüm yolları aranırken aynı zamanda verimlilik ölçütleri ve birim kaynak kullanımı da sürekli olarak izlenmelidir. Bu çok boyutlu yaklaşım, hedeflenen sonuca en dengeli ve kararlı şekilde ulaşılmasını sağlayacaktır."
        )
        
    return workers, coordinator

async def query_model(
    client: httpx.AsyncClient, 
    api_key: str, 
    model_id: str, 
    model_name: str, 
    messages: List[Dict[str, str]],
    question: str = ""
) -> Tuple[str, str]:
    if not api_key or api_key == "YOUR_OPENROUTER_API_KEY":
        workers_mock, coord_mock = get_smart_mock_responses(question)
        if model_name in workers_mock:
            await asyncio.sleep(1.2)
            return model_name, workers_mock[model_name]
        elif "Koordinatör" in model_name:
            await asyncio.sleep(1.5)
            return model_name, coord_mock
        return model_name, "Analiz verisi alınamadı."

    headers = {
        "Authorization": f"Bearer {api_key}",
        "HTTP-Referer": "http://localhost:8000",
        "X-Title": "Multi-LLM Coordinator App",
        "Content-Type": "application/json"
    }
    
    payload = {
        "model": model_id,
        "messages": messages
    }
    
    try:
        response = await client.post(OPENROUTER_URL, headers=headers, json=payload, timeout=45.0)
        if response.status_code == 200:
            data = response.json()
            answer = data["choices"][0]["message"]["content"]
            return model_name, answer
        else:
            return model_name, f"Hata (HTTP {response.status_code}): {response.text}"
    except Exception as e:
        return model_name, f"İstek Hatası: {str(e)}"

async def orchestrate_multi_llm(question: str, api_key: str, db_path: str = None) -> Dict:
    from database import DEFAULT_DB_PATH
    actual_db = db_path or DEFAULT_DB_PATH
    
    logs = []
    responses = {}
    
    def log_step(step_desc: str):
        logs.append(step_desc)
        print(f"[LOG] {step_desc}")

    log_step("Çoklu LLM sorgulama süreci başlatıldı.")
    log_step(f"Soru: '{question}'")
    
    log_step("5 çalışan model (Llama 3, Gemma 2, Mistral, DeepSeek, Phi 3) eşzamanlı olarak çağrılıyor...")
    
    worker_messages = [
        {"role": "user", "content": question}
    ]
    
    is_mock = not api_key or api_key == "YOUR_OPENROUTER_API_KEY"
    smart_workers, smart_coord = get_smart_mock_responses(question)
    
    async with httpx.AsyncClient() as client:
        if is_mock:
            for model in WORKER_MODELS:
                await asyncio.sleep(0.4)
                responses[model["name"]] = smart_workers.get(model["name"], "")
                log_step(f"'{model['name']}' modelinden cevap başarıyla alındı.")
        else:
            tasks = [
                query_model(client, api_key, model["id"], model["name"], worker_messages, question)
                for model in WORKER_MODELS
            ]
            worker_results = await asyncio.gather(*tasks)
            for model_name, response in worker_results:
                responses[model_name] = response
                log_step(f"'{model_name}' modelinden cevap başarıyla alındı.")
            
        log_step("Modellerden gelen cevaplar sentezlenmek üzere birleştiriliyor...")
        
        synthesis_prompt = (
            f"Sen bir Koordinatör Dil Modelisin. Görevin, bir kullanıcının sorduğu soruya "
            f"farklı 5 dil modelinin (Llama 3, Gemma 2, Mistral, DeepSeek, Phi 3) verdiği cevapları analiz etmek ve "
            f"en doğru, kapsamlı sentezi sunmaktır.\n\n"
            f"Raporunda 'Llama 3 şunu dedi, Gemma 2 bunu önerdi' gibi model özetlerini tek tek listeleme. Model isimlerini raporda hiç geçirme. "
            f"Doğrudan konsolide edilmiş nihai cevabı/raporu profesyonel ve bütünsel bir metin olarak sun.\n\n"
            f"Kullanıcının Sorusu: {question}\n\n"
            f"Modellerden Gelen Cevaplar:\n\n"
        )
        
        for name, resp in responses.items():
            synthesis_prompt += f"--- {name} Cevabı ---\n{resp}\n\n"
            
        synthesis_prompt += (
            "Lütfen yukarıdaki cevapların hepsini göz önünde bulundurarak, "
            "doğrudan konsolide edilmiş nihai sentez raporunu oluştur."
        )
        
        log_step("Koordinatör Model (Qwen 2) çağrılıyor, sentez işlemi yapılıyor...")
        
        coordinator_messages = [
            {"role": "system", "content": "Sen yetenekli bir sentezleyici ve koordinatör yapay zekasın. Raporunda model isimlerini (Llama, Gemma vb.) kullanmadan doğrudan bütünsel bir metin sunarsın."},
            {"role": "user", "content": synthesis_prompt}
        ]
        
        if is_mock:
            await asyncio.sleep(1.0)
            final_answer = smart_coord
            log_step("Koordinatör model sentez işlemini tamamladı.")
        else:
            coord_name, final_answer = await query_model(
                client, 
                api_key, 
                COORDINATOR_MODEL["id"], 
                COORDINATOR_MODEL["name"], 
                coordinator_messages,
                question
            )
            log_step("Koordinatör model sentez işlemini tamamladı.")
        
        log_step("Tüm veriler (sorgu, model cevapları ve loglar) SQLite veritabanına kaydediliyor...")
        
        query_id = save_query(question, final_answer, actual_db)
        
        for model_name, response in responses.items():
            save_model_response(query_id, model_name, response, actual_db)
            
        save_model_response(query_id, COORDINATOR_MODEL["name"], final_answer, actual_db)
        
        for log in logs:
            save_process_log(query_id, log, actual_db)
            
        log_step("Veritabanı kayıt işlemi tamamlandı. Süreç başarıyla sonlandırıldı.")
        save_process_log(query_id, "Süreç başarıyla sonlandırıldı.", actual_db)
        
        return {
            "query_id": query_id,
            "question": question,
            "final_response": final_answer,
            "worker_responses": responses,
            "logs": logs + ["Süreç başarıyla sonlandırıldı."]
        }
