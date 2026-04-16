// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appTitle => 'Alla med';

  @override
  String get cancel => 'Avbryt';

  @override
  String get save => 'Spara';

  @override
  String get next => 'Nästa';

  @override
  String get skip => 'Hoppa över';

  @override
  String get getStarted => 'Kom igång';

  @override
  String get create => 'Skapa';

  @override
  String get importAction => 'Importera';

  @override
  String get back => 'Tillbaka';

  @override
  String get restore => 'Återställ';

  @override
  String get remove => 'Ta bort';

  @override
  String get report => 'Rapport';

  @override
  String get end => 'Avsluta';

  @override
  String get copy => 'Kopiera';

  @override
  String get statusUnknown => 'Ej anlänt';

  @override
  String get statusPresent => 'Incheckad';

  @override
  String get statusAbsent => 'Frånvaro';

  @override
  String get statusLate => 'Försenad';

  @override
  String get statusCheckedOut => 'Utcheckad';

  @override
  String get statusPlannedAbsent => 'Planerad frånvaro';

  @override
  String get myGroups => 'Mina grupper';

  @override
  String get archivedGroups => 'Arkiverade grupper';

  @override
  String get settings => 'Inställningar';

  @override
  String get noGroupsYet => 'Inga grupper ännu';

  @override
  String get noGroupsDescription =>
      'Skapa din första grupp för att komma igång.';

  @override
  String get newGroup => 'Ny grupp';

  @override
  String studentCount(int count) {
    return '$count elever';
  }

  @override
  String get exportSemester => 'Exportera termin';

  @override
  String get sessionHistory => 'Sessionshistorik';

  @override
  String get addStudent => 'Lägg till elev';

  @override
  String get importStudents => 'Importera elever';

  @override
  String get noStudentsInGroup => 'Inga elever i gruppen';

  @override
  String get addStudentsManuallyOrImport =>
      'Lägg till elever manuellt eller importera från fil.';

  @override
  String get startSession => 'Starta registrering';

  @override
  String get sessionName => 'Sessionens namn (valfritt)';

  @override
  String get sessionNameHint => 't.ex. Fredagsträning, Utflykt till fjället';

  @override
  String get noteLabel => 'Anteckning';

  @override
  String get noteHint => 'Lägg till anteckning...';

  @override
  String get classroom => 'Klassrum';

  @override
  String get trip => 'Utflykt';

  @override
  String get viewFinishedSessions => 'Visa avslutade sessioner';

  @override
  String get activeSessionExistsTitle => 'Aktiv session finns';

  @override
  String get activeSessionExistsContent =>
      'Det finns redan en aktiv session för den här gruppen. Vill du fortsätta den?';

  @override
  String get continueSession => 'Fortsätt';

  @override
  String get renameStudentTitle => 'Ändra elevnamn';

  @override
  String get newNameHint => 'Nytt namn';

  @override
  String get removeStudentTitle => 'Ta bort elev från gruppen?';

  @override
  String removeStudentContent(String name) {
    return '$name tas bort från den här gruppen. Elevens data och historik behålls.';
  }

  @override
  String historyTitle(String groupName) {
    return 'Historik — $groupName';
  }

  @override
  String get noFinishedSessions => 'Inga avslutade sessioner';

  @override
  String get finishedSessionsDescription =>
      'Avslutade sessioner visas här så att du kan se rapport eller redigera frånvaro i efterhand.';

  @override
  String get editAbsence => 'Redigera frånvaro';

  @override
  String classroomTitle(String groupName) {
    return '$groupName — Klassrum';
  }

  @override
  String tripTitle(String groupName) {
    return '$groupName — Utflykt';
  }

  @override
  String sessionTitle(String sessionName) {
    return '$sessionName';
  }

  @override
  String get tapChangeStatusHint =>
      'Tryck = inchecka/utchecka · Håll in = anteckning och fler val';

  @override
  String get phaseInnsjekk => 'Incheckning';

  @override
  String get phaseUtsjekk => 'Utcheckning';

  @override
  String get switchToUtsjekk => 'Byt till utcheckning';

  @override
  String get switchToInnsjekk => '← Incheckning';

  @override
  String get innsjekkHint =>
      'Tryck för incheckning · Håll in för anteckning och frånvaro';

  @override
  String get utsjekkHint => 'Tryck för utcheckning · Håll in för anteckning';

  @override
  String get endSession => 'Avsluta session';

  @override
  String get endSessionTitle => 'Avsluta session?';

  @override
  String get endTripTitle => 'Avsluta utflyktsregistrering?';

  @override
  String get reportStillAvailable =>
      'Du kan fortfarande se rapporten efter avslutning.';

  @override
  String get searchStudent => 'Sök efter elev...';

  @override
  String registeredCount(int registered, int total) {
    return '$registered / $total registrerade';
  }

  @override
  String notRegisteredCount(int count) {
    return '$count inte registrerade';
  }

  @override
  String minutesLate(int minutes) {
    return '$minutes min försenad';
  }

  @override
  String get lateLabel => 'Försenad:';

  @override
  String get exportPdf => 'Exportera PDF';

  @override
  String get copyToClipboard => 'Kopiera till urklipp';

  @override
  String get shareReport => 'Dela rapport';

  @override
  String get reportCopied => 'Rapport kopierad';

  @override
  String get copyReport => 'Kopiera rapport';

  @override
  String get reportCopiedFull => 'Rapport kopierad till urklipp';

  @override
  String get shareVia => 'Dela via...';

  @override
  String get pdfExportError => 'Fel vid PDF-export:';

  @override
  String exportScreenTitle(String groupName) {
    return 'Exportera — $groupName';
  }

  @override
  String get choosePeriod => 'Välj period';

  @override
  String get exportCsvDescription =>
      'Exporterar CSV med alla sessioner i perioden. En rad per elev, en kolumn per session.';

  @override
  String get from => 'Från';

  @override
  String get to => 'Till';

  @override
  String get csvLegend =>
      'Förklaring:\nN = Närvarande · F = Frånvaro · S15 = Försenad 15 min\nP = Planerad frånvaro · ? = Inte registrerad';

  @override
  String get exportCsv => 'Exportera CSV';

  @override
  String get noSessionsInPeriod => 'Inga sessioner i vald period.';

  @override
  String get exportError => 'Fel vid export:';

  @override
  String get biometricLock => 'Biometriskt lås';

  @override
  String get biometricLockSubtitle =>
      'Kräv fingeravtryck eller ansikte vid uppstart';

  @override
  String get backup => 'Säkerhetskopiering';

  @override
  String get backupSubtitle => 'Säkerhetskopia till Google Drive';

  @override
  String get aboutApp => 'Om Alla med';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get loadingVersion => 'Laddar version...';

  @override
  String get privacyTitle => 'Integritet';

  @override
  String get privacySubtitle =>
      'All data lagras krypterad lokalt på din enhet. Ingen data skickas till någon server.';

  @override
  String get subscriptionActive => 'Prenumeration aktiv';

  @override
  String get subscriptionActiveSubtitle => 'Årsprenumeration — 29 kr/år';

  @override
  String get trialStatus => 'Provperiod';

  @override
  String get trialFree => 'Gratis i 30 dagar';

  @override
  String trialDaysLeft(int days) {
    return '$days dagar kvar av provperioden';
  }

  @override
  String get subscriptionExpired => 'Prenumeration utgången';

  @override
  String get subscriptionExpiredSubtitle =>
      'Prenumerera för att fortsätta använda appen';

  @override
  String get loadingStatus => 'Laddar...';

  @override
  String get googleDriveBackup => 'Google Drive-säkerhetskopiering';

  @override
  String get backupDescription =>
      'Spara en krypterad kopia av din databas på Google Drive. Bara du har tillgång till säkerhetskopian.';

  @override
  String lastBackup(String date) {
    return 'Senaste säkerhetskopia: $date';
  }

  @override
  String get signInWithGoogle => 'Logga in med Google';

  @override
  String get takeBackupNow => 'Ta säkerhetskopia nu';

  @override
  String get restoreFromBackup => 'Återställ från säkerhetskopia';

  @override
  String get restoreConfirmTitle => 'Återställ från säkerhetskopia?';

  @override
  String get restoreConfirmContent =>
      'All nuvarande data ersätts med data från säkerhetskopian. Appen startar om.';

  @override
  String get noBackupFound => 'Ingen säkerhetskopia hittad på Google Drive';

  @override
  String get restoreSuccess =>
      'Återställd. Starta om appen för att börja använda.';

  @override
  String get signedIn => 'Inloggad';

  @override
  String get signInCancelled => 'Inloggning avbruten';

  @override
  String get signInError => 'Fel vid inloggning:';

  @override
  String get backupError => 'Fel vid säkerhetskopiering:';

  @override
  String get restoreError => 'Fel vid återställning:';

  @override
  String get backupDone => 'Säkerhetskopiering klar';

  @override
  String get onboarding1Title => 'Skapa grupper';

  @override
  String get onboarding1Desc =>
      'Börja med att skapa en grupp och lägg till elever.\nImportera från CSV eller lägg till manuellt.';

  @override
  String get onboarding2Title => 'Klassrumsläge';

  @override
  String get onboarding2Desc =>
      'Tryck på en elev för att registrera närvaro.\nTryck igen för frånvaro. Håll in för fler val.';

  @override
  String get onboarding3Title => 'Utflyktsläge';

  @override
  String get onboarding3Desc =>
      'Utformat för en-hands användning utomhus.\nSök efter elever med tre bokstäver — ett tryck registrerar.';

  @override
  String get onboarding4Title => 'Rapport';

  @override
  String get onboarding4Desc =>
      'Generera rapport med ett tryck.\nKopiera eller dela via e-post, SMS etc.';

  @override
  String get onboarding5Title => 'Säkert och privat';

  @override
  String get onboarding5Desc =>
      'All data lagras krypterad på din enhet.\nBiometriskt lås skyddar elevdata.\nFungerar helt utan internet.';

  @override
  String get trialExpired => 'Provperioden har gått ut';

  @override
  String get yearlySubscription => 'Årsprenumeration';

  @override
  String get yearlyPrice => '29 kr / år';

  @override
  String get featureUnlimitedGroups => 'Obegränsat antal grupper och elever';

  @override
  String get featureClassroomTrip => 'Klassrums- och utflyktsläge';

  @override
  String get featureReports => 'Rapporter och export';

  @override
  String get featureEncrypted => 'Krypterad lokal lagring';

  @override
  String get featureBiometric => 'Biometriskt lås';

  @override
  String get subscribeCta => 'Prenumerera — 29 kr/år';

  @override
  String get restorePurchase => 'Återställ tidigare köp';

  @override
  String get purchaseError => 'Kunde inte starta köp. Försök igen senare.';

  @override
  String get purchaseGenericError => 'Något gick fel:';

  @override
  String get noSubscriptionFound => 'Ingen tidigare prenumeration hittad.';

  @override
  String get restoreFailedError => 'Kunde inte återställa:';

  @override
  String get authenticateToOpen => 'Autentisera för att öppna appen';

  @override
  String get unlockApp => 'Lås upp';

  @override
  String get biometricReason => 'Lås upp Alla med';

  @override
  String get authFailed => 'Autentisering misslyckades';

  @override
  String get noArchivedGroups => 'Inga arkiverade grupper';

  @override
  String groupRestored(String name) {
    return '$name återställd';
  }

  @override
  String get groupNameLabel => 'Gruppnamn';

  @override
  String get groupNameHint => 't.ex. 10A, Utflykt Fjällen';

  @override
  String get renameGroup => 'Byt namn';

  @override
  String get copyGroup => 'Kopiera grupp';

  @override
  String get copyGroupSubtitle => 'Ny grupp med samma elever';

  @override
  String get splitGroupAction => 'Dela grupp';

  @override
  String get splitGroupSubtitle => 'Välj elever för ny undergrupp';

  @override
  String get archiveGroup => 'Arkivera grupp';

  @override
  String groupArchived(String name) {
    return '$name arkiverad';
  }

  @override
  String get undoAction => 'Ångra';

  @override
  String get renameGroupTitle => 'Ändra gruppnamn';

  @override
  String get copyGroupTitle => 'Kopiera grupp';

  @override
  String get newGroupNameLabel => 'Namn på ny grupp';

  @override
  String groupCopied(String name) {
    return '$name skapad';
  }

  @override
  String get splitGroupTitle => 'Dela grupp';

  @override
  String get splitGroupNewGroupHint => 't.ex. Utflyktsgrupp 1';

  @override
  String get selectStudentsForNewGroup => 'Välj elever för den nya gruppen:';

  @override
  String get selectAll => 'Välj alla';

  @override
  String get clearAll => 'Rensa alla';

  @override
  String selectedCount(int count) {
    return '$count valda';
  }

  @override
  String get createGroup => 'Skapa grupp';

  @override
  String groupCreatedWithStudents(String name, int count) {
    return '$name skapad med $count elever';
  }

  @override
  String get readingFile => 'Läser fil...';

  @override
  String get chooseFile => 'Välj fil (.xlsx, .csv)';

  @override
  String get orSeparator => 'eller';

  @override
  String get pasteStudentList => 'Klistra in elevlista (ett namn per rad)';

  @override
  String get importHint =>
      'Skriv namn i kolumn A. Efternamn kan läggas i kolumn B. Första raden kan vara rubrik — appen löser det automatiskt.';

  @override
  String get previewTitle => 'Förhandsgranskning';

  @override
  String foundStudentsCount(int count) {
    return 'Hittade $count elever';
  }

  @override
  String get headerSkipped => ' (rubrikrad hoppad över)';

  @override
  String get doesThisLookRight => 'Ser det här rätt ut?';

  @override
  String importCountStudents(int count) {
    return 'Importera $count elever';
  }

  @override
  String studentsImported(int count) {
    return '$count elever importerade';
  }

  @override
  String get couldNotReadFile => 'Kunde inte läsa filen';

  @override
  String get noNamesFound => 'Hittade inga namn i filen';

  @override
  String get startupError => 'Fel vid uppstart:';

  @override
  String get language => 'Språk';

  @override
  String get languageSystem => 'Systemstandard';
}
