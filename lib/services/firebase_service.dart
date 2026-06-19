import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Simpan atau update progress user untuk materi tertentu
  static Future<void> simpanProgress(String materiId, double progress) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore.collection('progress').doc(uid);

    final snapshot = await docRef.get();
    final now = Timestamp.now();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      final Map<String, dynamic> currentProgress = Map<String, dynamic>.from(data['materi'] ?? {});
      final currentValue = (currentProgress[materiId] ?? 0.0) as num;

      // Simpan hanya jika progres baru lebih tinggi
      if (progress > currentValue) {
        currentProgress[materiId] = progress;
        await docRef.update({
          'materi': currentProgress,
          'lastUpdate': now,
        });
      }
    } else {
      // Buat dokumen baru kalau belum ada
      await docRef.set({
        'materi': {materiId: progress},
        'lastUpdate': now,
      });
    }
  }
}
