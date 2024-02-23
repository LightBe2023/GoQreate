import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String sender, String recipient, String message) async {
    await _firestore.collection('messages').add({
      'sender': sender,
      'recipient': recipient,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String recipient) {
    return _firestore
        .collection('messages')
        .where('recipient', isEqualTo: recipient)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<List<Map<String, dynamic>>> getChatsWithPreview() {
    return _firestore.collection('messages').snapshots().map((snapshot) {
      List<Map<String, dynamic>> chatPreviews = [];

      // Group messages by recipient
      Map<String, List<Map<String, dynamic>>> groupedMessages = {};

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        var recipient = data['recipient'] as String;

        if (!groupedMessages.containsKey(recipient)) {
          groupedMessages[recipient] = [];
        }

        groupedMessages[recipient]!.add(data);
      }

      // Extract the latest message for each recipient
      groupedMessages.forEach((recipient, messages) {
        messages.sort((a, b) {
          var aTimestamp = (a['timestamp'] as Timestamp).toDate();
          var bTimestamp = (b['timestamp'] as Timestamp).toDate();
          return bTimestamp.compareTo(aTimestamp);
        });

        var latestMessage = messages.isNotEmpty ? messages.first['message'] : '';
        var chatPreview = {
          'userName': recipient,
          'latestMessage': latestMessage,
        };

        chatPreviews.add(chatPreview);
      });

      return chatPreviews;
    });
  }
}
