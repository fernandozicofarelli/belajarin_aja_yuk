import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String userMessage, String botResponse) async {
    await _firestore.collection('chats').add({
      'user': userMessage,
      'bot': botResponse,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getChatMessages() {
    return _firestore
        .collection('chats')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
