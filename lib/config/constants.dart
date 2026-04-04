/// Game constants and configuration values.
class GameConstants {
  GameConstants._();

  // Grid and tile
  static const double tileSize = 64.0;
  static const int defaultUndoLimit = 3;
  static const int undosPerAd = 3;

  // Ad cooldown (minimum seconds between interstitials)
  static const int adCooldownSeconds = 60;

  // AdMob App ID: ca-app-pub-9288944682433583~6022992252
  // Android ad unit IDs
  static const String androidInterstitialAdId =
      'ca-app-pub-9288944682433583/8158201005';
  static const String androidRewardedAdId =
      'ca-app-pub-9288944682433583/5340465974';

  // iOS ad unit IDs — create these in AdMob when ready
  static const String iosInterstitialAdId =
      'ca-app-pub-3940256099942544/4411468910'; // still test ID
  static const String iosRewardedAdId =
      'ca-app-pub-3940256099942544/1712485313'; // still test ID

  // Animation durations
  static const Duration moveDuration = Duration(milliseconds: 150);
  static const Duration levelCompleteDuration = Duration(milliseconds: 600);

  // Swipe detection
  static const double minSwipeDistance = 20.0;
}
