// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get serverTitle => 'Serveur YouTrack';

  @override
  String get serverPrompt => 'Saisissez l\'adresse de votre instance YouTrack.';

  @override
  String get serverUrlLabel => 'Adresse du serveur';

  @override
  String get connect => 'Se connecter';

  @override
  String get cancel => 'Annuler';

  @override
  String get invalidUrl => 'Adresse invalide';

  @override
  String get serverUnreachable => 'Impossible de joindre le serveur';

  @override
  String get retry => 'Réessayer';

  @override
  String get changeServer => 'Changer de serveur';

  @override
  String get legalese =>
      'Distribué sous licence Apache 2.0.\n\nYouTrack est une marque de JetBrains s.r.o. UTD est un projet indépendant, ni affilié à JetBrains ni approuvé par JetBrains.';

  @override
  String get notificationsTitle => 'Notifications de bureau';

  @override
  String get notificationsIntro =>
      'UTD consulte votre centre de notifications YouTrack chaque minute et affiche les nouvelles notifications sur votre bureau. Un jeton permanent est nécessaire. Laissez le champ vide pour désactiver les notifications.';

  @override
  String get tokenLabel => 'Jeton permanent';

  @override
  String get tokenHelp =>
      'Dans YouTrack : Profil › Sécurité du compte › Nouveau jeton, avec la portée YouTrack.';

  @override
  String get openTokenPage => 'Créer un jeton';

  @override
  String get save => 'Enregistrer';

  @override
  String get tokenInvalid => 'Le serveur a refusé ce jeton.';

  @override
  String notificationsEnabled(String name) {
    return 'Notifications activées pour $name.';
  }

  @override
  String get notificationsDisabled => 'Notifications désactivées.';

  @override
  String updatedBy(String author) {
    return 'Mis à jour par $author';
  }

  @override
  String get newActivity => 'Nouvelle activité';

  @override
  String get statusChecking => 'Vérification…';

  @override
  String statusOk(String count, String time) {
    return 'Dernière vérification à $time. Notifications non lues : $count.';
  }

  @override
  String get statusKeychainError =>
      'Le jeton enregistré n\'a pas pu être lu dans le trousseau du système. Saisissez-le à nouveau et enregistrez.';

  @override
  String statusError(String error) {
    return 'La dernière vérification a échoué : $error';
  }

  @override
  String get statusPermissionDenied =>
      'Le système bloque les notifications d\'UTD. Autorisez-les dans les réglages du système.';

  @override
  String get openSystemSettings => 'Ouvrir les réglages du système';

  @override
  String get menuChangeServer => 'Changer de serveur…';

  @override
  String get menuNotifications => 'Notifications…';

  @override
  String menuAbout(String app) {
    return 'À propos de $app';
  }
}
