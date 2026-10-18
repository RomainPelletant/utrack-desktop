// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get serverTitle => 'Servidor do YouTrack';

  @override
  String get serverPrompt => 'Digite o endereço da sua instância do YouTrack.';

  @override
  String get serverUrlLabel => 'Endereço do servidor';

  @override
  String get connect => 'Conectar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get invalidUrl => 'Endereço inválido';

  @override
  String get serverUnreachable => 'Não foi possível acessar o servidor';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get changeServer => 'Mudar de servidor';

  @override
  String get legalese =>
      'Distribuído sob a Licença Apache 2.0.\n\nYouTrack é uma marca comercial da JetBrains s.r.o. O UTD é um projeto independente, sem afiliação ou endosso da JetBrains.';

  @override
  String get notificationsTitle => 'Notificações na área de trabalho';

  @override
  String get notificationsIntro =>
      'O UTD verifica a cada minuto sua central de notificações do YouTrack e exibe as novas notificações na área de trabalho. É necessário um token permanente. Deixe o campo vazio para desativar as notificações.';

  @override
  String get tokenLabel => 'Token permanente';

  @override
  String get tokenHelp =>
      'No YouTrack: Perfil › Segurança da conta › Novo token, com o escopo YouTrack.';

  @override
  String get openTokenPage => 'Criar um token';

  @override
  String get save => 'Salvar';

  @override
  String get tokenInvalid => 'O servidor recusou este token.';

  @override
  String notificationsEnabled(String name) {
    return 'Notificações ativadas para $name.';
  }

  @override
  String get notificationsDisabled => 'Notificações desativadas.';

  @override
  String updatedBy(String author) {
    return 'Atualizado por $author';
  }

  @override
  String get newActivity => 'Nova atividade';

  @override
  String get statusChecking => 'Verificando…';

  @override
  String statusOk(String count, String time) {
    return 'Última verificação às $time. Notificações não lidas: $count.';
  }

  @override
  String get statusKeychainError =>
      'Não foi possível ler o token salvo nas chaves do sistema. Digite-o novamente e salve.';

  @override
  String statusError(String error) {
    return 'A última verificação falhou: $error';
  }

  @override
  String get statusPermissionDenied =>
      'O sistema está bloqueando as notificações do UTD. Permita-as nos ajustes do sistema.';

  @override
  String get openSystemSettings => 'Abrir ajustes do sistema';

  @override
  String get menuChangeServer => 'Mudar de Servidor…';

  @override
  String get menuNotifications => 'Notificações…';

  @override
  String menuAbout(String app) {
    return 'Sobre o $app';
  }
}

/// The translations for Portuguese, as used in Portugal (`pt_PT`).
class AppLocalizationsPtPt extends AppLocalizationsPt {
  AppLocalizationsPtPt() : super('pt_PT');

  @override
  String get serverTitle => 'Servidor YouTrack';

  @override
  String get serverPrompt => 'Introduza o endereço da sua instância YouTrack.';

  @override
  String get serverUrlLabel => 'Endereço do servidor';

  @override
  String get connect => 'Ligar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get invalidUrl => 'Endereço inválido';

  @override
  String get serverUnreachable => 'Não é possível contactar o servidor';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get changeServer => 'Mudar de servidor';

  @override
  String get legalese =>
      'Distribuído ao abrigo da Licença Apache 2.0.\n\nYouTrack é uma marca comercial da JetBrains s.r.o. O UTD é um projeto independente, sem afiliação nem aprovação da JetBrains.';

  @override
  String get notificationsTitle => 'Notificações no ambiente de trabalho';

  @override
  String get notificationsIntro =>
      'O UTD verifica a cada minuto o seu centro de notificações do YouTrack e mostra as novas notificações no ambiente de trabalho. É necessário um token permanente. Deixe o campo vazio para desativar as notificações.';

  @override
  String get tokenLabel => 'Token permanente';

  @override
  String get tokenHelp =>
      'No YouTrack: Perfil › Segurança da conta › Novo token, com o âmbito YouTrack.';

  @override
  String get openTokenPage => 'Criar um token';

  @override
  String get save => 'Guardar';

  @override
  String get tokenInvalid => 'O servidor recusou este token.';

  @override
  String notificationsEnabled(String name) {
    return 'Notificações ativadas para $name.';
  }

  @override
  String get notificationsDisabled => 'Notificações desativadas.';

  @override
  String updatedBy(String author) {
    return 'Atualizado por $author';
  }

  @override
  String get newActivity => 'Nova atividade';

  @override
  String get statusChecking => 'A verificar…';

  @override
  String statusOk(String count, String time) {
    return 'Última verificação às $time. Notificações não lidas: $count.';
  }

  @override
  String get statusKeychainError =>
      'Não foi possível ler o token guardado no porta-chaves do sistema. Introduza-o novamente e guarde.';

  @override
  String statusError(String error) {
    return 'A última verificação falhou: $error';
  }

  @override
  String get statusPermissionDenied =>
      'O sistema bloqueia as notificações do UTD. Permita-as nas definições do sistema.';

  @override
  String get openSystemSettings => 'Abrir definições do sistema';

  @override
  String get menuChangeServer => 'Mudar de servidor…';

  @override
  String get menuNotifications => 'Notificações…';

  @override
  String menuAbout(String app) {
    return 'Acerca do $app';
  }
}
