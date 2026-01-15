import 'package:flutter/material.dart';
import 'package:quiz_app/models/quiz_question.dart';
import 'package:quiz_app/models/user_answer.dart'; // Import model
import 'package:quiz_app/question_summary.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.chosenAnswers,
    required this.onRestart,
    required this.questions,
  });

  final List<UserAnswer> chosenAnswers; // Tipe data berubah
  final void Function() onRestart;
  final List<QuizQuestion> questions;

  List<Map<String, Object>> getSummaryData() {
    final List<Map<String, Object>> summary = [];

    for (var i = 0; i < chosenAnswers.length; i++) {
      // Cari pertanyaan yang sesuai dengan ID di jawaban user (untuk keamanan, meski urutan index biasanya sama)
      final question = questions.firstWhere(
        (q) => q.id == chosenAnswers[i].questionId,
        orElse: () => questions[i],
      );

      summary.add({
        'question_index': i,
        'question': question.text,
        'correct_answer': question
            .answers[0], // Jawaban benar selalu index 0 (karena API sort)
        'user_answer': chosenAnswers[i].answer,
      });
    }
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    final summaryData = getSummaryData();
    final numTotalQuestions = questions.length;
    final numCorrectQuestions = summaryData.where((data) {
      return data['user_answer'] == data['correct_answer'];
    }).length;

    return SizedBox(
      width: double.infinity,
      child: Container(
        margin: const EdgeInsets.all(40),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'You Answered $numCorrectQuestions out of $numTotalQuestions correctly !',
                style: const TextStyle(color: Colors.white, fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              QuestionsSummary(summaryData),
              const SizedBox(height: 30),
              TextButton(
                onPressed: onRestart,
                child: const Text(
                  'Restart Quiz',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
