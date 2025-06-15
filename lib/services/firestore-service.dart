import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:michelle_frerk/environment.dart';

class FirestoreService {
  Future<void> store(String name, String email) async {
    final firestore = FirebaseFirestore.instance;

    String collection = await Environment.firebaseStoreCollection();

    await firestore.collection(collection).add({
      'name': name,
      'email': email,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
