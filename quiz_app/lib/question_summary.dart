import 'package:flutter/material.dart';
import 'package:quiz_app/summary_item.dart';

class QuestionsSummary extends StatelessWidget {
  const QuestionsSummary(this.summaryData, {super.key});

  final List<Map<String, Object>> summaryData;

  @override
  Widget build(BuildContext context) {
    // PERBAIKAN: Menambahkan SizedBox dan SingleChildScrollView agar bisa di-scroll
    return SizedBox(
      height: 400,
      child: SingleChildScrollView(
        child: Column(
          children: summaryData.map((data) {
            // PERBAIKAN: Menggunakan widget SummaryItem agar import tidak error
            return SummaryItem(data);
          }).toList(),
        ),
      ),
    );
  }
}
