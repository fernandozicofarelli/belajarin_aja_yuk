class UserModel {
  final String uid;
  final String name;
  final String email;
  final int score;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.score,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      score: (map['score'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'score': score,
    };
  }
}
