import 'package:flutter/material.dart';
import 'package:quiz_app/home_screen.dart';
import 'package:quiz_app/profile.dart';
import 'package:quiz_app/question_screen.dart';
import 'package:quiz_app/result_screen.dart';
import 'package:quiz_app/services/question_api_service.dart';
import 'package:quiz_app/models/quiz_question.dart';
import 'package:quiz_app/models/user_answer.dart'; // Import model baru

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() {
    return _QuizState();
  }
}

class _QuizState extends State<Quiz> {
  var activeScreen = 'start-screen';
  List<UserAnswer> selectedAnswers = []; // Ubah tipe data menjadi UserAnswer
  List<QuizQuestion> questions = [];
  bool isLoading = false;
  bool isSubmitting = false; // State untuk proses submit
  String? errorMessage;

  // Fungsi chooseAnswer sekarang async karena melakukan submit ke API
  Future<void> chooseAnswer(int questionId, String answer) async {
    selectedAnswers.add(UserAnswer(questionId: questionId, answer: answer));

    if (selectedAnswers.length == questions.length) {
      setState(() {
        isSubmitting = true; // Tampilkan loading saat submit
      });

      try {
        final apiService = QuestionApiService();
        // Konversi List<UserAnswer> ke List<Map> untuk dikirim via JSON
        final answersJson = selectedAnswers.map((a) => a.toJson()).toList();

        await apiService.submitAnswers(answersJson);

        // Jika sukses, pindah ke layar hasil
        setState(() {
          activeScreen = 'result-screen';
          isSubmitting = false;
        });
      } catch (e) {
        // Jika gagal, tetap tampilkan hasil tapi log error (atau tampilkan snackbar)
        print('Failed to submit answers: $e');
        setState(() {
          activeScreen = 'result-screen';
          isSubmitting = false;
        });
      }
    }
  }

  Future<void> switchScreen() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final apiService = QuestionApiService();
      final fetchedQuestions = await apiService.fetchQuestions();

      setState(() {
        questions = fetchedQuestions;
        activeScreen = 'questions-screen';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load questions: $e';
        isLoading = false;
      });
    }
  }

  Future<void> restartQuiz() async {
    setState(() {
      selectedAnswers = [];
      isLoading = true;
      errorMessage = null;
    });

    try {
      final apiService = QuestionApiService();
      final fetchedQuestions = await apiService.fetchQuestions();

      setState(() {
        questions = fetchedQuestions;
        activeScreen = 'questions-screen';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load questions: $e';
        isLoading = false;
      });
    }
  }

  void profileScreen() {
    setState(() {
      selectedAnswers = [];
      activeScreen = 'profile-screen';
    });
  }

  @override
  Widget build(context) {
    Widget screenWidget;

    if (isLoading || isSubmitting) {
      // Handle loading saat fetch atau submit
      final loadingText = isSubmitting
          ? 'Submitting answers...'
          : 'Loading questions...';
      screenWidget = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text(loadingText, style: const TextStyle(color: Colors.white)),
          ],
        ),
      );
    } else if (errorMessage != null) {
      screenWidget = Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    errorMessage = null;
                    activeScreen = 'start-screen'; // Kembali ke awal jika error
                  });
                },
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    } else {
      screenWidget = HomeScreen(
        startQuiz: switchScreen,
        profile: profileScreen,
      );
    }

    if (!isLoading && !isSubmitting && errorMessage == null) {
      if (activeScreen == 'questions-screen') {
        screenWidget = QuestionsScreen(
          onSelectedAnswer: chooseAnswer,
          questions: questions,
        );
      }

      if (activeScreen == 'result-screen') {
        screenWidget = ResultScreen(
          chosenAnswers: selectedAnswers,
          onRestart: restartQuiz,
          questions: questions,
        );
      }

      if (activeScreen == 'profile-screen') {
        screenWidget = const Profile();
      }
    }

    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: screenWidget,
        ),
      ),
    );
  }
}
