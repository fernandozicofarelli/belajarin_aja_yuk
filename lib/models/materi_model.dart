class MateriModel {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String pdfUrl;
  final double progress;
  final String summary;
  final List<Map<String, dynamic>> quiz;

  MateriModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.pdfUrl,
    required this.progress,
    required this.summary,
    required this.quiz,
  });

  factory MateriModel.fromJson(Map<String, dynamic> json) {
    return MateriModel(
      id: json['id'] ?? '',
      title: json['title'] ?? json['judul'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      pdfUrl: json['pdfUrl'] ?? '',
      progress: (json['progress'] ?? 0).toDouble(),
      summary: json['summary'] ?? json['ringkasan'] ?? '',
      quiz: (json['quiz'] ?? json['kuis'] ?? [])
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'pdfUrl': pdfUrl,
      'progress': progress,
      'summary': summary,
      'quiz': quiz,
    };
  }
}
