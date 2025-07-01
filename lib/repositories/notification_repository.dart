import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_settings/app_settings.dart';
import 'package:michelle_frerk/environment.dart';
import 'package:michelle_frerk/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRepository {
  bool? _alreadyDenied;
  
  final FirestoreService firestoreService;

  NotificationRepository({required this.firestoreService});

  
  get alreadyDenied async {
    if(_alreadyDenied == null) {
      final prefs = await SharedPreferences.getInstance();
      _alreadyDenied = prefs.getBool('notifications_already_denied') ?? false;
    }
    return _alreadyDenied;
  }

  get notificationsEnabled async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<void> requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    final enabled = await notificationsEnabled;
    if(enabled) {
      await subscribeToTopic();
    }
    if (!enabled) {
      _alreadyDenied = true;
    }
  }

  Future<void> subscribeToTopic() async {
    await FirebaseMessaging.instance.getAPNSToken();
    var topic = await Environment.firebaseMessagingTopic();
    FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  void openAppNotificationSettings() {
    AppSettings.openAppSettings();
  }
}
