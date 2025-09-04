import 'package:nb_utils/nb_utils.dart';

class AppKeys {
  static const String isPasswordRememberKey = 'Is Password Remember';

  static const String passwordKey = 'Password';
  static const String isLoggedInKey = 'Is Logged In';
  static const String selectedAppLanguageKey = 'App Language';
  static const String playerIdKey = 'Player Id';

  static const String appLanguageCodeKey = 'App Language Code';
  static const String appVersionKey = 'App Version';
  static const String hasInReviewKey = 'App Is In Review';
  static const String hasInReviewPlayStore = 'hasInReviewPlayStore';
  static const String hasInReviewAppStore = 'hasInReviewAppStore';
  static const String hasLocationPermissionKey = 'Has Location Permission';

  //region RemoveKeys
  static removeAppKeys() {
    removeKey(isPasswordRememberKey);
    removeKey(isLoggedInKey);
    removeKey(selectedAppLanguageKey);
    removeKey(appVersionKey);
    removeKey(hasInReviewKey);
    removeKey(hasInReviewPlayStore);
    removeKey(hasInReviewAppStore);
    removeKey(hasLocationPermissionKey);
  }
  //endregion
}
