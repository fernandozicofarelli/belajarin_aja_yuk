class KuisModel {
  final String id;
  final String question;
  final List<String> options;
  final String answer;

  KuisModel({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
  });

  factory KuisModel.fromMap(Map<String, dynamic> map, String docId) {
    return KuisModel(
      id: docId,
      question: map['question'],
      options: List<String>.from(map['options']),
      answer: map['answer'],
    );
  }
}
