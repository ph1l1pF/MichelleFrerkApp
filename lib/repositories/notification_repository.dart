import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_settings/app_settings.dart';
import 'package:michelle_frerk/environment.dart';
import 'package:michelle_frerk/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRepository {
  bool? _alreadyDenied;
  bool? _hintAlreadShown;
  
  final FirestoreService firestoreService;

  NotificationRepository({required this.firestoreService});

  
  get alreadyDenied async {
    if(_alreadyDenied == null) {
      final prefs = await SharedPreferences.getInstance();
      _alreadyDenied = prefs.getBool('notifications_already_denied') ?? false;
    }
    return _alreadyDenied;
  }

  get hintAlreadyShown async {
    if(_hintAlreadShown == null) {
      final prefs = await SharedPreferences.getInstance();
      _hintAlreadShown = prefs.getBool('notifications_hint_already_shown') ?? false;
    }
    return _hintAlreadShown;
  }

  setHintAlreadyShown() async {
    _hintAlreadShown = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_hint_already_shown', true);
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
      await firestoreService.storeNotificationsEnabled();
    }
    if (!enabled) {
      _alreadyDenied = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_already_denied', true);
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
