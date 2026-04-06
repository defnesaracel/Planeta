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
  // survey_provider.dart içine eklenecekler

bool _alreadyFilledToday = false;
bool get alreadyFilledToday => _alreadyFilledToday;

// UC: Günlük durumu kontrol et
Future<void> checkDailyStatus(String uid) async {
  try {
    final userDoc = await _db.collection('users').doc(uid).get();
    if (userDoc.exists && userDoc.data()!.containsKey('lastSurveyDate')) {
      Timestamp lastTimestamp = userDoc.data()!['lastSurveyDate'];
      DateTime lastDate = lastTimestamp.toDate();
      DateTime now = DateTime.now();

      _alreadyFilledToday = (lastDate.year == now.year &&
                             lastDate.month == now.month &&
                             lastDate.day == now.day);
      notifyListeners();
    } else {
      _alreadyFilledToday = false;
      notifyListeners();
    }
  } catch (e) {
    debugPrint("Daily status check error: $e");
  }
}

// completeSurvey metodunu Batch Write ile güncelle
Future<void> completeSurvey(String uid, List<SurveyAnswer> answers) async {
  _isLoading = true;
  notifyListeners();

  try {
    final List<SurveyQuestion> questions = _surveyService.getSurveyQuestions();
    final SurveyResult result = _surveyService.buildSurveyResult(
      questions: questions,
      answers: answers,
    );

    // Atomik işlem için Batch kullanıyoruz
    WriteBatch batch = _db.batch();

    // 1. Anketi alt koleksiyona ekle
    DocumentReference surveyRef = _db.collection('users').doc(uid).collection('surveys').doc();
    batch.set(surveyRef, result.toJson());

    // 2. Ana kullanıcı dökümanındaki tarihi güncelle
    DocumentReference userRef = _db.collection('users').doc(uid);
batch.set(
  userRef, 
  {'lastSurveyDate': FieldValue.serverTimestamp()}, 
  SetOptions(merge: true)
);

await batch.commit();

    _surveyHistory.insert(0, result);
    _alreadyFilledToday = true; // Yerel durumu güncelle
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