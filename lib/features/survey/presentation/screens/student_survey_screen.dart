import 'package:flutter/material.dart';

import '../../../../component/layout/responsive_layout.dart';
import '../../domain/entities/submit_survey_params.dart';
import '../../domain/failures/survey_failure.dart';
import '../../domain/usecases/submit_survey_use_case.dart';

class StudentSurveyScreen extends StatefulWidget {
  const StudentSurveyScreen({
    super.key,
    required this.submitSurveyUseCase,
    required this.onCompleted,
  });

  final SubmitSurveyUseCase submitSurveyUseCase;
  final VoidCallback onCompleted;

  @override
  State<StudentSurveyScreen> createState() => _StudentSurveyScreenState();
}

class _StudentSurveyScreenState extends State<StudentSurveyScreen> {
  static const List<String> _mbtiTypes = <String>[
    'INTJ',
    'INTP',
    'ENTJ',
    'ENTP',
    'INFJ',
    'INFP',
    'ENFJ',
    'ENFP',
    'ISTJ',
    'ISFJ',
    'ESTJ',
    'ESFJ',
    'ISTP',
    'ISFP',
    'ESTP',
    'ESFP',
  ];

  final TextEditingController _personalityController = TextEditingController();
  final TextEditingController _preferenceController = TextEditingController();

  String? _selectedMbti;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _canSubmit {
    return _selectedMbti != null &&
        _personalityController.text.trim().isNotEmpty &&
        _preferenceController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _personalityController.dispose();
    _preferenceController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage == null) {
      return;
    }

    setState(() {
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    if (!_canSubmit || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.submitSurveyUseCase(
        SubmitSurveyParams(
          mbti: _selectedMbti!,
          personality: _personalityController.text,
          preference: _preferenceController.text,
        ),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('설문이 저장되었습니다.')));
      widget.onCompleted();
    } on SurveyFailure catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = '설문 제출 중 문제가 발생했습니다. 다시 시도해주세요.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveLayout.of(context) == ResponsiveSize.mobile;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 18 : 24,
            vertical: isMobile ? 26 : 36,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 660),
              child: Column(
                children: [
                  _SurveyIntro(isMobile: isMobile),
                  SizedBox(height: isMobile ? 26 : 32),
                  _SurveyCardShell(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionBadge(label: 'STUDENT SURVEY'),
                        const SizedBox(height: 22),
                        const Text(
                          '모둠 활동 성향을 알려주세요',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            color: Color(0xFF1F2743),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '작성한 내용은 모둠 활동을 더 잘 맞추는 데 사용됩니다.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.7,
                            color: Color(0xFF7B88A8),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const _SectionTitle(
                          title: 'MBTI',
                          description: '가장 가까운 유형을 선택해 주세요.',
                        ),
                        const SizedBox(height: 14),
                        _MbtiChoiceGrid(
                          types: _mbtiTypes,
                          selectedType: _selectedMbti,
                          onSelected: (String type) {
                            _clearError();
                            setState(() {
                              _selectedMbti = type;
                            });
                          },
                        ),
                        const SizedBox(height: 30),
                        _SurveyTextArea(
                          label: '성격',
                          hintText: '예: 계획적으로 움직이는 편이고 역할이 분명한 협업을 선호합니다.',
                          controller: _personalityController,
                          enabled: !_isSubmitting,
                          onChanged: (_) {
                            _clearError();
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 22),
                        _SurveyTextArea(
                          label: '협업 선호 방식',
                          hintText: '예: 정리된 문서 협업과 일정 기반 진행을 선호합니다.',
                          controller: _preferenceController,
                          enabled: !_isSubmitting,
                          onChanged: (_) {
                            _clearError();
                            setState(() {});
                          },
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFD14D4D),
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _canSubmit && !_isSubmitting
                                ? _submit
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6281F0),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFFD9E0F2),
                              disabledForegroundColor: const Color(0xFF8F9BB7),
                              elevation: 0,
                              minimumSize: const Size.fromHeight(58),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    '설문 제출',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SurveyIntro extends StatelessWidget {
  const _SurveyIntro({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/modus_text_logo.png',
          width: isMobile ? 170 : 210,
          fit: BoxFit.contain,
        ),
        SizedBox(height: isMobile ? 24 : 28),
        Text(
          'MODUS SURVEY',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 12 : 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 5,
            color: const Color(0xFF8BA2FF),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Before Class',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 42 : 56,
            fontWeight: FontWeight.w800,
            height: 1.05,
            color: const Color(0xFF1F2743),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '첫 수업 전에 협업 성향을 남겨주세요.\n모둠 활동을 준비하는 데 활용됩니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w600,
            height: 1.7,
            color: const Color(0xFF7B88A8),
          ),
        ),
      ],
    );
  }
}

class _SurveyCardShell extends StatelessWidget {
  const _SurveyCardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ResponsiveSize screenSize = ResponsiveLayout.of(context);
    final double horizontalPadding = screenSize == ResponsiveSize.mobile
        ? 18
        : 30;
    final double verticalPadding = screenSize == ResponsiveSize.mobile
        ? 20
        : 30;
    final double radius = screenSize == ResponsiveSize.mobile ? 30 : 38;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x183E5FC6),
            blurRadius: 36,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionBadge extends StatelessWidget {
  const _SectionBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.4,
          color: Color(0xFF6281F0),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2743),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8F9BB7),
          ),
        ),
      ],
    );
  }
}

class _MbtiChoiceGrid extends StatelessWidget {
  const _MbtiChoiceGrid({
    required this.types,
    required this.selectedType,
    required this.onSelected,
  });

  final List<String> types;
  final String? selectedType;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final String type in types)
          ChoiceChip(
            label: SizedBox(
              width: 52,
              child: Text(
                type,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: selectedType == type
                      ? Colors.white
                      : const Color(0xFF1F2743),
                ),
              ),
            ),
            selected: selectedType == type,
            showCheckmark: false,
            selectedColor: const Color(0xFF6281F0),
            backgroundColor: const Color(0xFFF2F5FC),
            side: BorderSide(
              color: selectedType == type
                  ? const Color(0xFF6281F0)
                  : const Color(0xFFE1E7F4),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            onSelected: (_) => onSelected(type),
          ),
      ],
    );
  }
}

class _SurveyTextArea extends StatelessWidget {
  const _SurveyTextArea({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2743),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.multiline,
          minLines: 4,
          maxLines: 7,
          textInputAction: TextInputAction.newline,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFFF2F5FC),
            alignLabelWithHint: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            hintStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: Color(0xFF96A2BD),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(26),
              borderSide: const BorderSide(color: Color(0xFFE1E7F4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(26),
              borderSide: const BorderSide(color: Color(0xFFE1E7F4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(26),
              borderSide: const BorderSide(
                color: Color(0xFF6C84F1),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
