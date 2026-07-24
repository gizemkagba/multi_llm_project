import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _keyController;

  @override
  void initState() {
    super.initState();
    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    _keyController = TextEditingController(text: apiProvider.apiKey);
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  void _saveSettings(ApiProvider apiProvider) {
    apiProvider.setApiKey(_keyController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ayarlar kaydedildi.")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final apiProvider = Provider.of<ApiProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text("Ayarlar"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleTextStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.black.withOpacity(0.06)),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "OpenRouter API Anahtarı",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC61F1B)),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _keyController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: "sk-or-v1-...",
                          hintStyle: const TextStyle(color: Colors.black38),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear, color: Colors.black45),
                            onPressed: () => _keyController.clear(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Not: API anahtarınızı girmezseniz, sistem otomatik olarak 'Mock Modu'nda çalışacak ve simüle edilmiş model cevapları üretecektir. Bu sayede API anahtarınız olmasa dahi tüm akışı test edebilirsiniz.",
                        style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _saveSettings(apiProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC61F1B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Kaydet",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
