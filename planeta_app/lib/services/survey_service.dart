import '../model/survey_model.dart';

/// Local-only service that handles survey question data and scoring.
///
/// Firebase integration can be added later without changing model structure.
class SurveyService {
  /// Hardcoded environmental awareness questions.
  ///
  /// All question weights sum to exactly 100.
  static const List<SurveyQuestion> _questions = <SurveyQuestion>[
    SurveyQuestion(
      id: 'q1',
      text: 'Did you use public transportation instead of driving today?',
      type: QuestionType.yesNo,
      weight: 12.5,
    ),
    SurveyQuestion(
      id: 'q2',
      text: 'Did you avoid single-use plastic today?',
      type: QuestionType.yesNo,
      weight: 12.5,
    ),
    SurveyQuestion(
      id: 'q3',
      text: 'My water usage today was conscious and minimal.',
      type: QuestionType.likert,
      weight: 12.5,
    ),
    SurveyQuestion(
      id: 'q4',
      text:
          'I made sure my dishwasher or washing machine (or both) was fully loaded before running it today.',
      type: QuestionType.likert,
      weight: 12.5,
    ),
    SurveyQuestion(
      id: 'q5',
      text: 'I chose plant-based or low-carbon food options today.',
      type: QuestionType.likert,
      weight: 12.5,
    ),
    SurveyQuestion(
      id: 'q6',
      text: 'Did you avoid buying fast fashion or unnecessary products today?',
      type: QuestionType.yesNo,
      weight: 12.5,
    ),
    SurveyQuestion(
      id: 'q7',
      text: 'I made an effort to recycle or sort my waste correctly today.',
      type: QuestionType.likert,
      weight: 12.5,
    ),
    SurveyQuestion(
      id: 'q8',
      text: 'I encouraged someone else to make an eco-friendly choice today.',
      type: QuestionType.likert,
      weight: 12.5,
    ),
  ];

  /// Returns a copy of local survey questions.
  List<SurveyQuestion> getSurveyQuestions() {
    return List<SurveyQuestion>.from(_questions);
  }

  /// Calculates weighted score out of 100 from user answers.
  ///
  /// Rules:
  /// - Yes/No: Yes(1) = full weight, No(0) = 0
  /// - Likert: (value / 4) * weight where value is in range 0..4
  double calculateTotalScore({
    required List<SurveyQuestion> questions,
    required List<SurveyAnswer> answers,
  }) {
    if (questions.isEmpty || answers.isEmpty) {
      return 0;
    }

    final Map<String, SurveyQuestion> questionById = <String, SurveyQuestion>{
      for (final SurveyQuestion question in questions) question.id: question,
    };

    double total = 0;

    for (final SurveyAnswer answer in answers) {
      final SurveyQuestion? question = questionById[answer.questionId];
      if (question == null) {
        continue;
      }

      switch (question.type) {
        case QuestionType.yesNo:
          final int normalized = answer.value.clamp(0, 1);
          total += normalized == 1 ? question.weight : 0;
          break;
        case QuestionType.likert:
          final int normalized = answer.value.clamp(0, 4);
          total += (normalized / 4) * question.weight;
          break;
      }
    }

    // Keep score in the valid range even with unexpected duplicate answers.
    return total.clamp(0, 100).toDouble();
  }

  /// Returns feedback text based on total score.
  String getFeedback(double totalScore) {
    if (totalScore <= 40) {
      return 'Needs Improvement – Small changes can make a big difference!';
    } else if (totalScore <= 60) {
      return "Getting There – You're building good habits.";
    } else if (totalScore <= 80) {
      return "Good Job – You're making a positive impact!";
    } else {
      return "Excellent – You're an environmental champion!";
    }
  }

  /// Packages score, feedback, and answers into [SurveyResult].
  SurveyResult buildSurveyResult({
    required List<SurveyQuestion> questions,
    required List<SurveyAnswer> answers,
  }) {
    final double score = calculateTotalScore(
      questions: questions,
      answers: answers,
    );
    final String feedback = getFeedback(score);

    return SurveyResult(
      totalScore: score,
      feedback: feedback,
      answers: answers,
      date: DateTime.now(),
    );
  }
}
