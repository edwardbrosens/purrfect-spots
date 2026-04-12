// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Purrfect Spots';

  @override
  String get splashTitle1 => 'Purrfect';

  @override
  String get splashTitle2 => 'Spots';

  @override
  String get splashSubtitle => 'Un jeu de puzzle\nchat café cosy';

  @override
  String get play => 'Jouer';

  @override
  String get cats => 'Chats';

  @override
  String get shop => 'Boutique';

  @override
  String get settings => 'Paramètres';

  @override
  String get cafeAreas => 'Espaces du café';

  @override
  String get levels => 'Niveaux';

  @override
  String get continueButton => 'Continuer';

  @override
  String levelN(int floor) {
    return 'Niveau $floor';
  }

  @override
  String floorNName(int floor, String name) {
    return 'Niveau $floor - $name';
  }

  @override
  String floorsRange(int first, int last) {
    return 'Niveaux $first-$last';
  }

  @override
  String floorsRangeTutorial(int first, int last) {
    return 'Niveaux $first-$last · Tutoriel';
  }

  @override
  String get progress => 'Progression';

  @override
  String get comingSoon => 'Bientôt disponible !';

  @override
  String get exitTitle => 'Quitter Purrfect Spots ?';

  @override
  String get exitMessage => 'Es-tu sûr de vouloir quitter le café ?';

  @override
  String get stay => 'Rester';

  @override
  String get exit => 'Quitter';

  @override
  String get back => 'Retour';

  @override
  String moves(int count) {
    return 'COUPS  $count';
  }

  @override
  String get swipeHint => 'Glisse pour déplacer et pousser les chats';

  @override
  String get reset => 'Recommencer';

  @override
  String get undo => 'Annuler';

  @override
  String plusUndos(int count) {
    return '+$count Annuler';
  }

  @override
  String get leaveLevel => 'Quitter le niveau ?';

  @override
  String get leaveLevelMessage => 'Ta progression dans ce niveau sera perdue.';

  @override
  String get keepPlaying => 'Continuer';

  @override
  String get leave => 'Quitter';

  @override
  String get outOfUndos => 'Plus d\'annulations !';

  @override
  String watchAdForUndos(int count) {
    return 'Regarde une courte vidéo pour obtenir $count annulations supplémentaires ?';
  }

  @override
  String get noThanks => 'Non merci';

  @override
  String getUndos(int count) {
    return 'Obtenir $count annulations';
  }

  @override
  String get loadingAd => 'Chargement de la pub...';

  @override
  String plusUndosGranted(int count) {
    return '+$count annulations';
  }

  @override
  String get purrfect => 'Purrfect !';

  @override
  String get movesLabel => 'Coups';

  @override
  String get catsLabel => 'Chats';

  @override
  String get ratingLabel => 'Note';

  @override
  String get ratingPerfect => 'Parfait !';

  @override
  String get ratingGreat => 'Super';

  @override
  String get ratingGood => 'Bien';

  @override
  String get retry => 'Réessayer';

  @override
  String get nextFloor => 'Niveau suivant';

  @override
  String get backToFloorSelect => 'Retour à la sélection';

  @override
  String categoryComplete(String name) {
    return '$name Terminé !';
  }

  @override
  String everyCushionClaimed(int floor) {
    return 'Chaque coussin occupé · Niveau $floor';
  }

  @override
  String get account => 'Compte';

  @override
  String get playingAsGuest => 'Joue en tant qu\'invité';

  @override
  String get signedInWithGoogle => 'Connecté avec Google';

  @override
  String get signInSignUp => 'Se connecter / S\'inscrire';

  @override
  String get manageAccount => 'Gérer le compte';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signOutTitle => 'Se déconnecter ?';

  @override
  String get signOutMessage => 'Tu peux te reconnecter à tout moment.';

  @override
  String get cancel => 'Annuler';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get signIn => 'Se connecter';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get usernameMin => 'Au moins 2 caractères';

  @override
  String get usernameMax => 'Maximum 20 caractères';

  @override
  String get email => 'E-mail';

  @override
  String get emailInvalid => 'Entre une adresse e-mail valide';

  @override
  String get password => 'Mot de passe';

  @override
  String get passwordMin => 'Au moins 6 caractères';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get or => 'ou';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get premium => 'Premium';

  @override
  String get premiumActive => 'Premium Actif';

  @override
  String get unlimitedUndosNoAds => 'Annulations illimitées et sans publicité';

  @override
  String get purrfectPremium => 'Purrfect Premium';

  @override
  String get unlimitedUndosNoAdsShort => 'Annulations illimitées & sans pub';

  @override
  String pricePerMonth(String price) {
    return '$price / mois';
  }

  @override
  String get subscribe => 'S\'abonner';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get language => 'Langue';

  @override
  String get about => 'À propos';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get howToPlay => 'Comment jouer';

  @override
  String get howToPlayDescription =>
      'Glisse pour te déplacer. Pousse les chats sur leurs coussins. Utilise le moins de coups possible pour plus d\'étoiles !';

  @override
  String get dangerZone => 'Zone de danger';

  @override
  String get resetAllProgress => 'Réinitialiser toute la progression';

  @override
  String get resetAllProgressTitle => 'Réinitialiser toute la progression ?';

  @override
  String get resetAllProgressMessage =>
      'Cela supprimera définitivement tes étoiles, meilleurs coups, annulations et chaque niveau terminé de ce compte. Cette action est irréversible.';

  @override
  String get resetEverything => 'Tout réinitialiser';

  @override
  String get progressReset => 'Progression réinitialisée.';

  @override
  String get tipTitle => 'Astuce';

  @override
  String get tipSignIn =>
      'Connecte-toi avec Google pour sauvegarder ta progression sur plusieurs appareils et apparaître dans les classements !';

  @override
  String get leaderboard => 'Classement';

  @override
  String get global => 'Global';

  @override
  String get byFloor => 'Par niveau';

  @override
  String get noRankingsYet => 'Pas encore de classement !';

  @override
  String get completeForRankings =>
      'Termine quelques niveaux pour voir les classements.';

  @override
  String floorsCleared(int count) {
    return '$count niveaux terminés';
  }

  @override
  String get noRankingsForFloor => 'Pas encore de classement pour ce niveau !';

  @override
  String get catLover => 'Amoureux des chats';

  @override
  String clearedCount(int completed, int total) {
    return '$completed/$total terminés';
  }

  @override
  String get latteLounge => 'Salon Latte';

  @override
  String get catnipCorner => 'Coin Herbe-à-chat';

  @override
  String get velvetNook => 'Coin Velours';

  @override
  String get bakeryCorner => 'Coin Boulangerie';

  @override
  String get teaRoom => 'Salon de Thé';

  @override
  String get greenhouse => 'Serre';

  @override
  String get toyShop => 'Magasin de Jouets';

  @override
  String get readingLoft => 'Grenier de Lecture';

  @override
  String get sunnyGarden => 'Jardin Ensoleillé';

  @override
  String get whiskerTerrace => 'Terrasse des Moustaches';

  @override
  String get productNotAvailable => 'Produit non disponible';

  @override
  String get purchaseFailed => 'Achat échoué';

  @override
  String get firebaseNotReady => 'Firebase non prêt';

  @override
  String get signInCancelled => 'Connexion annulée';
}
