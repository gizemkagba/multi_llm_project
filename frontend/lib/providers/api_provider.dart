import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiProvider with ChangeNotifier {
  String get _baseUrl {
    if (kIsWeb) {
      return "http://localhost:8000/api";
    }
    try {
      if (Platform.isAndroid) {
        return "http://10.0.2.2:8000/api";
      }
    } catch (_) {}
    return "http://localhost:8000/api";
  }

  bool _isLoading = false;
  String _errorMessage = "";
  List<String> _logs = [];
  Map<String, dynamic>? _currentResult;
  List<dynamic> _history = [];
  String _apiKey = "";

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<String> get logs => _logs;
  Map<String, dynamic>? get currentResult => _currentResult;
  List<dynamic> get history => _history;
  String get apiKey => _apiKey;

  void setApiKey(String key) {
    _apiKey = key;
    notifyListeners();
  }

  void clearState() {
    _currentResult = null;
    _errorMessage = "";
    _logs = [];
    notifyListeners();
  }

  Future<bool> askQuestion(String question) async {
    _isLoading = true;
    _errorMessage = "";
    _logs = ["Talebiniz veri merkezine gönderiliyor..."];
    _currentResult = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/ask"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "question": question,
          "api_key": _apiKey.isNotEmpty ? _apiKey : null,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        _currentResult = data;
        _logs = List<String>.from(data["logs"] ?? []);
        _isLoading = false;
        notifyListeners();
        fetchHistory();
        return true;
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        _errorMessage = errorData["detail"] ?? "Bağlantı hatası oluştu (HTTP ${response.statusCode})";
        _logs.add("HATA: $_errorMessage");
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Sunucu bağlantısı başarısız. Lütfen yerel sunucunun çalıştığından emin olun. Detay: $e";
      _logs.add("HATA: Bağlantı kurulamadı.");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchHistory() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/history"));
      if (response.statusCode == 200) {
        _history = jsonDecode(utf8.decode(response.bodyBytes));
        notifyListeners();
      }
    } catch (e) {
      print("Geçmiş çekilirken hata oluştu: $e");
    }
  }

  void loadResultFromHistory(Map<String, dynamic> historyItem) {
    Map<String, String> workerResps = {};
    for (var r in historyItem["model_responses"] ?? []) {
      workerResps[r["model_name"]] = r["response"];
    }
    
    List<String> steps = [];
    for (var l in historyItem["process_logs"] ?? []) {
      steps.add(l["step_description"]);
    }

    _currentResult = {
      "query_id": historyItem["id"],
      "question": historyItem["question"],
      "final_response": historyItem["final_response"],
      "worker_responses": workerResps,
      "logs": steps,
    };
    notifyListeners();
  }
}
