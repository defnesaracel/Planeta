import 'package:flutter/material.dart';
import 'package:planeta_app/model/survey_model.dart';
import 'package:planeta_app/services/survey_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Tarih formatı için
import '../../providers/survey_provider.dart';
import '../../providers/auth_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // ── UC4: Sayfa açıldığında geçmişi yükle ──
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = Provider.of<AuthProvider>(context, listen: false).user?.uid;
      if (uid != null) {
        Provider.of<SurveyProvider>(context, listen: false).loadUserHistory(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF4EE),
      appBar: AppBar(
        title: const Text("My Achievements", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
    
      body: Consumer<SurveyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.surveyHistory.isEmpty) {
            return const Center(child: Text("No surveys yet. Start your journey!"));

          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Özet Kartı (Toplam Puan) ──
                _buildTotalScoreCard(provider.totalPoints),
                const SizedBox(height: 25),
                
                // ── Rozetler (Badge System) ──
                const Text("Your Badges", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildBadgeRow(provider.totalPoints),
                const SizedBox(height: 25),

                // ── Geçmiş Listesi ──
                const Text("Previous Surveys", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.surveyHistory.length,
                  itemBuilder: (context, index) {
                    final entry = provider.surveyHistory[index];
                    return _buildHistoryItem(entry);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget metodları (Temizlik ve Modülerlik için) ...
  Widget _buildTotalScoreCard(double points) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D6A4F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Lifetime Score", style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text("Sustainability Rank", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          Text(
            points.toStringAsFixed(0),
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  
    Widget _buildHistoryItem(SurveyResult entry) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      onTap: () => _showSurveyDetails(context, entry), // <── Tıklandığında detayları açar
      leading: const CircleAvatar(backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.description, color: Colors.green)),
      title: Text(DateFormat('MMMM dd, yyyy').format(entry.date)),
      subtitle: Text("Score: ${entry.totalScore.toInt()}"),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}
  }

  Widget _buildBadgeRow(double totalPoints) {
    // Örnek Award Logic [cite: 138]
    return Row(
      children: [
        _badgeIcon(Icons.spa, "Beginner", totalPoints>200),
        _badgeIcon(Icons.bolt, "Warrior", totalPoints > 400),
        _badgeIcon(Icons.public, "Protector", totalPoints > 600),
      ],
    );
  }

  Widget _badgeIcon(IconData icon, String label, bool unlocked) {
    return Opacity(
      opacity: unlocked ? 1.0 : 0.2,
      child: Padding(
        padding: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            CircleAvatar(backgroundColor: Colors.white, child: Icon(icon, color: Colors.green)),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
  
void _showSurveyDetails(BuildContext context, SurveyResult result) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            // Ekranın %70'inden fazla yer kaplamasın
            maxHeight: MediaQuery.of(context).size.height * 0.7, 
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık Alanı
              const Text(
                "Survey Analysis",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
              ),
              const SizedBox(height: 10),
              Text(
                "Score: ${result.totalScore.toInt()} / 100",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Divider(height: 30),
              
              // Kaydırılabilir Cevap Listesi
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: result.answers.length,
                  itemBuilder: (context, index) {
                    final answer = result.answers[index];
                    final question = SurveyService()
                        .getSurveyQuestions()
                        .firstWhere((q) => q.id == answer.questionId);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(question.text, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            "Your Answer: ${_getAnswerText(question, answer.value)}",
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              
              // Kapat Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Close", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
// HistoryScreenState içinde bir fonksiyon:


// Cevap sayılarını (0, 1, 2...) anlamlı metne döken yardımcı fonksiyon
String _getAnswerText(SurveyQuestion q, int val) {
  if (q.type == QuestionType.yesNo) return val == 1 ? "Yes" : "No";
  switch (val) {
    case 4: return "Strongly Agree";
    case 3: return "Agree";
    case 2: return "Neutral";
    case 1: return "Disagree";
    default: return "Strongly Disagree";
  }
}