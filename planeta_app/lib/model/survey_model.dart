/// Defines the supported survey question types.
enum QuestionType {
  /// Binary question (No = 0, Yes = 1).
  yesNo,

  /// 5-point Likert scale question (0..4).
  likert,
}

/// Helper extension for serializing/deserializing [QuestionType].
extension QuestionTypeX on QuestionType {
  /// Converts enum value to a JSON-safe string.
  String toJsonValue() => name;

  /// Parses enum value from a JSON string.
  static QuestionType fromJsonValue(String value) {
    return QuestionType.values.firstWhere(
      (QuestionType type) => type.name == value,
      orElse: () => QuestionType.likert,
    );
  }
}

/// Represents a single survey question with its score weight.
class SurveyQuestion {
  /// Creates a survey question.
  const SurveyQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.weight,
  });

  /// Unique question identifier.
  final String id;

  /// Question text shown to the user.
  final String text;

  /// Type of the question that defines allowed input values.
  final QuestionType type;

  /// Weighted contribution of this question out of 100.
  final double weight;

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'type': type.toJsonValue(),
      'weight': weight,
    };
  }

  /// Builds a [SurveyQuestion] model from JSON.
  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    return SurveyQuestion(
      id: json['id'] as String,
      text: json['text'] as String,
      type: QuestionTypeX.fromJsonValue(json['type'] as String),
      weight: (json['weight'] as num).toDouble(),
    );
  }
}

/// Represents one user answer entry.
class SurveyAnswer {
  /// Creates a user answer.
  const SurveyAnswer({
    required this.questionId,
    required this.value,
    required this.timestamp,
  });

  /// Associated question id.
  final String questionId;

  /// Numeric answer value based on question type.
  ///
  /// - Yes/No: No = 0, Yes = 1
  /// - Likert: 0..4
  final int value;

  /// Date and time when this answer was submitted.
  final DateTime timestamp;

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'questionId': questionId,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Builds a [SurveyAnswer] model from JSON.
  factory SurveyAnswer.fromJson(Map<String, dynamic> json) {
    return SurveyAnswer(
      questionId: json['questionId'] as String,
      value: json['value'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Represents the final survey output.
class SurveyResult {
  /// Creates a survey result object.
  const SurveyResult({
    required this.totalScore,
    required this.feedback,
    required this.answers,
    required this.date,
  });

  /// Final calculated score in range 0..100.
  final double totalScore;

  /// Text feedback generated from score range.
  final String feedback;

  /// Answers included in this result.
  final List<SurveyAnswer> answers;

  /// Date and time when result was generated.
  final DateTime date;

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'totalScore': totalScore,
      'feedback': feedback,
      'answers': answers.map((SurveyAnswer answer) => answer.toJson()).toList(),
      'date': date.toIso8601String(),
    };
  }

  /// Builds a [SurveyResult] model from JSON.
  factory SurveyResult.fromJson(Map<String, dynamic> json) {
    return SurveyResult(
      totalScore: (json['totalScore'] as num).toDouble(),
      feedback: json['feedback'] as String,
      answers: (json['answers'] as List<dynamic>)
          .map(
            (dynamic item) =>
                SurveyAnswer.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}
