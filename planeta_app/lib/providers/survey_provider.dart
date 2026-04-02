import 'package:flutter/material.dart';
import '../model/survey_model.dart';
import '../services/survey_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SurveyProvider with ChangeNotifier {
  // Singleton olan servisimize erişiyoruz [cite: 56]
  final SurveyService _surveyService = SurveyService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<SurveyResult> _surveyHistory = [];
  bool _isLoading = false;

  // UI'ın bu verilere erişmesi için getter'lar
  List<SurveyResult> get surveyHistory => _surveyHistory;
  bool get isLoading => _isLoading;

  // Dökümandaki "Award Logic": Tüm anketlerin toplam puanı [cite: 134-138]
  double get totalPoints => _surveyHistory.fold(0, (sum, item) => sum + item.totalScore);

  // --- UC3: Anket Tamamlama ve Kaydetme ---
  Future<void> completeSurvey(String uid, List<SurveyAnswer> answers) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Servis aracılığıyla puanı hesapla ve sonucu paketle [cite: 165-166]
      final List<SurveyQuestion> questions = _surveyService.getSurveyQuestions();
      final SurveyResult result = _surveyService.buildSurveyResult(
        questions: questions,
        answers: answers,
      );

      // 2. Firestore'a NoSQL dökümanı olarak kaydet [cite: 145-147, 225]
      // Yol: users/{uid}/surveys/
      await _db
          .collection('users')
          .doc(uid)
          .collection('surveys')
          .add(result.toJson());

      // 3. Yerel listeyi güncelle ki History ekranında anında gözüksün [cite: 230]
      _surveyHistory.insert(0, result);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- UC4: Geçmişi Yükleme ---
  Future<void> loadUserHistory(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Firestore'dan tarih sırasına göre çekiyoruz [cite: 170, 237]
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('surveys')
          .orderBy('date', descending: true)
          .get();

      // Ham NoSQL verisini SurveyResult modellerine dönüştür [cite: 236]
      _surveyHistory = snapshot.docs
          .map((doc) => SurveyResult.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print("Geçmiş yükleme hatası: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}