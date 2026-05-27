class AnswerEvaluation {
  final String questionText;
  final int maxMarks;
  final int scoredMarks;
  final List<String> missingPoints;
  final String howToGetFullMarks;
  final String overallFeedback;

  AnswerEvaluation({
    required this.questionText,
    required this.maxMarks,
    required this.scoredMarks,
    required this.missingPoints,
    required this.howToGetFullMarks,
    required this.overallFeedback,
  });

  double get scorePercent => (scoredMarks / maxMarks).clamp(0.0, 1.0);

  String get grade {
    final p = scorePercent;
    if (p >= 0.9) return 'Excellent';
    if (p >= 0.7) return 'Good';
    if (p >= 0.5) return 'Average';
    return 'Needs Work';
  }
}