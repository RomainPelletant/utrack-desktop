// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get serverTitle => 'Server YouTrack';

  @override
  String get serverPrompt =>
      'Inserisci l\'indirizzo della tua istanza YouTrack.';

  @override
  String get serverUrlLabel => 'Indirizzo del server';

  @override
  String get connect => 'Connetti';

  @override
  String get cancel => 'Annulla';

  @override
  String get invalidUrl => 'Indirizzo non valido';

  @override
  String get serverUnreachable => 'Impossibile raggiungere il server';

  @override
  String get retry => 'Riprova';

  @override
  String get changeServer => 'Cambia server';

  @override
  String get legalese =>
      'Distribuito con licenza Apache 2.0.\n\nYouTrack è un marchio di JetBrains s.r.o. UTD è un progetto indipendente, non affiliato né approvato da JetBrains.';

  @override
  String get notificationsTitle => 'Notifiche desktop';

  @override
  String get notificationsIntro =>
      'UTD controlla ogni minuto il centro notifiche di YouTrack e mostra le nuove notifiche sul desktop. È necessario un token permanente. Lascia il campo vuoto per disattivare le notifiche.';

  @override
  String get tokenLabel => 'Token permanente';

  @override
  String get tokenHelp =>
      'In YouTrack: Profilo › Sicurezza dell\'account › Nuovo token, con ambito YouTrack.';

  @override
  String get openTokenPage => 'Crea un token';

  @override
  String get save => 'Salva';

  @override
  String get tokenInvalid => 'Il server ha rifiutato questo token.';

  @override
  String notificationsEnabled(String name) {
    return 'Notifiche attivate per $name.';
  }

  @override
  String get notificationsDisabled => 'Notifiche disattivate.';

  @override
  String updatedBy(String author) {
    return 'Aggiornato da $author';
  }

  @override
  String get newActivity => 'Nuova attività';

  @override
  String get statusChecking => 'Verifica in corso…';

  @override
  String statusOk(String count, String time) {
    return 'Ultima verifica alle $time. Notifiche non lette: $count.';
  }

  @override
  String get statusKeychainError =>
      'Impossibile leggere il token salvato dal portachiavi di sistema. Inseriscilo di nuovo e salva.';

  @override
  String statusError(String error) {
    return 'Ultima verifica non riuscita: $error';
  }

  @override
  String get statusPermissionDenied =>
      'Il sistema blocca le notifiche di UTD. Consentile nelle impostazioni di sistema.';

  @override
  String get openSystemSettings => 'Apri impostazioni di sistema';

  @override
  String get menuChangeServer => 'Cambia server…';

  @override
  String get menuNotifications => 'Notifiche…';

  @override
  String menuAbout(String app) {
    return 'Informazioni su $app';
  }
}
