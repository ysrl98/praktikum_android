class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.text,
    required this.answers,
  });

  final int id;
  final String text;
  final List<String> answers;

  List<String> getShuffledAnswers() {
    final shuffledList = List.of(answers);
    shuffledList.shuffle();
    return shuffledList;
  }
}
