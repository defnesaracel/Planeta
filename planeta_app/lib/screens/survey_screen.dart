import 'package:flutter/material.dart';
import 'package:planeta_app/providers/auth_provider.dart';
import 'package:planeta_app/providers/survey_provider.dart';
import 'package:provider/provider.dart';
import '../model/survey_model.dart';
import '../services/survey_service.dart';
import 'package:planeta_app/screens/home_screen.dart';
class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen>
    with SingleTickerProviderStateMixin {
  final SurveyService _surveyService = SurveyService();
  late List<SurveyQuestion> _questions;
  final List<SurveyAnswer> _userAnswers = [];

  int _currentIndex = 0;
  int? _tempSelectedValue;

  // Animation controller for question transitions
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ----- Palette -----
  static const Color _bgColor = Color(0xFFEFF4EE);
  static const Color _cardColor = Colors.white;
  static const Color _primaryGreen = Color(0xFF2D6A4F);
  static const Color _darkGreen = Color(0xFF1B5E20);
  static const Color _lightGreen = Color(0xFFE8F5E9);
  static const Color _progressTrack = Color(0xFFD0E8D5);
  static const Color _textSecondary = Color(0xFF7A8C82);
  
  

  @override
  void initState() {


    super.initState();
   
    _questions = _surveyService.getSurveyQuestions();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onNextPressed() async {
    
    if (_tempSelectedValue == null) return;

    _userAnswers.add(
      SurveyAnswer(
        questionId: _questions[_currentIndex].id,
        value: _tempSelectedValue!,
        timestamp: DateTime.now(),
      ),
    );

    if (_currentIndex < _questions.length - 1) {
      _animController.reset();
      setState(() {
        _currentIndex++;
        _tempSelectedValue = null;
      });
      _animController.forward();
    } else {
     final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final uid = authProvider.user?.uid;

      if (uid != null) {
        // 2. SurveyProvider'ı çağır ve anketi kaydet [cite: 224]
        final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
        
        try {
          // Bu metod hem puanı hesaplar hem de Firebase'e kaydeder
          await surveyProvider.completeSurvey(uid, _userAnswers);
          
          // 3. Sonuç ekranını göster (Provider içindeki hesaplanmış sonucu kullanıyoruz)
          if (mounted) {
            _showResultDialog(surveyProvider.surveyHistory.first);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error saving survey: $e")),
            );
          }
        }
      }
    }
  }
// ...
    
  

  void _showResultDialog(SurveyResult result) {
    final Color scoreColor = result.totalScore >= 80
        ? _darkGreen
        : result.totalScore >= 60
        ? const Color(0xFF388E3C)
        : result.totalScore >= 40
        ? const Color(0xFFF57F17)
        : const Color(0xFFB71C1C);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Leaf icon badge
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: _primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.eco_rounded, color: Colors.white, size: 34),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Survey Complete!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _primaryGreen,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                result.totalScore.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: scoreColor,
                  height: 1,
                ),
              ),
              const Text(
                'out of 100',
                style: TextStyle(
                  fontSize: 14,
                  color: _textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  result.feedback,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: _darkGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                 onPressed: () {
  // 1. Dismiss the Dialog
  Navigator.pop(context); 

  // 2. Navigate to Home and clear the survey from the stack
  Navigator.pushNamedAndRemoveUntil(
    context, 
    '/home', 
    (route) => false, 
  );
},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Great!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentIndex];
    final double progress = (_currentIndex + 1) / _questions.length;
    final int progressPercent = ((progress) * 100).round();

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              _buildHeader(),
              const SizedBox(height: 20),

              // ── Progress Section ──
              _buildProgressSection(progress, progressPercent),
              const SizedBox(height: 20),

              // ── Question Card ──
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: _buildQuestionCard(currentQuestion),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Motivational tagline ──
              Center(
                child: Text(
                  'Your daily actions make a difference 🌍',
                  style: TextStyle(
                    fontSize: 13,
                    color: _textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Next Button ──
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header: leaf logo + title ──────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        // Leaf logo circle
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: _primaryGreen,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              'assets/leaf_image.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.eco_rounded, color: Colors.white, size: 22),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Daily Survey',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _primaryGreen,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  // ── Progress bar + label ────────────────────────────────────────────────────
  Widget _buildProgressSection(double progress, int progressPercent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${_currentIndex + 1} of ${_questions.length}',
              style: const TextStyle(
                fontSize: 13,
                color: _textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$progressPercent%',
              style: const TextStyle(
                fontSize: 13,
                color: _primaryGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: _progressTrack,
            valueColor: const AlwaysStoppedAnimation<Color>(_primaryGreen),
          ),
        ),
      ],
    );
  }

  // ── Question Card ───────────────────────────────────────────────────────────
  Widget _buildQuestionCard(SurveyQuestion question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _primaryGreen,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            if (question.type == QuestionType.yesNo)
              _buildYesNoOptions()
            else
              _buildLikertOptions(),
          ],
        ),
      ),
    );
  }

  // ── Yes / No ────────────────────────────────────────────────────────────────
  Widget _buildYesNoOptions() {
    return Column(
      children: [
        _buildOptionTile('Yes ✓', 1),
        const SizedBox(height: 12),
        _buildOptionTile('No', 0),
      ],
    );
  }

  // ── Likert Scale ────────────────────────────────────────────────────────────
  Widget _buildLikertOptions() {
    return Column(
      children: [
        for (int i = 4; i >= 0; i--)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildOptionTile(_getLikertLabel(i), i),
          ),
      ],
    );
  }

  String _getLikertLabel(int value) {
    switch (value) {
      case 4:
        return 'Strongly Agree / Always';
      case 3:
        return 'Agree';
      case 2:
        return 'Neutral';
      case 1:
        return 'Disagree';
      default:
        return 'Strongly Disagree / Never';
    }
  }

  // ── Option Tile ─────────────────────────────────────────────────────────────
  Widget _buildOptionTile(String text, int value) {
    final bool isSelected = _tempSelectedValue == value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _tempSelectedValue = value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? _darkGreen : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              color: isSelected ? _lightGreen : Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      color: isSelected ? _darkGreen : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: _darkGreen,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Next Button ─────────────────────────────────────────────────────────────
  Widget _buildNextButton() {
    final bool isLast = _currentIndex == _questions.length - 1;
    final bool isEnabled = _tempSelectedValue != null;

    return AnimatedOpacity(
      opacity: isEnabled ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isEnabled ? _onNextPressed : null,
          icon: Icon(
            isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
            size: 20,
          ),
          label: Text(
            isLast ? 'Submit' : 'Next Question',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryGreen,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade500,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: isEnabled ? 2 : 0,
          ),
        ),
      ),
    );
  }
}
