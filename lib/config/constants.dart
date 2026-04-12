/// Game constants and configuration values.
class GameConstants {
  GameConstants._();

  // Grid and tile
  static const double tileSize = 64.0;
  static const int defaultUndoLimit = 10;
  static const int undosPerAd = 10;

  // Ad cooldown (minimum seconds between interstitials)
  static const int adCooldownSeconds = 60;

  // AdMob App ID: ca-app-pub-9288944682433583~6022992252
  // Set to true to use Google's sample ad unit IDs (for development)
  static const bool useTestAds = false;

  // Production ad unit IDs
  static const String _androidInterstitialAdId =
      'ca-app-pub-9288944682433583/8158201005';
  static const String _androidRewardedAdId =
      'ca-app-pub-9288944682433583/5340465974';
  static const String _iosInterstitialAdId =
      'ca-app-pub-9288944682433583/6384302911';
  static const String _iosRewardedAdId =
      'ca-app-pub-9288944682433583/2640499024';

  // Google sample test ad unit IDs (always fill)
  static const String _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testInterstitialIos =
      'ca-app-pub-3940256099942544/4411468910';
  static const String _testRewardedIos =
      'ca-app-pub-3940256099942544/1712485313';

  static String get androidInterstitialAdId =>
      useTestAds ? _testInterstitialAndroid : _androidInterstitialAdId;
  static String get androidRewardedAdId =>
      useTestAds ? _testRewardedAndroid : _androidRewardedAdId;
  static String get iosInterstitialAdId =>
      useTestAds ? _testInterstitialIos : _iosInterstitialAdId;
  static String get iosRewardedAdId =>
      useTestAds ? _testRewardedIos : _iosRewardedAdId;

  // Animation durations
  static const Duration moveDuration = Duration(milliseconds: 150);
  static const Duration levelCompleteDuration = Duration(milliseconds: 600);

  // In-app purchase product ID (must match App Store Connect & Google Play Console)
  static const String premiumProductId = 'premium_monthly';

  // Swipe detection
  static const double minSwipeDistance = 20.0;
}
