class Materi {
  final String id;
  final String judul;
  final String videoUrl;
  final String ringkasan;
  final List<Kuis> kuis;

  Materi({
    required this.id,
    required this.judul,
    required this.videoUrl,
    required this.ringkasan,
    required this.kuis,
  });

  factory Materi.fromJson(Map<String, dynamic> json) {
    return Materi(
      id: json['id'],
      judul: json['judul'],
      videoUrl: json['videoUrl'],
      ringkasan: json['ringkasan'],
      kuis: (json['kuis'] as List).map((e) => Kuis.fromJson(e)).toList(),
    );
  }
}

class Kuis {
  final String soal;
  final List<String> opsi;
  final String jawaban;

  Kuis({
    required this.soal,
    required this.opsi,
    required this.jawaban,
  });

  factory Kuis.fromJson(Map<String, dynamic> json) {
    return Kuis(
      soal: json['soal'],
      opsi: List<String>.from(json['opsi']),
      jawaban: json['jawaban'],
    );
  }
}
