// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Purrfect Spots';

  @override
  String get splashTitle1 => 'Purrfect';

  @override
  String get splashTitle2 => 'Spots';

  @override
  String get splashSubtitle => 'Un accogliente gioco puzzle\nda cat café';

  @override
  String get play => 'Gioca';

  @override
  String get cats => 'Gatti';

  @override
  String get shop => 'Negozio';

  @override
  String get settings => 'Impostazioni';

  @override
  String get cafeAreas => 'Aree del caffè';

  @override
  String get levels => 'Livelli';

  @override
  String get continueButton => 'Continua';

  @override
  String levelN(int floor) {
    return 'Livello $floor';
  }

  @override
  String floorNName(int floor, String name) {
    return 'Livello $floor - $name';
  }

  @override
  String floorsRange(int first, int last) {
    return 'Livelli $first-$last';
  }

  @override
  String floorsRangeTutorial(int first, int last) {
    return 'Livelli $first-$last · Tutorial';
  }

  @override
  String get progress => 'Progresso';

  @override
  String get comingSoon => 'Prossimamente!';

  @override
  String get exitTitle => 'Uscire da Purrfect Spots?';

  @override
  String get exitMessage => 'Sei sicuro di voler lasciare il caffè?';

  @override
  String get stay => 'Rimani';

  @override
  String get exit => 'Esci';

  @override
  String get back => 'Indietro';

  @override
  String moves(int count) {
    return 'MOSSE  $count';
  }

  @override
  String get swipeHint => 'Scorri per muovere e spingere i gatti';

  @override
  String get reset => 'Ricomincia';

  @override
  String get undo => 'Annulla';

  @override
  String plusUndos(int count) {
    return '+$count Annulla';
  }

  @override
  String get leaveLevel => 'Lasciare il livello?';

  @override
  String get leaveLevelMessage =>
      'I tuoi progressi in questo livello andranno persi.';

  @override
  String get keepPlaying => 'Continua a giocare';

  @override
  String get leave => 'Lascia';

  @override
  String get outOfUndos => 'Annullamenti esauriti!';

  @override
  String watchAdForUndos(int count) {
    return 'Guarda un breve video per ottenere $count annullamenti extra?';
  }

  @override
  String get noThanks => 'No grazie';

  @override
  String getUndos(int count) {
    return 'Ottieni $count annullamenti';
  }

  @override
  String get loadingAd => 'Caricamento annuncio...';

  @override
  String plusUndosGranted(int count) {
    return '+$count annullamenti';
  }

  @override
  String get purrfect => 'Purrfect!';

  @override
  String get movesLabel => 'Mosse';

  @override
  String get catsLabel => 'Gatti';

  @override
  String get ratingLabel => 'Valutazione';

  @override
  String get ratingPerfect => 'Perfetto!';

  @override
  String get ratingGreat => 'Ottimo';

  @override
  String get ratingGood => 'Buono';

  @override
  String get retry => 'Riprova';

  @override
  String get nextFloor => 'Prossimo livello';

  @override
  String get backToFloorSelect => 'Torna alla selezione';

  @override
  String categoryComplete(String name) {
    return '$name Completato!';
  }

  @override
  String everyCushionClaimed(int floor) {
    return 'Ogni cuscino occupato · Livello $floor';
  }

  @override
  String get account => 'Account';

  @override
  String get playingAsGuest => 'Gioca come ospite';

  @override
  String get signedInWithGoogle => 'Connesso con Google';

  @override
  String get signInSignUp => 'Accedi / Registrati';

  @override
  String get manageAccount => 'Gestisci account';

  @override
  String get signOut => 'Esci';

  @override
  String get signOutTitle => 'Uscire?';

  @override
  String get signOutMessage => 'Puoi accedere di nuovo in qualsiasi momento.';

  @override
  String get cancel => 'Annulla';

  @override
  String get signUp => 'Registrati';

  @override
  String get signIn => 'Accedi';

  @override
  String get username => 'Nome utente';

  @override
  String get usernameMin => 'Almeno 2 caratteri';

  @override
  String get usernameMax => 'Massimo 20 caratteri';

  @override
  String get email => 'E-mail';

  @override
  String get emailInvalid => 'Inserisci un indirizzo e-mail valido';

  @override
  String get password => 'Password';

  @override
  String get passwordMin => 'Almeno 6 caratteri';

  @override
  String get createAccount => 'Crea account';

  @override
  String get or => 'o';

  @override
  String get continueWithGoogle => 'Continua con Google';

  @override
  String get premium => 'Premium';

  @override
  String get premiumActive => 'Premium Attivo';

  @override
  String get unlimitedUndosNoAds =>
      'Annullamenti illimitati e nessuna pubblicità';

  @override
  String get purrfectPremium => 'Purrfect Premium';

  @override
  String get unlimitedUndosNoAdsShort =>
      'Annullamenti illimitati e senza pubblicità';

  @override
  String pricePerMonth(String price) {
    return '$price / mese';
  }

  @override
  String get subscribe => 'Abbonati';

  @override
  String get restorePurchases => 'Ripristina acquisti';

  @override
  String get language => 'Lingua';

  @override
  String get about => 'Info';

  @override
  String version(String version) {
    return 'Versione $version';
  }

  @override
  String get howToPlay => 'Come giocare';

  @override
  String get howToPlayDescription =>
      'Scorri per muoverti. Spingi i gatti sui loro cuscini. Usa meno mosse possibili per più stelle!';

  @override
  String get dangerZone => 'Zona pericolosa';

  @override
  String get resetAllProgress => 'Reimposta tutti i progressi';

  @override
  String get resetAllProgressTitle => 'Reimpostare tutti i progressi?';

  @override
  String get resetAllProgressMessage =>
      'Questo eliminerà permanentemente le tue stelle, migliori mosse, annullamenti e ogni livello completato in questo account. Questa azione è irreversibile.';

  @override
  String get resetEverything => 'Reimposta tutto';

  @override
  String get progressReset => 'Progressi reimpostati.';

  @override
  String get tipTitle => 'Suggerimento';

  @override
  String get tipSignIn =>
      'Accedi con Google per salvare i tuoi progressi su più dispositivi e apparire nelle classifiche!';

  @override
  String get leaderboard => 'Classifica';

  @override
  String get global => 'Globale';

  @override
  String get byFloor => 'Per livello';

  @override
  String get noRankingsYet => 'Nessuna classifica ancora!';

  @override
  String get completeForRankings =>
      'Completa alcuni livelli per vedere le classifiche.';

  @override
  String floorsCleared(int count) {
    return '$count livelli completati';
  }

  @override
  String get noRankingsForFloor => 'Nessuna classifica per questo livello!';

  @override
  String get catLover => 'Amante dei gatti';

  @override
  String clearedCount(int completed, int total) {
    return '$completed/$total completati';
  }

  @override
  String get latteLounge => 'Sala Latte';

  @override
  String get catnipCorner => 'Angolo Erba Gatta';

  @override
  String get velvetNook => 'Angolo Velluto';

  @override
  String get bakeryCorner => 'Angolo Panetteria';

  @override
  String get teaRoom => 'Sala da Tè';

  @override
  String get greenhouse => 'Serra';

  @override
  String get toyShop => 'Negozio di Giocattoli';

  @override
  String get readingLoft => 'Soffitta di Lettura';

  @override
  String get sunnyGarden => 'Giardino Soleggiato';

  @override
  String get whiskerTerrace => 'Terrazza dei Baffi';

  @override
  String get productNotAvailable => 'Prodotto non disponibile';

  @override
  String get purchaseFailed => 'Acquisto fallito';

  @override
  String get firebaseNotReady => 'Firebase non pronto';

  @override
  String get signInCancelled => 'Accesso annullato';
}
