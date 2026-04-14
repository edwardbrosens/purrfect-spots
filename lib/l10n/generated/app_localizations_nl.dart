// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Purrfect Spots';

  @override
  String get splashTitle1 => 'Purrfect';

  @override
  String get splashTitle2 => 'Spots';

  @override
  String get splashSubtitle => 'Een gezellig kattencafé\npuzzelspel';

  @override
  String get play => 'Spelen';

  @override
  String get cats => 'Katten';

  @override
  String get shop => 'Winkel';

  @override
  String get settings => 'Instellingen';

  @override
  String get cafeAreas => 'Caféruimtes';

  @override
  String get levels => 'Levels';

  @override
  String get continueButton => 'Verder';

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
    return 'Levels $first-$last';
  }

  @override
  String floorsRangeTutorial(int first, int last) {
    return 'Levels $first-$last · Uitleg';
  }

  @override
  String get progress => 'Voortgang';

  @override
  String get comingSoon => 'Binnenkort beschikbaar!';

  @override
  String get exitTitle => 'Purrfect Spots afsluiten?';

  @override
  String get exitMessage => 'Weet je zeker dat je het café wilt verlaten?';

  @override
  String get stay => 'Blijven';

  @override
  String get exit => 'Afsluiten';

  @override
  String get back => 'Terug';

  @override
  String moves(int count) {
    return 'ZETTEN  $count';
  }

  @override
  String get swipeHint => 'Swipe om te bewegen en katten te duwen';

  @override
  String get reset => 'Opnieuw';

  @override
  String get undo => 'Ongedaan';

  @override
  String plusUndos(int count) {
    return '+$count Ongedaan';
  }

  @override
  String get leaveLevel => 'Level verlaten?';

  @override
  String get leaveLevelMessage => 'Je voortgang op dit level gaat verloren.';

  @override
  String get keepPlaying => 'Doorspelen';

  @override
  String get leave => 'Verlaten';

  @override
  String get outOfUndos => 'Geen ongedaan meer!';

  @override
  String watchAdForUndos(int count) {
    return 'Bekijk een korte video voor $count extra ongedaan-acties?';
  }

  @override
  String get noThanks => 'Nee, bedankt';

  @override
  String getUndos(int count) {
    return 'Krijg $count ongedaan';
  }

  @override
  String get loadingAd => 'Advertentie laden...';

  @override
  String plusUndosGranted(int count) {
    return '+$count ongedaan';
  }

  @override
  String get purrfect => 'Purrfect!';

  @override
  String get movesLabel => 'Zetten';

  @override
  String get catsLabel => 'Katten';

  @override
  String get ratingLabel => 'Beoordeling';

  @override
  String get ratingPerfect => 'Perfect!';

  @override
  String get ratingGreat => 'Geweldig';

  @override
  String get ratingGood => 'Goed';

  @override
  String get retry => 'Opnieuw';

  @override
  String get nextFloor => 'Volgend Level';

  @override
  String get backToFloorSelect => 'Terug naar overzicht';

  @override
  String categoryComplete(String name) {
    return '$name Voltooid!';
  }

  @override
  String everyCushionClaimed(int floor) {
    return 'Elk kussen bezet · Level $floor';
  }

  @override
  String get account => 'Account';

  @override
  String get playingAsGuest => 'Speelt als gast';

  @override
  String get signedInWithGoogle => 'Ingelogd met Google';

  @override
  String get signInSignUp => 'Inloggen / Registreren';

  @override
  String get manageAccount => 'Account beheren';

  @override
  String get signOut => 'Uitloggen';

  @override
  String get signOutTitle => 'Uitloggen?';

  @override
  String get signOutMessage => 'Je kunt altijd weer inloggen.';

  @override
  String get cancel => 'Annuleren';

  @override
  String get signUp => 'Registreren';

  @override
  String get signIn => 'Inloggen';

  @override
  String get username => 'Gebruikersnaam';

  @override
  String get usernameMin => 'Minimaal 2 tekens';

  @override
  String get usernameMax => 'Maximaal 20 tekens';

  @override
  String get email => 'E-mail';

  @override
  String get emailInvalid => 'Voer een geldig e-mailadres in';

  @override
  String get password => 'Wachtwoord';

  @override
  String get passwordMin => 'Minimaal 6 tekens';

  @override
  String get createAccount => 'Account aanmaken';

  @override
  String get or => 'of';

  @override
  String get continueWithGoogle => 'Doorgaan met Google';

  @override
  String get continueWithApple => 'Doorgaan met Apple';

  @override
  String get premium => 'Premium';

  @override
  String get premiumActive => 'Premium Actief';

  @override
  String get unlimitedUndosNoAds =>
      'Onbeperkt ongedaan maken en geen advertenties';

  @override
  String get purrfectPremium => 'Purrfect Premium';

  @override
  String get unlimitedUndosNoAdsShort => 'Onbeperkt ongedaan & geen ads';

  @override
  String pricePerMonth(String price) {
    return '$price / maand';
  }

  @override
  String get subscribe => 'Abonneren';

  @override
  String get restorePurchases => 'Aankopen herstellen';

  @override
  String get language => 'Taal';

  @override
  String get about => 'Over';

  @override
  String version(String version) {
    return 'Versie $version';
  }

  @override
  String get howToPlay => 'Hoe te spelen';

  @override
  String get howToPlayDescription =>
      'Swipe om te bewegen. Duw katten naar hun kussen. Gebruik zo min mogelijk zetten voor meer sterren!';

  @override
  String get dangerZone => 'Gevarenzone';

  @override
  String get resetAllProgress => 'Alle voortgang wissen';

  @override
  String get resetAllProgressTitle => 'Alle voortgang wissen?';

  @override
  String get resetAllProgressMessage =>
      'Dit verwijdert permanent al je sterren, beste zetten, ongedaan-acties en elk voltooid level op dit account. Dit kan niet ongedaan worden gemaakt.';

  @override
  String get resetEverything => 'Alles wissen';

  @override
  String get progressReset => 'Voortgang gewist.';

  @override
  String get tipTitle => 'Tip';

  @override
  String get tipSignIn =>
      'Log in met Google om je voortgang op te slaan op meerdere apparaten en op ranglijsten te verschijnen!';

  @override
  String get leaderboard => 'Ranglijst';

  @override
  String get global => 'Globaal';

  @override
  String get byFloor => 'Per Level';

  @override
  String get noRankingsYet => 'Nog geen ranglijst!';

  @override
  String get completeForRankings =>
      'Voltooi een paar levels om ranglijsten te zien.';

  @override
  String floorsCleared(int count) {
    return '$count levels voltooid';
  }

  @override
  String get noRankingsForFloor => 'Nog geen ranglijst voor dit level!';

  @override
  String get catLover => 'Kattenliefhebber';

  @override
  String clearedCount(int completed, int total) {
    return '$completed/$total voltooid';
  }

  @override
  String get latteLounge => 'Latte Lounge';

  @override
  String get catnipCorner => 'Kattenkruidhoek';

  @override
  String get velvetNook => 'Fluwelen Hoekje';

  @override
  String get bakeryCorner => 'Bakkerijhoek';

  @override
  String get teaRoom => 'Theekamer';

  @override
  String get greenhouse => 'Serre';

  @override
  String get toyShop => 'Speelgoedwinkel';

  @override
  String get readingLoft => 'Leeszolder';

  @override
  String get sunnyGarden => 'Zonnetuin';

  @override
  String get whiskerTerrace => 'Snorhaarterras';

  @override
  String get productNotAvailable => 'Product niet beschikbaar';

  @override
  String get purchaseFailed => 'Aankoop mislukt';

  @override
  String get firebaseNotReady => 'Firebase niet gereed';

  @override
  String get signInCancelled => 'Inloggen geannuleerd';

  @override
  String get deleteAccount => 'Account verwijderen';

  @override
  String get deleteAccountTitle => 'Account verwijderen?';

  @override
  String get deleteAccountMessage =>
      'Dit verwijdert permanent je account, voortgang en alle gegevens. Dit kan niet ongedaan worden gemaakt.';

  @override
  String get deleteAccountConfirm => 'Definitief verwijderen';

  @override
  String get accountDeleted => 'Account verwijderd.';

  @override
  String get privacyPolicy => 'Privacybeleid';

  @override
  String get termsOfUse => 'Gebruiksvoorwaarden';
}
