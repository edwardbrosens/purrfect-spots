import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow both orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize Firebase
  bool firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (e) {
    debugPrint('Firebase not configured yet. Run: flutterfire configure');
    debugPrint('The game will run in offline/local mode.');
  }

  // Initialize AdMob (mobile only — not supported on web)
  bool adsEnabled = false;
  if (!kIsWeb) {
    try {
      await MobileAds.instance.initialize();
      adsEnabled = true;
    } catch (e) {
      debugPrint('AdMob init failed: $e');
    }
  }

  runApp(CatCafeApp(firebaseReady: firebaseReady, adsEnabled: adsEnabled));
}
