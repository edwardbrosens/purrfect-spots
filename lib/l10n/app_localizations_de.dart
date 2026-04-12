// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Purrfect Spots';

  @override
  String get splashTitle1 => 'Purrfect';

  @override
  String get splashTitle2 => 'Spots';

  @override
  String get splashSubtitle => 'Ein gemütliches Katzencafé-\nPuzzlespiel';

  @override
  String get play => 'Spielen';

  @override
  String get cats => 'Katzen';

  @override
  String get shop => 'Shop';

  @override
  String get settings => 'Einstellungen';

  @override
  String get cafeAreas => 'Cafébereiche';

  @override
  String get levels => 'Level';

  @override
  String get continueButton => 'Weiter';

  @override
  String levelN(int floor) {
    return 'Level $floor';
  }

  @override
  String floorNName(int floor, String name) {
    return 'Level $floor - $name';
  }

  @override
  String floorsRange(int first, int last) {
    return 'Level $first-$last';
  }

  @override
  String floorsRangeTutorial(int first, int last) {
    return 'Level $first-$last · Anleitung';
  }

  @override
  String get progress => 'Fortschritt';

  @override
  String get comingSoon => 'Demnächst verfügbar!';

  @override
  String get exitTitle => 'Purrfect Spots beenden?';

  @override
  String get exitMessage => 'Möchtest du das Café wirklich verlassen?';

  @override
  String get stay => 'Bleiben';

  @override
  String get exit => 'Beenden';

  @override
  String get back => 'Zurück';

  @override
  String moves(int count) {
    return 'ZÜGE  $count';
  }

  @override
  String get swipeHint => 'Wische, um Katzen zu bewegen und zu schieben';

  @override
  String get reset => 'Neustart';

  @override
  String get undo => 'Rückgängig';

  @override
  String plusUndos(int count) {
    return '+$count Rückgängig';
  }

  @override
  String get leaveLevel => 'Level verlassen?';

  @override
  String get leaveLevelMessage =>
      'Dein Fortschritt in diesem Level geht verloren.';

  @override
  String get keepPlaying => 'Weiterspielen';

  @override
  String get leave => 'Verlassen';

  @override
  String get outOfUndos => 'Keine Rückgängig-Aktionen mehr!';

  @override
  String watchAdForUndos(int count) {
    return 'Schau ein kurzes Video für $count zusätzliche Rückgängig-Aktionen?';
  }

  @override
  String get noThanks => 'Nein danke';

  @override
  String getUndos(int count) {
    return '$count Rückgängig erhalten';
  }

  @override
  String get loadingAd => 'Werbung wird geladen...';

  @override
  String plusUndosGranted(int count) {
    return '+$count Rückgängig';
  }

  @override
  String get purrfect => 'Purrfect!';

  @override
  String get movesLabel => 'Züge';

  @override
  String get catsLabel => 'Katzen';

  @override
  String get ratingLabel => 'Bewertung';

  @override
  String get ratingPerfect => 'Perfekt!';

  @override
  String get ratingGreat => 'Großartig';

  @override
  String get ratingGood => 'Gut';

  @override
  String get retry => 'Nochmal';

  @override
  String get nextFloor => 'Nächstes Level';

  @override
  String get backToFloorSelect => 'Zurück zur Übersicht';

  @override
  String categoryComplete(String name) {
    return '$name Abgeschlossen!';
  }

  @override
  String everyCushionClaimed(int floor) {
    return 'Jedes Kissen besetzt · Level $floor';
  }

  @override
  String get account => 'Konto';

  @override
  String get playingAsGuest => 'Spielt als Gast';

  @override
  String get signedInWithGoogle => 'Mit Google angemeldet';

  @override
  String get signInSignUp => 'Anmelden / Registrieren';

  @override
  String get manageAccount => 'Konto verwalten';

  @override
  String get signOut => 'Abmelden';

  @override
  String get signOutTitle => 'Abmelden?';

  @override
  String get signOutMessage => 'Du kannst dich jederzeit wieder anmelden.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get signUp => 'Registrieren';

  @override
  String get signIn => 'Anmelden';

  @override
  String get username => 'Benutzername';

  @override
  String get usernameMin => 'Mindestens 2 Zeichen';

  @override
  String get usernameMax => 'Maximal 20 Zeichen';

  @override
  String get email => 'E-Mail';

  @override
  String get emailInvalid => 'Gib eine gültige E-Mail-Adresse ein';

  @override
  String get password => 'Passwort';

  @override
  String get passwordMin => 'Mindestens 6 Zeichen';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get or => 'oder';

  @override
  String get continueWithGoogle => 'Weiter mit Google';

  @override
  String get premium => 'Premium';

  @override
  String get premiumActive => 'Premium Aktiv';

  @override
  String get unlimitedUndosNoAds => 'Unbegrenzt Rückgängig und keine Werbung';

  @override
  String get purrfectPremium => 'Purrfect Premium';

  @override
  String get unlimitedUndosNoAdsShort =>
      'Unbegrenzt Rückgängig & keine Werbung';

  @override
  String pricePerMonth(String price) {
    return '$price / Monat';
  }

  @override
  String get subscribe => 'Abonnieren';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get about => 'Über';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get howToPlay => 'Spielanleitung';

  @override
  String get howToPlayDescription =>
      'Wische, um dich zu bewegen. Schiebe Katzen auf ihre Kissen. Verwende so wenige Züge wie möglich für mehr Sterne!';

  @override
  String get dangerZone => 'Gefahrenzone';

  @override
  String get resetAllProgress => 'Gesamten Fortschritt löschen';

  @override
  String get resetAllProgressTitle => 'Gesamten Fortschritt löschen?';

  @override
  String get resetAllProgressMessage =>
      'Dies löscht dauerhaft alle Sterne, besten Züge, Rückgängig-Aktionen und jedes abgeschlossene Level in diesem Konto. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get resetEverything => 'Alles löschen';

  @override
  String get progressReset => 'Fortschritt gelöscht.';

  @override
  String get tipTitle => 'Tipp';

  @override
  String get tipSignIn =>
      'Melde dich mit Google an, um deinen Fortschritt geräteübergreifend zu speichern und in Ranglisten zu erscheinen!';

  @override
  String get leaderboard => 'Rangliste';

  @override
  String get global => 'Global';

  @override
  String get byFloor => 'Nach Level';

  @override
  String get noRankingsYet => 'Noch keine Rangliste!';

  @override
  String get completeForRankings =>
      'Schließe ein paar Level ab, um Ranglisten zu sehen.';

  @override
  String floorsCleared(int count) {
    return '$count Level abgeschlossen';
  }

  @override
  String get noRankingsForFloor => 'Noch keine Rangliste für dieses Level!';

  @override
  String get catLover => 'Katzenliebhaber';

  @override
  String clearedCount(int completed, int total) {
    return '$completed/$total abgeschlossen';
  }

  @override
  String get latteLounge => 'Latte Lounge';

  @override
  String get catnipCorner => 'Katzenminze-Ecke';

  @override
  String get velvetNook => 'Samtecke';

  @override
  String get bakeryCorner => 'Bäckerei-Ecke';

  @override
  String get teaRoom => 'Teestube';

  @override
  String get greenhouse => 'Gewächshaus';

  @override
  String get toyShop => 'Spielzeugladen';

  @override
  String get readingLoft => 'Lesedachboden';

  @override
  String get sunnyGarden => 'Sonnengarten';

  @override
  String get whiskerTerrace => 'Schnurrbart-Terrasse';

  @override
  String get productNotAvailable => 'Produkt nicht verfügbar';

  @override
  String get purchaseFailed => 'Kauf fehlgeschlagen';

  @override
  String get firebaseNotReady => 'Firebase nicht bereit';

  @override
  String get signInCancelled => 'Anmeldung abgebrochen';
}
