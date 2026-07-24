import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/api_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApiProvider>(context, listen: false).fetchHistory();
    });
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat("dd/MM/yyyy HH:mm").format(date);
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiProvider = Provider.of<ApiProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text("Sorgu Geçmişi"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleTextStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      body: RefreshIndicator(
        onRefresh: () => apiProvider.fetchHistory(),
        color: const Color(0xFFC61F1B),
        child: apiProvider.history.isEmpty
            ? _buildEmptyState()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: apiProvider.history.length,
                  itemBuilder: (context, index) {
                    final item = apiProvider.history[index];
                    final question = item["question"] ?? "";
                    final response = item["final_response"] ?? "";
                    final dateStr = item["created_at"] ?? "";
                    final modelsCount = (item["model_responses"] as List?)?.length ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.black.withOpacity(0.06)),
                      ),
                      elevation: 2,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDate(dateStr),
                                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC61F1B).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "$modelsCount Model",
                                    style: const TextStyle(color: Color(0xFFC61F1B), fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              question,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              response,
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    apiProvider.loadResultFromHistory(item);
                                    Navigator.pushReplacementNamed(context, '/');
                                  },
                                  icon: const Icon(Icons.open_in_new, size: 18),
                                  label: const Text("Detayları Yükle"),
                                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFC61F1B)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Icon(Icons.history, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 16),
        const Text(
          "Henüz geçmiş sorgu bulunmuyor",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            "Sorduğunuz sorular ve alınan model cevapları otomatik olarak burada listelenecektir.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }
}
