class ProgressModel {
  final String materiId;
  final double progress;

  ProgressModel({required this.materiId, required this.progress});

  factory ProgressModel.fromJson(String id, dynamic value) {
    return ProgressModel(
      materiId: id,
      progress: (value ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      materiId: progress,
    };
  }
}
