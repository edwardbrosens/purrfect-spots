import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('nl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Purrfect Spots'**
  String get appTitle;

  /// No description provided for @splashTitle1.
  ///
  /// In en, this message translates to:
  /// **'Purrfect'**
  String get splashTitle1;

  /// No description provided for @splashTitle2.
  ///
  /// In en, this message translates to:
  /// **'Spots'**
  String get splashTitle2;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A cosy cat café puzzle\ngame'**
  String get splashSubtitle;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @cats.
  ///
  /// In en, this message translates to:
  /// **'Cats'**
  String get cats;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @cafeAreas.
  ///
  /// In en, this message translates to:
  /// **'Café Areas'**
  String get cafeAreas;

  /// No description provided for @levels.
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get levels;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @levelN.
  ///
  /// In en, this message translates to:
  /// **'Level {floor}'**
  String levelN(int floor);

  /// No description provided for @floorNName.
  ///
  /// In en, this message translates to:
  /// **'Floor {floor} - {name}'**
  String floorNName(int floor, String name);

  /// No description provided for @floorsRange.
  ///
  /// In en, this message translates to:
  /// **'Floors {first}-{last}'**
  String floorsRange(int first, int last);

  /// No description provided for @floorsRangeTutorial.
  ///
  /// In en, this message translates to:
  /// **'Floors {first}-{last} · Tutorial'**
  String floorsRangeTutorial(int first, int last);

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get comingSoon;

  /// No description provided for @exitTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit Purrfect Spots?'**
  String get exitTitle;

  /// No description provided for @exitMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave the café?'**
  String get exitMessage;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @moves.
  ///
  /// In en, this message translates to:
  /// **'MOVES  {count}'**
  String moves(int count);

  /// No description provided for @swipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe to move and push cats'**
  String get swipeHint;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @plusUndos.
  ///
  /// In en, this message translates to:
  /// **'+{count} Undos'**
  String plusUndos(int count);

  /// No description provided for @leaveLevel.
  ///
  /// In en, this message translates to:
  /// **'Leave level?'**
  String get leaveLevel;

  /// No description provided for @leaveLevelMessage.
  ///
  /// In en, this message translates to:
  /// **'Your progress on this level will be lost.'**
  String get leaveLevelMessage;

  /// No description provided for @keepPlaying.
  ///
  /// In en, this message translates to:
  /// **'Keep playing'**
  String get keepPlaying;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @outOfUndos.
  ///
  /// In en, this message translates to:
  /// **'Out of undos!'**
  String get outOfUndos;

  /// No description provided for @watchAdForUndos.
  ///
  /// In en, this message translates to:
  /// **'Watch a short video to earn {count} extra undos?'**
  String watchAdForUndos(int count);

  /// No description provided for @noThanks.
  ///
  /// In en, this message translates to:
  /// **'No thanks'**
  String get noThanks;

  /// No description provided for @getUndos.
  ///
  /// In en, this message translates to:
  /// **'Get {count} undos'**
  String getUndos(int count);

  /// No description provided for @loadingAd.
  ///
  /// In en, this message translates to:
  /// **'Loading ad...'**
  String get loadingAd;

  /// No description provided for @plusUndosGranted.
  ///
  /// In en, this message translates to:
  /// **'+{count} undos'**
  String plusUndosGranted(int count);

  /// No description provided for @purrfect.
  ///
  /// In en, this message translates to:
  /// **'Purrfect!'**
  String get purrfect;

  /// No description provided for @movesLabel.
  ///
  /// In en, this message translates to:
  /// **'Moves'**
  String get movesLabel;

  /// No description provided for @catsLabel.
  ///
  /// In en, this message translates to:
  /// **'Cats'**
  String get catsLabel;

  /// No description provided for @ratingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingLabel;

  /// No description provided for @ratingPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect!'**
  String get ratingPerfect;

  /// No description provided for @ratingGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get ratingGreat;

  /// No description provided for @ratingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingGood;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @nextFloor.
  ///
  /// In en, this message translates to:
  /// **'Next Floor'**
  String get nextFloor;

  /// No description provided for @backToFloorSelect.
  ///
  /// In en, this message translates to:
  /// **'Back to Floor Select'**
  String get backToFloorSelect;

  /// No description provided for @categoryComplete.
  ///
  /// In en, this message translates to:
  /// **'{name} Complete!'**
  String categoryComplete(String name);

  /// No description provided for @everyCushionClaimed.
  ///
  /// In en, this message translates to:
  /// **'Every cushion claimed · Floor {floor}'**
  String everyCushionClaimed(int floor);

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @playingAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Playing as guest'**
  String get playingAsGuest;

  /// No description provided for @signedInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Signed in with Google'**
  String get signedInWithGoogle;

  /// No description provided for @signInSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign in / Sign up'**
  String get signInSignUp;

  /// No description provided for @manageAccount.
  ///
  /// In en, this message translates to:
  /// **'Manage account'**
  String get manageAccount;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutTitle;

  /// No description provided for @signOutMessage.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in any time.'**
  String get signOutMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameMin.
  ///
  /// In en, this message translates to:
  /// **'At least 2 characters'**
  String get usernameMin;

  /// No description provided for @usernameMax.
  ///
  /// In en, this message translates to:
  /// **'Max 20 characters'**
  String get usernameMax;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordMin.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordMin;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium Active'**
  String get premiumActive;

  /// No description provided for @unlimitedUndosNoAds.
  ///
  /// In en, this message translates to:
  /// **'Unlimited undos and no ads'**
  String get unlimitedUndosNoAds;

  /// No description provided for @purrfectPremium.
  ///
  /// In en, this message translates to:
  /// **'Purrfect Premium'**
  String get purrfectPremium;

  /// No description provided for @unlimitedUndosNoAdsShort.
  ///
  /// In en, this message translates to:
  /// **'Unlimited undos & no ads'**
  String get unlimitedUndosNoAdsShort;

  /// No description provided for @pricePerMonth.
  ///
  /// In en, this message translates to:
  /// **'{price} / month'**
  String pricePerMonth(String price);

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get howToPlay;

  /// No description provided for @howToPlayDescription.
  ///
  /// In en, this message translates to:
  /// **'Swipe to move. Push cats onto their cushions. Use as few moves as possible for more stars!'**
  String get howToPlayDescription;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get dangerZone;

  /// No description provided for @resetAllProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset all progress'**
  String get resetAllProgress;

  /// No description provided for @resetAllProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all progress?'**
  String get resetAllProgressTitle;

  /// No description provided for @resetAllProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your stars, best moves, undos, and every completed level on this account. This cannot be undone.'**
  String get resetAllProgressMessage;

  /// No description provided for @resetEverything.
  ///
  /// In en, this message translates to:
  /// **'Reset everything'**
  String get resetEverything;

  /// No description provided for @progressReset.
  ///
  /// In en, this message translates to:
  /// **'Progress reset.'**
  String get progressReset;

  /// No description provided for @tipTitle.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tipTitle;

  /// No description provided for @tipSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google to save your progress across devices and appear on leaderboards!'**
  String get tipSignIn;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @global.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get global;

  /// No description provided for @byFloor.
  ///
  /// In en, this message translates to:
  /// **'By Floor'**
  String get byFloor;

  /// No description provided for @noRankingsYet.
  ///
  /// In en, this message translates to:
  /// **'No rankings yet!'**
  String get noRankingsYet;

  /// No description provided for @completeForRankings.
  ///
  /// In en, this message translates to:
  /// **'Complete some levels to see rankings.'**
  String get completeForRankings;

  /// No description provided for @floorsCleared.
  ///
  /// In en, this message translates to:
  /// **'{count} floors cleared'**
  String floorsCleared(int count);

  /// No description provided for @noRankingsForFloor.
  ///
  /// In en, this message translates to:
  /// **'No rankings for this floor yet!'**
  String get noRankingsForFloor;

  /// No description provided for @catLover.
  ///
  /// In en, this message translates to:
  /// **'Cat Lover'**
  String get catLover;

  /// No description provided for @clearedCount.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} cleared'**
  String clearedCount(int completed, int total);

  /// No description provided for @latteLounge.
  ///
  /// In en, this message translates to:
  /// **'Latte Lounge'**
  String get latteLounge;

  /// No description provided for @catnipCorner.
  ///
  /// In en, this message translates to:
  /// **'Catnip Corner'**
  String get catnipCorner;

  /// No description provided for @velvetNook.
  ///
  /// In en, this message translates to:
  /// **'Velvet Nook'**
  String get velvetNook;

  /// No description provided for @bakeryCorner.
  ///
  /// In en, this message translates to:
  /// **'Bakery Corner'**
  String get bakeryCorner;

  /// No description provided for @teaRoom.
  ///
  /// In en, this message translates to:
  /// **'Tea Room'**
  String get teaRoom;

  /// No description provided for @greenhouse.
  ///
  /// In en, this message translates to:
  /// **'Greenhouse'**
  String get greenhouse;

  /// No description provided for @toyShop.
  ///
  /// In en, this message translates to:
  /// **'Toy Shop'**
  String get toyShop;

  /// No description provided for @readingLoft.
  ///
  /// In en, this message translates to:
  /// **'Reading Loft'**
  String get readingLoft;

  /// No description provided for @sunnyGarden.
  ///
  /// In en, this message translates to:
  /// **'Sunny Garden'**
  String get sunnyGarden;

  /// No description provided for @whiskerTerrace.
  ///
  /// In en, this message translates to:
  /// **'Whisker Terrace'**
  String get whiskerTerrace;

  /// No description provided for @productNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Product not available'**
  String get productNotAvailable;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed'**
  String get purchaseFailed;

  /// No description provided for @firebaseNotReady.
  ///
  /// In en, this message translates to:
  /// **'Firebase not ready'**
  String get firebaseNotReady;

  /// No description provided for @signInCancelled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in cancelled'**
  String get signInCancelled;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account, progress, and all data. This cannot be undone.'**
  String get deleteAccountMessage;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deleteAccountConfirm;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get accountDeleted;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'nl',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
