// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Purrfect Spots';

  @override
  String get splashTitle1 => 'Purrfect';

  @override
  String get splashTitle2 => 'Spots';

  @override
  String get splashSubtitle => 'A cosy cat café puzzle\ngame';

  @override
  String get play => 'Play';

  @override
  String get cats => 'Cats';

  @override
  String get shop => 'Shop';

  @override
  String get settings => 'Settings';

  @override
  String get cafeAreas => 'Café Areas';

  @override
  String get levels => 'Levels';

  @override
  String get continueButton => 'Continue';

  @override
  String levelN(int floor) {
    return 'Level $floor';
  }

  @override
  String floorNName(int floor, String name) {
    return 'Floor $floor - $name';
  }

  @override
  String floorsRange(int first, int last) {
    return 'Floors $first-$last';
  }

  @override
  String floorsRangeTutorial(int first, int last) {
    return 'Floors $first-$last · Tutorial';
  }

  @override
  String get progress => 'Progress';

  @override
  String get comingSoon => 'Coming soon!';

  @override
  String get exitTitle => 'Exit Purrfect Spots?';

  @override
  String get exitMessage => 'Are you sure you want to leave the café?';

  @override
  String get stay => 'Stay';

  @override
  String get exit => 'Exit';

  @override
  String get back => 'Back';

  @override
  String moves(int count) {
    return 'MOVES  $count';
  }

  @override
  String get swipeHint => 'Swipe to move and push cats';

  @override
  String get reset => 'Reset';

  @override
  String get undo => 'Undo';

  @override
  String plusUndos(int count) {
    return '+$count Undos';
  }

  @override
  String get leaveLevel => 'Leave level?';

  @override
  String get leaveLevelMessage => 'Your progress on this level will be lost.';

  @override
  String get keepPlaying => 'Keep playing';

  @override
  String get leave => 'Leave';

  @override
  String get outOfUndos => 'Out of undos!';

  @override
  String watchAdForUndos(int count) {
    return 'Watch a short video to earn $count extra undos?';
  }

  @override
  String get noThanks => 'No thanks';

  @override
  String getUndos(int count) {
    return 'Get $count undos';
  }

  @override
  String get loadingAd => 'Loading ad...';

  @override
  String plusUndosGranted(int count) {
    return '+$count undos';
  }

  @override
  String get purrfect => 'Purrfect!';

  @override
  String get movesLabel => 'Moves';

  @override
  String get catsLabel => 'Cats';

  @override
  String get ratingLabel => 'Rating';

  @override
  String get ratingPerfect => 'Perfect!';

  @override
  String get ratingGreat => 'Great';

  @override
  String get ratingGood => 'Good';

  @override
  String get retry => 'Retry';

  @override
  String get nextFloor => 'Next Floor';

  @override
  String get backToFloorSelect => 'Back to Floor Select';

  @override
  String categoryComplete(String name) {
    return '$name Complete!';
  }

  @override
  String everyCushionClaimed(int floor) {
    return 'Every cushion claimed · Floor $floor';
  }

  @override
  String get account => 'Account';

  @override
  String get playingAsGuest => 'Playing as guest';

  @override
  String get signedInWithGoogle => 'Signed in with Google';

  @override
  String get signInSignUp => 'Sign in / Sign up';

  @override
  String get manageAccount => 'Manage account';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutTitle => 'Sign out?';

  @override
  String get signOutMessage => 'You can sign back in any time.';

  @override
  String get cancel => 'Cancel';

  @override
  String get signUp => 'Sign up';

  @override
  String get signIn => 'Sign in';

  @override
  String get username => 'Username';

  @override
  String get usernameMin => 'At least 2 characters';

  @override
  String get usernameMax => 'Max 20 characters';

  @override
  String get email => 'Email';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get password => 'Password';

  @override
  String get passwordMin => 'At least 6 characters';

  @override
  String get createAccount => 'Create account';

  @override
  String get or => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get premium => 'Premium';

  @override
  String get premiumActive => 'Premium Active';

  @override
  String get unlimitedUndosNoAds => 'Unlimited undos and no ads';

  @override
  String get purrfectPremium => 'Purrfect Premium';

  @override
  String get unlimitedUndosNoAdsShort => 'Unlimited undos & no ads';

  @override
  String pricePerMonth(String price) {
    return '$price / month';
  }

  @override
  String get subscribe => 'Subscribe';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get about => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get howToPlay => 'How to Play';

  @override
  String get howToPlayDescription =>
      'Swipe to move. Push cats onto their cushions. Use as few moves as possible for more stars!';

  @override
  String get dangerZone => 'Danger zone';

  @override
  String get resetAllProgress => 'Reset all progress';

  @override
  String get resetAllProgressTitle => 'Reset all progress?';

  @override
  String get resetAllProgressMessage =>
      'This will permanently delete your stars, best moves, undos, and every completed level on this account. This cannot be undone.';

  @override
  String get resetEverything => 'Reset everything';

  @override
  String get progressReset => 'Progress reset.';

  @override
  String get tipTitle => 'Tip';

  @override
  String get tipSignIn =>
      'Sign in with Google to save your progress across devices and appear on leaderboards!';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get global => 'Global';

  @override
  String get byFloor => 'By Floor';

  @override
  String get noRankingsYet => 'No rankings yet!';

  @override
  String get completeForRankings => 'Complete some levels to see rankings.';

  @override
  String floorsCleared(int count) {
    return '$count floors cleared';
  }

  @override
  String get noRankingsForFloor => 'No rankings for this floor yet!';

  @override
  String get catLover => 'Cat Lover';

  @override
  String clearedCount(int completed, int total) {
    return '$completed/$total cleared';
  }

  @override
  String get latteLounge => 'Latte Lounge';

  @override
  String get catnipCorner => 'Catnip Corner';

  @override
  String get velvetNook => 'Velvet Nook';

  @override
  String get bakeryCorner => 'Bakery Corner';

  @override
  String get teaRoom => 'Tea Room';

  @override
  String get greenhouse => 'Greenhouse';

  @override
  String get toyShop => 'Toy Shop';

  @override
  String get readingLoft => 'Reading Loft';

  @override
  String get sunnyGarden => 'Sunny Garden';

  @override
  String get whiskerTerrace => 'Whisker Terrace';

  @override
  String get productNotAvailable => 'Product not available';

  @override
  String get purchaseFailed => 'Purchase failed';

  @override
  String get firebaseNotReady => 'Firebase not ready';

  @override
  String get signInCancelled => 'Sign-in cancelled';
}
