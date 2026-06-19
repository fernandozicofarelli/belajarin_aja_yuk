import 'package:flutter/material.dart';
import '../../models/progress_model.dart';

class ProgressPage extends StatelessWidget {
  final List<ProgressModel> daftarProgress;

  const ProgressPage({super.key, required this.daftarProgress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Progres Belajar"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: daftarProgress.length,
        itemBuilder: (context, index) {
          final progress = daftarProgress[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress.materiId,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress.progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 4),
                  Text("${(progress.progress * 100).toInt()}% Selesai"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
