import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/answer_button.dart';
import 'package:quiz_app/models/quiz_question.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({
    super.key,
    required this.onSelectedAnswer,
    required this.questions,
  });

  // Update tipe fungsi callback untuk menerima ID dan Jawaban
  final void Function(int questionId, String answer) onSelectedAnswer;
  final List<QuizQuestion> questions;

  @override
  State<QuestionsScreen> createState() {
    return _QuestionsScreenState();
  }
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  var currentQuestionIndex = 0;

  void answerQuestion(String selectedAnswer) {
    // Mengirimkan ID soal saat ini dan jawaban yang dipilih
    widget.onSelectedAnswer(
      widget.questions[currentQuestionIndex].id,
      selectedAnswer,
    );

    setState(() {
      currentQuestionIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mencegah error index out of range jika data belum siap
    if (widget.questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentQuestion = widget.questions[currentQuestionIndex];

    return SizedBox(
      width: double.infinity,
      child: Container(
        margin: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              currentQuestion.text,
              style: GoogleFonts.lato(
                color: const Color.fromARGB(255, 215, 196, 249),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ...currentQuestion.getShuffledAnswers().map((item) {
              return Container(
                margin: const EdgeInsets.all(5),
                child: AnswerButton(
                  text: item,
                  onTap: () {
                    answerQuestion(item);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
