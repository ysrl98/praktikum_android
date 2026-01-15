class UserAnswer {
  const UserAnswer({required this.questionId, required this.answer});

  final int questionId;
  final String answer;

  Map<String, dynamic> toJson() {
    return {'question_id': questionId, 'answer': answer};
  }
}
