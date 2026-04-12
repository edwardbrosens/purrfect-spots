// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Purrfect Spots';

  @override
  String get splashTitle1 => 'Purrfect';

  @override
  String get splashTitle2 => 'Spots';

  @override
  String get splashSubtitle => 'Un acogedor juego de\npuzzle de cat café';

  @override
  String get play => 'Jugar';

  @override
  String get cats => 'Gatos';

  @override
  String get shop => 'Tienda';

  @override
  String get settings => 'Ajustes';

  @override
  String get cafeAreas => 'Zonas del café';

  @override
  String get levels => 'Niveles';

  @override
  String get continueButton => 'Continuar';

  @override
  String levelN(int floor) {
    return 'Nivel $floor';
  }

  @override
  String floorNName(int floor, String name) {
    return 'Nivel $floor - $name';
  }

  @override
  String floorsRange(int first, int last) {
    return 'Niveles $first-$last';
  }

  @override
  String floorsRangeTutorial(int first, int last) {
    return 'Niveles $first-$last · Tutorial';
  }

  @override
  String get progress => 'Progreso';

  @override
  String get comingSoon => '¡Próximamente!';

  @override
  String get exitTitle => '¿Salir de Purrfect Spots?';

  @override
  String get exitMessage => '¿Estás seguro de que quieres salir del café?';

  @override
  String get stay => 'Quedarse';

  @override
  String get exit => 'Salir';

  @override
  String get back => 'Atrás';

  @override
  String moves(int count) {
    return 'MOVIMIENTOS  $count';
  }

  @override
  String get swipeHint => 'Desliza para mover y empujar gatos';

  @override
  String get reset => 'Reiniciar';

  @override
  String get undo => 'Deshacer';

  @override
  String plusUndos(int count) {
    return '+$count Deshacer';
  }

  @override
  String get leaveLevel => '¿Abandonar nivel?';

  @override
  String get leaveLevelMessage => 'Tu progreso en este nivel se perderá.';

  @override
  String get keepPlaying => 'Seguir jugando';

  @override
  String get leave => 'Abandonar';

  @override
  String get outOfUndos => '¡Sin deshacer!';

  @override
  String watchAdForUndos(int count) {
    return '¿Ver un vídeo corto para ganar $count deshacer extra?';
  }

  @override
  String get noThanks => 'No, gracias';

  @override
  String getUndos(int count) {
    return 'Obtener $count deshacer';
  }

  @override
  String get loadingAd => 'Cargando anuncio...';

  @override
  String plusUndosGranted(int count) {
    return '+$count deshacer';
  }

  @override
  String get purrfect => '¡Purrfect!';

  @override
  String get movesLabel => 'Movimientos';

  @override
  String get catsLabel => 'Gatos';

  @override
  String get ratingLabel => 'Puntuación';

  @override
  String get ratingPerfect => '¡Perfecto!';

  @override
  String get ratingGreat => 'Genial';

  @override
  String get ratingGood => 'Bien';

  @override
  String get retry => 'Reintentar';

  @override
  String get nextFloor => 'Siguiente nivel';

  @override
  String get backToFloorSelect => 'Volver a selección';

  @override
  String categoryComplete(String name) {
    return '¡$name Completado!';
  }

  @override
  String everyCushionClaimed(int floor) {
    return 'Cada cojín ocupado · Nivel $floor';
  }

  @override
  String get account => 'Cuenta';

  @override
  String get playingAsGuest => 'Jugando como invitado';

  @override
  String get signedInWithGoogle => 'Conectado con Google';

  @override
  String get signInSignUp => 'Iniciar sesión / Registrarse';

  @override
  String get manageAccount => 'Gestionar cuenta';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get signOutTitle => '¿Cerrar sesión?';

  @override
  String get signOutMessage =>
      'Puedes volver a iniciar sesión en cualquier momento.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get signUp => 'Registrarse';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get usernameMin => 'Al menos 2 caracteres';

  @override
  String get usernameMax => 'Máximo 20 caracteres';

  @override
  String get email => 'Correo electrónico';

  @override
  String get emailInvalid => 'Introduce un correo válido';

  @override
  String get password => 'Contraseña';

  @override
  String get passwordMin => 'Al menos 6 caracteres';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get or => 'o';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get premium => 'Premium';

  @override
  String get premiumActive => 'Premium Activo';

  @override
  String get unlimitedUndosNoAds => 'Deshacer ilimitado y sin anuncios';

  @override
  String get purrfectPremium => 'Purrfect Premium';

  @override
  String get unlimitedUndosNoAdsShort => 'Deshacer ilimitado y sin anuncios';

  @override
  String pricePerMonth(String price) {
    return '$price / mes';
  }

  @override
  String get subscribe => 'Suscribirse';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get about => 'Acerca de';

  @override
  String version(String version) {
    return 'Versión $version';
  }

  @override
  String get howToPlay => 'Cómo jugar';

  @override
  String get howToPlayDescription =>
      'Desliza para moverte. Empuja los gatos a sus cojines. ¡Usa el menor número de movimientos posible para más estrellas!';

  @override
  String get dangerZone => 'Zona de peligro';

  @override
  String get resetAllProgress => 'Restablecer todo el progreso';

  @override
  String get resetAllProgressTitle => '¿Restablecer todo el progreso?';

  @override
  String get resetAllProgressMessage =>
      'Esto eliminará permanentemente tus estrellas, mejores movimientos, deshacer y cada nivel completado en esta cuenta. Esta acción no se puede deshacer.';

  @override
  String get resetEverything => 'Restablecer todo';

  @override
  String get progressReset => 'Progreso restablecido.';

  @override
  String get tipTitle => 'Consejo';

  @override
  String get tipSignIn =>
      '¡Inicia sesión con Google para guardar tu progreso en varios dispositivos y aparecer en las clasificaciones!';

  @override
  String get leaderboard => 'Clasificación';

  @override
  String get global => 'Global';

  @override
  String get byFloor => 'Por nivel';

  @override
  String get noRankingsYet => '¡Aún no hay clasificación!';

  @override
  String get completeForRankings =>
      'Completa algunos niveles para ver clasificaciones.';

  @override
  String floorsCleared(int count) {
    return '$count niveles completados';
  }

  @override
  String get noRankingsForFloor => '¡Aún no hay clasificación para este nivel!';

  @override
  String get catLover => 'Amante de gatos';

  @override
  String clearedCount(int completed, int total) {
    return '$completed/$total completados';
  }

  @override
  String get latteLounge => 'Salón Latte';

  @override
  String get catnipCorner => 'Rincón de Hierba Gatera';

  @override
  String get velvetNook => 'Rincón de Terciopelo';

  @override
  String get bakeryCorner => 'Rincón de Panadería';

  @override
  String get teaRoom => 'Sala de Té';

  @override
  String get greenhouse => 'Invernadero';

  @override
  String get toyShop => 'Juguetería';

  @override
  String get readingLoft => 'Desván de Lectura';

  @override
  String get sunnyGarden => 'Jardín Soleado';

  @override
  String get whiskerTerrace => 'Terraza de Bigotes';

  @override
  String get productNotAvailable => 'Producto no disponible';

  @override
  String get purchaseFailed => 'Compra fallida';

  @override
  String get firebaseNotReady => 'Firebase no está listo';

  @override
  String get signInCancelled => 'Inicio de sesión cancelado';
}
