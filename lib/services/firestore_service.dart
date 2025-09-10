import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:michelle_frerk/environment.dart';

class FirestoreService {


Future<void> storeNotificationsEnabled() async {
    final firestore = FirebaseFirestore.instance;

    String collection = await Environment.firebaseStoreCollectionNotificationsEnabled();

    await firestore.collection(collection).add({
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> storeGewinnspielTeilnehmer(String name, String email) async {
    final firestore = FirebaseFirestore.instance;

    String collection = await Environment.firebaseStoreCollectionGewinnspiel();

    await firestore.collection(collection).add({
      'name': name,
      'email': email,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
