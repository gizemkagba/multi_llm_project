import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  final List<String> _simulatedSteps = [
    "İstek veri merkezine iletildi.",
    "5 adet çalışan model eşzamanlı olarak tetikleniyor...",
    "Llama 3 8B, Gemma 2 9B ve Mistral 7B yanıtları hazırlanıyor...",
    "DeepSeek Chat ve Phi 3 Mini analizleri gerçekleştiriliyor...",
    "Tüm çalışan modellerin cevapları toplandı ve birleştirildi.",
    "Koordinatör model (Qwen) sentez işlemine başladı...",
    "Süreç adımları SQLite veritabanına yazılıyor...",
    "Nihai sentez raporu derleniyor..."
  ];
  
  int _currentSimulatedStep = 0;
  bool _isSimulating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _startSimulatedLoading() async {
    setState(() {
      _currentSimulatedStep = 0;
      _isSimulating = true;
    });

    for (int i = 0; i < _simulatedSteps.length; i++) {
      if (!_isSimulating) break;
      await Future.delayed(const Duration(seconds: 2));
      if (!_isSimulating) break;
      setState(() {
        _currentSimulatedStep = i + 1;
      });
    }
  }

  void _stopSimulatedLoading() {
    setState(() {
      _isSimulating = false;
    });
  }

  void _submitQuestion(ApiProvider apiProvider) async {
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen sorunuzu yazın")),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    _startSimulatedLoading();
    
    final success = await apiProvider.askQuestion(question);
    _stopSimulatedLoading();

    if (success) {
      _questionController.clear();
      _tabController.animateTo(0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: ${apiProvider.errorMessage}")),
      );
    }
  }

  // Model adına göre renk döner (Görsel zenginlik için)
  Color _getModelColor(String modelName) {
    if (modelName.contains("Llama")) return const Color(0xFF33A1FD); // Mavi
    if (modelName.contains("Gemma")) return const Color(0xFFFF9F1C); // Google Turuncu
    if (modelName.contains("Mistral")) return const Color(0xFFEE6C4D); // Koyu Turuncu
    if (modelName.contains("DeepSeek")) return const Color(0xFF4E598C); // Koyu Lacivert
    if (modelName.contains("Phi")) return const Color(0xFF2EC4B6); // Yeşil/Mavi
    return const Color(0xFFC61F1B); // Ziraat Kırmızısı
  }

  @override
  Widget build(BuildContext context) {
    final apiProvider = Provider.of<ApiProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header (Black Bold title "Analiz" and grey settings icon)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Analiz",
                    style: TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.tune_outlined, color: Colors.grey[600]),
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Arama Kutusu (Kırmızı Çerçeveli, Beyaz Zeminli)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC61F1B), width: 2), // Kurumsal Kırmızı Çerçeve
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _questionController,
                        maxLines: null,
                        style: const TextStyle(color: Colors.black87, fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: "Analiz edilecek sorunuzu yazın...",
                          hintStyle: TextStyle(color: Colors.black38, fontSize: 15),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Sağdaki ok butonu
                    GestureDetector(
                      onTap: apiProvider.isLoading ? null : () => _submitQuestion(apiProvider),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F1F4), // Açık gri buton arka planı
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: apiProvider.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(color: Color(0xFFC61F1B), strokeWidth: 2),
                                )
                              : const Icon(Icons.arrow_forward, color: Colors.black87, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Kalın Kırmızı Şerit/Çizgi
              Container(
                height: 3,
                width: double.infinity,
                color: const Color(0xFFC61F1B),
              ),
              const SizedBox(height: 24),

              // 4. İçerik (Stepper, Sonuçlar veya Boş Ekran)
              Expanded(
                child: apiProvider.isLoading
                    ? _buildFrististicStepper()
                    : apiProvider.currentResult != null
                        ? _buildResultsView(apiProvider.currentResult!)
                        : _buildEmptyState(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fütüristik Zaman Tüneli - Açık Renk Temalı
  Widget _buildFrististicStepper() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC61F1B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.query_stats, color: Color(0xFFC61F1B), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "Orkestrasyon İşleniyor",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.black12),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _simulatedSteps.length,
              itemBuilder: (context, index) {
                final isDone = index < _currentSimulatedStep;
                final isCurrent = index == _currentSimulatedStep;

                return IntrinsicHeight(
                  child: Row(
                    children: [
                      // Sol Dikey Çizgi ve Nokta Tasarımı
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone 
                                  ? Colors.green 
                                  : isCurrent 
                                      ? const Color(0xFFC61F1B) 
                                      : Colors.grey[300],
                              boxShadow: isCurrent 
                                  ? [BoxShadow(color: const Color(0xFFC61F1B).withOpacity(0.3), blurRadius: 8, spreadRadius: 1)]
                                  : isDone 
                                      ? [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 4)]
                                      : [],
                            ),
                          ),
                          if (index < _simulatedSteps.length - 1)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: isDone ? Colors.green.withOpacity(0.6) : Colors.black12,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      // Adım Metni
                      Expanded(
                        child: Padding(
                           padding: const EdgeInsets.only(bottom: 24.0),
                           child: Text(
                            _simulatedSteps[index],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              color: isDone 
                                  ? Colors.grey[500] 
                                  : isCurrent 
                                      ? Colors.black87 
                                      : Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Sonuç Görünümü - Açık Renk Temalı
  Widget _buildResultsView(Map<String, dynamic> result) {
    final finalResponse = result["final_response"] ?? "";
    final workerResponses = Map<String, dynamic>.from(result["worker_responses"] ?? {});
    final logs = List<String>.from(result["logs"] ?? []);

    return Column(
      children: [
        // Özel TabBar Tasarımı
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F1F4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.04)),
          ),
          padding: const EdgeInsets.all(4),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFC61F1B), Color(0xFFE53935)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black54,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: "Sentez (Qwen)"),
              Tab(text: "Modeller"),
              Tab(text: "Loglar"),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Sekme 1: Konsolide Sentez Raporu
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Color(0xFFC61F1B), size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            "Qwen 2 Sentez Raporu",
                            style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold, 
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32, color: Colors.black12),
                      SelectableText(
                        finalResponse,
                        style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),

              // Sekme 2: Modellerin Kendi Cevapları
              ListView.builder(
                itemCount: workerResponses.length,
                itemBuilder: (context, index) {
                  final modelName = workerResponses.keys.elementAt(index);
                  final response = workerResponses[modelName];
                  
                  if (modelName.contains("Koordinatör")) return const SizedBox.shrink();
                  final modelColor = _getModelColor(modelName);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black.withOpacity(0.06)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.01),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.antiAlias,
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: Text(
                            modelName,
                            style: TextStyle(fontWeight: FontWeight.bold, color: modelColor),
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: modelColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.smart_toy_outlined, color: modelColor, size: 18),
                          ),
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 4),
                              decoration: BoxDecoration(
                                border: Border(
                                    left: BorderSide(color: modelColor, width: 3),
                                ),
                              ),
                              child: SelectableText(
                                response,
                                style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Sekme 3: Loglar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(20.0),
                child: ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.arrow_right_alt, color: Color(0xFFC61F1B), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              logs[index],
                              style: const TextStyle(
                                fontFamily: 'Courier', 
                                fontSize: 13, 
                                color: Colors.black87,
                                height: 1.4
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Boş Başlangıç Ekranı - Görsel Şablona Birebir Uyumlu
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          // 1. Ağ Çizgili Grafik
          SizedBox(
            height: 180,
            width: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Bağlantı Çizgileri
                CustomPaint(
                  size: const Size(180, 180),
                  painter: NetworkLinesPainter6(),
                ),
                // Merkez Kırmızı Daire (İş Grafik İkonlu)
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFC61F1B),
                  ),
                  child: const Center(
                    child: Icon(Icons.bar_chart, color: Colors.white, size: 28),
                  ),
                ),
                // 6 Farklı Gösterge İkonlu Çevre Düğümü
                _buildNetworkNode6(0, -65, Icons.show_chart, Colors.red),
                _buildNetworkNode6(56, -33, Icons.monetization_on_outlined, Colors.amber[800]!),
                _buildNetworkNode6(56, 33, Icons.track_changes, Colors.teal),
                _buildNetworkNode6(0, 65, Icons.trending_down, Colors.blue),
                _buildNetworkNode6(-56, 33, Icons.warning_amber_rounded, Colors.orange),
                _buildNetworkNode6(-56, -33, Icons.check, Colors.black87),
              ],
            ),
          ),
          
          // Küçük aşağı ok ikonu
          const SizedBox(height: 8),
          const Icon(Icons.arrow_downward, color: Colors.black26, size: 20),
          const SizedBox(height: 12),
          
          // 2. Başlık ve Açıklamalar
          const Text(
            "Kapsamlı Analiz",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFC61F1B)),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Verilerinizi 6 farklı açıdan derinlemesine analiz eder ve işletmeniz\niçin önerilerde bulunur.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
            ),
          ),
          const SizedBox(height: 28),
          
          // 3. Şablon Başlığı
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                "ANALİZ ŞABLONLARI",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black38, letterSpacing: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // 4. Şablon Kartları (3 Adet Yan Yana - Claude Tasarımı)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildSuggestionCard6(
                  "E-Ticaret Satış",
                  Icons.shopping_cart_outlined,
                  "E-ticaret sitemizin satışlarını artırmak için neler yapabiliriz?",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSuggestionCard6(
                  "Dijital Pazarlama",
                  Icons.phone_android_outlined,
                  "Dijital pazarlama kampanyalarımızın dönüşüm oranlarını nasıl yükseltiriz?",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSuggestionCard6(
                  "İşletme Raporu",
                  Icons.business_center_outlined,
                  "Sürdürülebilir bir iş büyütmek isteyen bir girişimci için en önemli 3 tavsiye nedir?",
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Çevre ağ düğümleri üretici
  Widget _buildNetworkNode6(double dx, double dy, IconData icon, Color iconColor) {
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFFC61F1B), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              spreadRadius: 1,
            )
          ],
        ),
        child: Center(
          child: Icon(icon, size: 16, color: iconColor),
        ),
      ),
    );
  }

  // 3'lü Şablon Kart Tasarımı
  Widget _buildSuggestionCard6(String title, IconData icon, String question) {
    return GestureDetector(
      onTap: () {
        _questionController.text = question;
      },
      child: Container(
        height: 95,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, color: const Color(0xFFC61F1B), size: 26),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

// 6'lı Ağ Çizgisi Çizici
class NetworkLinesPainter6 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    
    final nodes = [
      Offset(center.dx + 0, center.dy - 65),
      Offset(center.dx + 56, center.dy - 33),
      Offset(center.dx + 56, center.dy + 33),
      Offset(center.dx + 0, center.dy + 65),
      Offset(center.dx - 56, center.dy + 33),
      Offset(center.dx - 56, center.dy - 33),
    ];

    for (var node in nodes) {
      canvas.drawLine(center, node, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
