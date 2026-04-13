import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:planeta_app/screens/survey_screen.dart';
import 'package:planeta_app/providers/auth_provider.dart';
import 'package:planeta_app/providers/survey_provider.dart';
import 'package:planeta_app/model/survey_model.dart';
import 'package:planeta_app/model/user_entity.dart';

class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  UserEntity? get user => UserEntity(uid: 'test-uid', email: 'test@test.com');
  @override
  bool get isLoading => false;
  @override
  Future<void> login(String email, String password) async {}
  @override
  Future<void> register(String email, String password, String username) async {}
  @override
  Future<void> signOut() async {}
}

class MockSurveyProvider extends ChangeNotifier implements SurveyProvider {
  final double _mockScore;
  final String _mockFeedback;

  MockSurveyProvider({
    double score = 100.0,
    String feedback = "Excellent – You're an environmental champion!",
  })  : _mockScore = score,
        _mockFeedback = feedback;

  @override
  bool get isLoading => false;
  @override
  bool get alreadyFilledToday => false;
  @override
  List<SurveyResult> get surveyHistory => [
        SurveyResult(
          totalScore: _mockScore,
          feedback: _mockFeedback,
          answers: [],
          date: DateTime.now(),
        ),
      ];
  @override
  double get totalPoints => _mockScore;
  @override
  Future<void> completeSurvey(String uid, List<SurveyAnswer> answers) async {}
  @override
  Future<void> loadUserHistory(String uid) async {}
  @override
  Future<void> checkDailyStatus(String uid) async {}
}

Widget buildSurveyScreen({MockSurveyProvider? surveyProvider}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => MockAuthProvider(),
      ),
      ChangeNotifierProvider<SurveyProvider>(
        create: (_) => surveyProvider ?? MockSurveyProvider(),
      ),
    ],
    child: MaterialApp(
      routes: {
        '/home': (context) => Scaffold(body: Text('Home Screen')),
      },
      home: SurveyScreen(),
    ),
  );
}

Future<void> answerAllQuestions(WidgetTester tester) async {
  for (int i = 0; i < 8; i++) {
    final isLikert =
        find.textContaining('Strongly Agree').evaluate().isNotEmpty;
    if (isLikert) {
      await tester.tap(find.textContaining('Strongly Agree').first);
    } else {
      await tester.tap(find.text('Yes ✓').first);
    }
    await tester.pumpAndSettle();
    if (i == 7) {
      await tester.tap(find.widgetWithText(ElevatedButton, 'Submit'));
    } else {
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next Question'));
    }
    await tester.pumpAndSettle();
  }
}

void main() {
  group('SurveyScreen Widget Testleri', () {
    testWidgets('ST-01: Ekran dogru yukleniyor', (tester) async {
      await tester.pumpWidget(buildSurveyScreen());
      expect(find.text('Daily Survey'), findsOneWidget);
      expect(find.text('Question 1 of 8'), findsOneWidget);
      expect(find.text('13%'), findsOneWidget);
    });

    testWidgets('ST-02: Ilk soru Yes/No secenekleri gosteriyor', (tester) async {
      await tester.pumpWidget(buildSurveyScreen());
      expect(find.text('Yes ✓'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });

    testWidgets('ST-03: Cevap secilmeden Next butonu disabled olmali', (tester) async {
      await tester.pumpWidget(buildSurveyScreen());
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next Question'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('ST-04: Cevap secilince Next butonu aktif olmali', (tester) async {
      await tester.pumpWidget(buildSurveyScreen());
      await tester.tap(find.text('Yes ✓'));
      await tester.pump();
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next Question'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('ST-05: Secilen secenek checkmark gostermeli', (tester) async {
      await tester.pumpWidget(buildSurveyScreen());
      await tester.tap(find.text('Yes ✓'));
      await tester.pump();
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('ST-06: Next butonuna basinca soru 2ye gecmeli', (tester) async {
      await tester.pumpWidget(buildSurveyScreen());
      await tester.tap(find.text('Yes ✓'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next Question'));
      await tester.pumpAndSettle();
      expect(find.text('Question 2 of 8'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
    });

    testWidgets('ST-07: Sonraki soruya gecince secim sifirlanmali', (tester) async {
      await tester.pumpWidget(buildSurveyScreen());
      await tester.tap(find.text('Yes ✓'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next Question'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    });

    testWidgets('ST-08: Ilerleme cubugu her soruda artmali', (tester) async {
      await tester.pumpWidget(buildSurveyScreen());
      LinearProgressIndicator bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, closeTo(1 / 8, 0.001));
      await tester.tap(find.text('Yes ✓'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next Question'));
      await tester.pumpAndSettle();
      bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, closeTo(2 / 8, 0.001));
    });

    testWidgets('ST-09: 8. soruda Submit butonu gorunmeli', (tester) async {
      await tester.pumpWidget(buildSurveyScreen());
      for (int i = 0; i < 7; i++) {
        final isLikert =
            find.textContaining('Strongly Agree').evaluate().isNotEmpty;
        if (isLikert) {
          await tester.tap(find.textContaining('Strongly Agree').first);
        } else {
          await tester.tap(find.text('Yes ✓').first);
        }
        await tester.pump();
        await tester.tap(find.widgetWithText(ElevatedButton, 'Next Question'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Question 8 of 8'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Submit'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Next Question'), findsNothing);
    });

    testWidgets('ST-10: Tum sorular cevaplandıgında sonuc dialogu acilmali', (tester) async {
      await tester.pumpWidget(buildSurveyScreen());
      await answerAllQuestions(tester);
      expect(find.text('Survey Complete!'), findsOneWidget);
      expect(find.text('out of 100'), findsOneWidget);
      expect(find.text('Great!'), findsOneWidget);
    });

    testWidgets('ST-11: Sonuc dialogu skoru dogru gostermeli', (tester) async {
      await tester.pumpWidget(buildSurveyScreen(
        surveyProvider: MockSurveyProvider(score: 100.0),
      ));
      await answerAllQuestions(tester);
      expect(find.text('100.0'), findsOneWidget);
      expect(find.textContaining('environmental champion'), findsOneWidget);
    });

    testWidgets('ST-12: Dusuk skor icin dogru feedback gostermeli', (tester) async {
      await tester.pumpWidget(buildSurveyScreen(
        surveyProvider: MockSurveyProvider(
          score: 25.0,
          feedback: 'Needs Improvement – Small changes can make a big difference!',
        ),
      ));
      await answerAllQuestions(tester);
      expect(find.text('25.0'), findsOneWidget);
      expect(find.textContaining('Needs Improvement'), findsOneWidget);
    });

    testWidgets('ST-13: Sonuc dialogu disina tiklanarak kapatilamamali', (tester) async {
      await tester.pumpWidget(buildSurveyScreen());
      await answerAllQuestions(tester);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('Survey Complete!'), findsOneWidget);
    });

    testWidgets('ST-14: Great! butonuna basinca Home ekranina gidilmeli', (tester) async {
      await tester.pumpWidget(buildSurveyScreen());
      await answerAllQuestions(tester);
      await tester.tap(find.text('Great!'));
      await tester.pumpAndSettle();
      expect(find.text('Survey Complete!'), findsNothing);
      expect(find.text('Home Screen'), findsOneWidget);
    });
  });
}