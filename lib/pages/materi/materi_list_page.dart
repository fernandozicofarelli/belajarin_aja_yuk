import 'package:flutter/material.dart';
import '../../models/materi_model.dart';
import '../../widgets/progress_bar.dart';
import 'detail_materi_page.dart';

class MateriListPage extends StatelessWidget {
  final String pelajaran;
  final List<Map<String, dynamic>> materiList;
  final Map<String, double> progressMap; // ✅ Tambahkan ini

  const MateriListPage({
    super.key,
    required this.pelajaran,
    required this.materiList,
    required this.progressMap, // ✅ Tambahkan ini juga
  });

  @override
  Widget build(BuildContext context) {
    final List<MateriModel> parsedMateriList =
        materiList.map((e) => MateriModel.fromJson(e)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(pelajaran),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: parsedMateriList.isEmpty
          ? const Center(child: Text("Belum ada materi."))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: parsedMateriList.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final materi = parsedMateriList[index];
                final progress = progressMap[materi.id] ?? 0.0;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.play_circle_fill,
                      size: 32,
                      color: Colors.blue,
                    ),
                    title: Text(
                      materi.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: ProgressBar(progress: progress), // ✅ pakai progress dari Firebase
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailMateriPage(materi: materi),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
