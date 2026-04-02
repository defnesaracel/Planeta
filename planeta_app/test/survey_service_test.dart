import 'package:flutter_test/flutter_test.dart';
import 'package:planeta_app/model/survey_model.dart';
import 'package:planeta_app/services/survey_service.dart';

void main() {
  group('SurveyService', () {
    late SurveyService service;

    setUp(() {
      service = SurveyService();
    });

    test('getSurveyQuestions returns 8 questions', () {
      final List<SurveyQuestion> questions = service.getSurveyQuestions();
      expect(questions, hasLength(8));
    });

    test('all question weights sum to exactly 100', () {
      final List<SurveyQuestion> questions = service.getSurveyQuestions();
      final double sum = questions.fold<double>(
        0,
        (double acc, SurveyQuestion q) => acc + q.weight,
      );
      expect(sum, equals(100.0));
    });

    test('Yes/No: Yes scores full weight, No scores 0', () {
      const List<SurveyQuestion> questions = <SurveyQuestion>[
        SurveyQuestion(
          id: 'yn1',
          text: 'Test yes/no',
          type: QuestionType.yesNo,
          weight: 40,
        ),
      ];
      final DateTime ts = DateTime.utc(2026, 3, 30);

      final double yesScore = service.calculateTotalScore(
        questions: questions,
        answers: <SurveyAnswer>[
          SurveyAnswer(questionId: 'yn1', value: 1, timestamp: ts),
        ],
      );
      expect(yesScore, equals(40.0));

      final double noScore = service.calculateTotalScore(
        questions: questions,
        answers: <SurveyAnswer>[
          SurveyAnswer(questionId: 'yn1', value: 0, timestamp: ts),
        ],
      );
      expect(noScore, equals(0.0));
    });

    test(
      'Likert: value 4 full weight, 0 zero, 2 half weight (relative to weight)',
      () {
        const List<SurveyQuestion> questions = <SurveyQuestion>[
          SurveyQuestion(
            id: 'lk1',
            text: 'Test likert',
            type: QuestionType.likert,
            weight: 24,
          ),
        ];
        final DateTime ts = DateTime.utc(2026, 3, 30);

        expect(
          service.calculateTotalScore(
            questions: questions,
            answers: <SurveyAnswer>[
              SurveyAnswer(questionId: 'lk1', value: 4, timestamp: ts),
            ],
          ),
          equals(24.0),
        );
        expect(
          service.calculateTotalScore(
            questions: questions,
            answers: <SurveyAnswer>[
              SurveyAnswer(questionId: 'lk1', value: 0, timestamp: ts),
            ],
          ),
          equals(0.0),
        );
        expect(
          service.calculateTotalScore(
            questions: questions,
            answers: <SurveyAnswer>[
              SurveyAnswer(questionId: 'lk1', value: 2, timestamp: ts),
            ],
          ),
          equals(12.0),
        );
      },
    );

    test('getFeedback returns correct string for scores 20, 50, 70, 90', () {
      // Separator matches [SurveyService.getFeedback] (Unicode en dash U+2013).
      expect(
        service.getFeedback(20),
        equals(
          'Needs Improvement – Small changes can make a big difference!',
        ),
      );
      expect(
        service.getFeedback(50),
        equals("Getting There – You're building good habits."),
      );
      expect(
        service.getFeedback(70),
        equals("Good Job – You're making a positive impact!"),
      );
      expect(
        service.getFeedback(90),
        equals("Excellent – You're an environmental champion!"),
      );
    });

    test('buildSurveyResult returns valid SurveyResult with score and feedback',
        () {
      const List<SurveyQuestion> questions = <SurveyQuestion>[
        SurveyQuestion(
          id: 'a',
          text: 'Q1',
          type: QuestionType.yesNo,
          weight: 50,
        ),
        SurveyQuestion(
          id: 'b',
          text: 'Q2',
          type: QuestionType.likert,
          weight: 50,
        ),
      ];
      final DateTime ts = DateTime.utc(2026, 3, 30, 12);
      final List<SurveyAnswer> answers = <SurveyAnswer>[
        SurveyAnswer(questionId: 'a', value: 1, timestamp: ts),
        SurveyAnswer(questionId: 'b', value: 4, timestamp: ts),
      ];

      final SurveyResult result = service.buildSurveyResult(
        questions: questions,
        answers: answers,
      );

      expect(result.totalScore, equals(100.0));
      expect(
        result.feedback,
        equals("Excellent – You're an environmental champion!"),
      );
      expect(result.answers, equals(answers));
      expect(result.date.isBefore(DateTime.now().add(const Duration(seconds: 5))),
          isTrue);
    });
  });

  group('Survey models JSON', () {
    test('SurveyQuestion round-trip', () {
      const SurveyQuestion q = SurveyQuestion(
        id: 'x',
        text: 'Hello',
        type: QuestionType.likert,
        weight: 12.5,
      );
      final SurveyQuestion restored = SurveyQuestion.fromJson(q.toJson());
      expect(restored.id, q.id);
      expect(restored.text, q.text);
      expect(restored.type, q.type);
      expect(restored.weight, q.weight);
    });

    test('SurveyAnswer round-trip', () {
      final DateTime ts = DateTime.utc(2026, 1, 2, 3, 4, 5);
      final SurveyAnswer a = SurveyAnswer(
        questionId: 'q1',
        value: 3,
        timestamp: ts,
      );
      final SurveyAnswer restored = SurveyAnswer.fromJson(a.toJson());
      expect(restored.questionId, a.questionId);
      expect(restored.value, a.value);
      expect(restored.timestamp, a.timestamp);
    });

    test('SurveyResult round-trip', () {
      final DateTime ts = DateTime.utc(2026, 6, 15);
      final SurveyResult r = SurveyResult(
        totalScore: 42.5,
        feedback: 'ok',
        answers: <SurveyAnswer>[
          SurveyAnswer(questionId: 'q', value: 1, timestamp: ts),
        ],
        date: ts,
      );
      final SurveyResult restored = SurveyResult.fromJson(r.toJson());
      expect(restored.totalScore, r.totalScore);
      expect(restored.feedback, r.feedback);
      expect(restored.answers.length, r.answers.length);
      expect(restored.answers.first.questionId, r.answers.first.questionId);
      expect(restored.date, r.date);
    });
  });
}
