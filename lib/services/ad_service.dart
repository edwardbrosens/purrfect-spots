import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/constants.dart';

/// Manages AdMob interstitial and rewarded ads.
class AdService {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  DateTime? _lastInterstitialTime;

  // ── Interstitial Ads ──────────────────────────────────────

  String get _interstitialAdUnitId => Platform.isAndroid
      ? GameConstants.androidInterstitialAdId
      : GameConstants.iosInterstitialAdId;

  String get _rewardedAdUnitId => Platform.isAndroid
      ? GameConstants.androidRewardedAdId
      : GameConstants.iosRewardedAdId;

  /// Pre-load an interstitial ad.
  void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitial(); // Pre-load next one
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Show interstitial ad with cooldown enforcement.
  Future<void> showInterstitial() async {
    if (_interstitialAd == null) return;

    // Enforce cooldown
    final now = DateTime.now();
    if (_lastInterstitialTime != null) {
      final elapsed = now.difference(_lastInterstitialTime!).inSeconds;
      if (elapsed < GameConstants.adCooldownSeconds) return;
    }

    _lastInterstitialTime = now;
    await _interstitialAd!.show();
  }

  // ── Rewarded Ads ──────────────────────────────────────────

  /// Pre-load a rewarded ad.
  void loadRewarded() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              loadRewarded(); // Pre-load next one
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              loadRewarded();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
        },
      ),
    );
  }

  /// Show rewarded ad. Returns true if user earned the reward.
  Future<bool> showRewarded() async {
    if (_rewardedAd == null) return false;

    bool earned = false;
    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        earned = true;
      },
    );
    return earned;
  }

  bool get isInterstitialReady => _interstitialAd != null;
  bool get isRewardedReady => _rewardedAd != null;

  /// Initialize and pre-load all ads.
  void initialize() {
    loadInterstitial();
    loadRewarded();
  }

  /// Dispose all ads.
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
