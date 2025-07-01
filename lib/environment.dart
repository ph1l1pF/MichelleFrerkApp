import 'package:store_checker/store_checker.dart';

class Environment {
  static final String shopifyDomain = "caae00.myshopify.com";
  static final String shopifyGraphQLUrl = "https://caae00.myshopify.com/admin/api/2023-10/graphql.json";

  static Future<String> firebaseMessagingTopic() async {
    if (await _isProdMode()) {
      return "all_devices_prod";
    } else {
      return "all_devices_test";
    }
  }

  static Future<String> firebaseStoreCollectionGewinnspiel() async{
    if (await _isProdMode()) {
      return "Gewinnspiel";
    } else {
      return "Gewinnspiel_test";
    }
  }

  static Future<String> firebaseStoreCollectionNotificationsEnabled() async{
    if (await _isProdMode()) {
      return "Notifications";
    } else {
      return "Notifications_test";
    }
  }

  static Future<bool> _isProdMode() async{
    var installationSource = await StoreChecker.getSource;
    return installationSource == Source.IS_INSTALLED_FROM_APP_STORE || installationSource == Source.IS_INSTALLED_FROM_PLAY_STORE;
  }
}
