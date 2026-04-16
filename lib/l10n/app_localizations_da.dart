// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get appTitle => 'Alle med';

  @override
  String get cancel => 'Annuller';

  @override
  String get save => 'Gem';

  @override
  String get next => 'Næste';

  @override
  String get skip => 'Spring over';

  @override
  String get getStarted => 'Kom i gang';

  @override
  String get create => 'Opret';

  @override
  String get importAction => 'Importer';

  @override
  String get back => 'Tilbage';

  @override
  String get restore => 'Gendan';

  @override
  String get remove => 'Fjern';

  @override
  String get report => 'Rapport';

  @override
  String get end => 'Afslut';

  @override
  String get copy => 'Kopier';

  @override
  String get statusUnknown => 'Ikke ankommet';

  @override
  String get statusPresent => 'Checket ind';

  @override
  String get statusAbsent => 'Fravær';

  @override
  String get statusLate => 'Forsinket';

  @override
  String get statusCheckedOut => 'Checket ud';

  @override
  String get statusPlannedAbsent => 'Planlagt fraværende';

  @override
  String get myGroups => 'Mine grupper';

  @override
  String get archivedGroups => 'Arkiverede grupper';

  @override
  String get settings => 'Indstillinger';

  @override
  String get noGroupsYet => 'Ingen grupper endnu';

  @override
  String get noGroupsDescription =>
      'Opret din første gruppe for at komme i gang.';

  @override
  String get newGroup => 'Ny gruppe';

  @override
  String studentCount(int count) {
    return '$count elever';
  }

  @override
  String get exportSemester => 'Eksporter semester';

  @override
  String get sessionHistory => 'Sessionshistorik';

  @override
  String get addStudent => 'Tilføj elev';

  @override
  String get importStudents => 'Importer elever';

  @override
  String get noStudentsInGroup => 'Ingen elever i gruppen';

  @override
  String get addStudentsManuallyOrImport =>
      'Tilføj elever manuelt eller importer fra fil.';

  @override
  String get startSession => 'Start registrering';

  @override
  String get sessionName => 'Sessionens navn (valgfrit)';

  @override
  String get sessionNameHint => 'f.eks. Fredagstræning, Tur til Himmelbjerget';

  @override
  String get noteLabel => 'Bemærkning';

  @override
  String get noteHint => 'Tilføj bemærkning...';

  @override
  String get classroom => 'Klasseværelse';

  @override
  String get trip => 'Tur';

  @override
  String get viewFinishedSessions => 'Vis afsluttede sessioner';

  @override
  String get activeSessionExistsTitle => 'Aktiv session findes';

  @override
  String get activeSessionExistsContent =>
      'Der findes allerede en aktiv session for denne gruppe. Vil du fortsætte den?';

  @override
  String get continueSession => 'Fortsæt';

  @override
  String get renameStudentTitle => 'Skift elevnavn';

  @override
  String get newNameHint => 'Nyt navn';

  @override
  String get removeStudentTitle => 'Fjern elev fra gruppen?';

  @override
  String removeStudentContent(String name) {
    return '$name fjernes fra denne gruppe. Elevens data og historik bevares.';
  }

  @override
  String historyTitle(String groupName) {
    return 'Historik — $groupName';
  }

  @override
  String get noFinishedSessions => 'Ingen afsluttede sessioner';

  @override
  String get finishedSessionsDescription =>
      'Afsluttede sessioner vises her, så du kan se rapport eller redigere fravær efterfølgende.';

  @override
  String get editAbsence => 'Rediger fravær';

  @override
  String classroomTitle(String groupName) {
    return '$groupName — Klasseværelse';
  }

  @override
  String tripTitle(String groupName) {
    return '$groupName — Tur';
  }

  @override
  String sessionTitle(String sessionName) {
    return '$sessionName';
  }

  @override
  String get tapChangeStatusHint =>
      'Tryk = check ind/ud · Hold inde = bemærkning og flere valg';

  @override
  String get phaseInnsjekk => 'Indtjekning';

  @override
  String get phaseUtsjekk => 'Udtjekning';

  @override
  String get switchToUtsjekk => 'Skift til udtjekning';

  @override
  String get switchToInnsjekk => '← Indtjekning';

  @override
  String get innsjekkHint =>
      'Tryk for at tjekke ind · Hold inde for bemærkning og fravær';

  @override
  String get utsjekkHint => 'Tryk for at tjekke ud · Hold inde for bemærkning';

  @override
  String get endSession => 'Afslut session';

  @override
  String get endSessionTitle => 'Afslut session?';

  @override
  String get endTripTitle => 'Afslut turregistrering?';

  @override
  String get reportStillAvailable =>
      'Du kan stadig se rapporten efter afslutning.';

  @override
  String get searchStudent => 'Søg efter elev...';

  @override
  String registeredCount(int registered, int total) {
    return '$registered / $total registreret';
  }

  @override
  String notRegisteredCount(int count) {
    return '$count ikke registreret';
  }

  @override
  String minutesLate(int minutes) {
    return '$minutes min forsinket';
  }

  @override
  String get lateLabel => 'Forsinket:';

  @override
  String get exportPdf => 'Eksporter PDF';

  @override
  String get copyToClipboard => 'Kopier til udklipsholder';

  @override
  String get shareReport => 'Del rapport';

  @override
  String get reportCopied => 'Rapport kopieret';

  @override
  String get copyReport => 'Kopier rapport';

  @override
  String get reportCopiedFull => 'Rapport kopieret til udklipsholder';

  @override
  String get shareVia => 'Del via...';

  @override
  String get pdfExportError => 'Fejl ved PDF-eksport:';

  @override
  String exportScreenTitle(String groupName) {
    return 'Eksporter — $groupName';
  }

  @override
  String get choosePeriod => 'Vælg periode';

  @override
  String get exportCsvDescription =>
      'Eksporterer CSV med alle sessioner i perioden. Én række per elev, én kolonne per session.';

  @override
  String get from => 'Fra';

  @override
  String get to => 'Til';

  @override
  String get csvLegend =>
      'Forklaring:\nT = Til stede · F = Fravær · S15 = Forsinket 15 min\nP = Planlagt fraværende · ? = Ikke registreret';

  @override
  String get exportCsv => 'Eksporter CSV';

  @override
  String get noSessionsInPeriod => 'Ingen sessioner i valgt periode.';

  @override
  String get exportError => 'Fejl ved eksport:';

  @override
  String get biometricLock => 'Biometrisk lås';

  @override
  String get biometricLockSubtitle =>
      'Kræv fingeraftryk eller ansigt ved opstart';

  @override
  String get backup => 'Sikkerhedskopi';

  @override
  String get backupSubtitle => 'Sikkerhedskopi til Google Drive';

  @override
  String get aboutApp => 'Om Alle med';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get loadingVersion => 'Indlæser version...';

  @override
  String get privacyTitle => 'Privatliv';

  @override
  String get privacySubtitle =>
      'Alle data gemmes krypteret lokalt på din enhed. Ingen data sendes til nogen server.';

  @override
  String get subscriptionActive => 'Abonnement aktivt';

  @override
  String get subscriptionActiveSubtitle => 'Årsabonnement — 29 kr/år';

  @override
  String get trialStatus => 'Prøveperiode';

  @override
  String get trialFree => 'Gratis i 30 dage';

  @override
  String trialDaysLeft(int days) {
    return '$days dage tilbage af prøveperioden';
  }

  @override
  String get subscriptionExpired => 'Abonnement udløbet';

  @override
  String get subscriptionExpiredSubtitle =>
      'Abonner for at fortsætte med at bruge appen';

  @override
  String get loadingStatus => 'Indlæser...';

  @override
  String get googleDriveBackup => 'Google Drive Sikkerhedskopi';

  @override
  String get backupDescription =>
      'Gem en krypteret kopi af din database på Google Drive. Kun du har adgang til sikkerhedskopien.';

  @override
  String lastBackup(String date) {
    return 'Seneste sikkerhedskopi: $date';
  }

  @override
  String get signInWithGoogle => 'Log ind med Google';

  @override
  String get takeBackupNow => 'Tag sikkerhedskopi nu';

  @override
  String get restoreFromBackup => 'Gendan fra sikkerhedskopi';

  @override
  String get restoreConfirmTitle => 'Gendan fra sikkerhedskopi?';

  @override
  String get restoreConfirmContent =>
      'Alle nuværende data erstattes med data fra sikkerhedskopien. Appen genstarter.';

  @override
  String get noBackupFound => 'Ingen sikkerhedskopi fundet på Google Drive';

  @override
  String get restoreSuccess => 'Gendannet. Genstart appen for at tage i brug.';

  @override
  String get signedIn => 'Logget ind';

  @override
  String get signInCancelled => 'Login annulleret';

  @override
  String get signInError => 'Fejl ved login:';

  @override
  String get backupError => 'Fejl ved sikkerhedskopi:';

  @override
  String get restoreError => 'Fejl ved gendannelse:';

  @override
  String get backupDone => 'Sikkerhedskopi fuldført';

  @override
  String get onboarding1Title => 'Opret grupper';

  @override
  String get onboarding1Desc =>
      'Start med at oprette en gruppe og tilføj elever.\nImporter fra CSV eller tilføj manuelt.';

  @override
  String get onboarding2Title => 'Klasseværelsestilstand';

  @override
  String get onboarding2Desc =>
      'Tryk på en elev for at registrere til stede.\nTryk igen for fravær. Hold inde for flere valg.';

  @override
  String get onboarding3Title => 'Tur-tilstand';

  @override
  String get onboarding3Desc =>
      'Designet til en-hånds brug udendørs.\nSøg efter elever med tre bogstaver — ét tryk registrerer.';

  @override
  String get onboarding4Title => 'Rapport';

  @override
  String get onboarding4Desc =>
      'Generer rapport med ét tryk.\nKopier eller del via e-mail, SMS osv.';

  @override
  String get onboarding5Title => 'Sikkert og privat';

  @override
  String get onboarding5Desc =>
      'Alle data gemmes krypteret på din enhed.\nBiometrisk lås beskytter elevdata.\nFungerer helt uden internet.';

  @override
  String get trialExpired => 'Prøveperioden er udløbet';

  @override
  String get yearlySubscription => 'Årsabonnement';

  @override
  String get yearlyPrice => '29 kr / år';

  @override
  String get featureUnlimitedGroups => 'Ubegrænset antal grupper og elever';

  @override
  String get featureClassroomTrip => 'Klasseværelses- og tur-tilstand';

  @override
  String get featureReports => 'Rapporter og eksport';

  @override
  String get featureEncrypted => 'Krypteret lokal lagring';

  @override
  String get featureBiometric => 'Biometrisk lås';

  @override
  String get subscribeCta => 'Abonner — 29 kr/år';

  @override
  String get restorePurchase => 'Gendan tidligere køb';

  @override
  String get purchaseError => 'Kunne ikke starte køb. Prøv igen senere.';

  @override
  String get purchaseGenericError => 'Noget gik galt:';

  @override
  String get noSubscriptionFound => 'Ingen tidligere abonnement fundet.';

  @override
  String get restoreFailedError => 'Kunne ikke gendanne:';

  @override
  String get authenticateToOpen => 'Godkend for at åbne appen';

  @override
  String get unlockApp => 'Lås op';

  @override
  String get biometricReason => 'Lås op Alle med';

  @override
  String get authFailed => 'Godkendelse mislykkedes';

  @override
  String get noArchivedGroups => 'Ingen arkiverede grupper';

  @override
  String groupRestored(String name) {
    return '$name gendannet';
  }

  @override
  String get groupNameLabel => 'Gruppenavn';

  @override
  String get groupNameHint => 'f.eks. 10A, Tur Naturpark';

  @override
  String get renameGroup => 'Skift navn';

  @override
  String get copyGroup => 'Kopier gruppe';

  @override
  String get copyGroupSubtitle => 'Ny gruppe med samme elever';

  @override
  String get splitGroupAction => 'Del gruppe';

  @override
  String get splitGroupSubtitle => 'Vælg elever til ny undergruppe';

  @override
  String get archiveGroup => 'Arkiver gruppe';

  @override
  String groupArchived(String name) {
    return '$name arkiveret';
  }

  @override
  String get undoAction => 'Fortryd';

  @override
  String get renameGroupTitle => 'Skift gruppenavn';

  @override
  String get copyGroupTitle => 'Kopier gruppe';

  @override
  String get newGroupNameLabel => 'Navn på ny gruppe';

  @override
  String groupCopied(String name) {
    return '$name oprettet';
  }

  @override
  String get splitGroupTitle => 'Del gruppe';

  @override
  String get splitGroupNewGroupHint => 'f.eks. Turgruppe 1';

  @override
  String get selectStudentsForNewGroup => 'Vælg elever til den nye gruppe:';

  @override
  String get selectAll => 'Vælg alle';

  @override
  String get clearAll => 'Ryd alle';

  @override
  String selectedCount(int count) {
    return '$count valgt';
  }

  @override
  String get createGroup => 'Opret gruppe';

  @override
  String groupCreatedWithStudents(String name, int count) {
    return '$name oprettet med $count elever';
  }

  @override
  String get readingFile => 'Læser fil...';

  @override
  String get chooseFile => 'Vælg fil (.xlsx, .csv)';

  @override
  String get orSeparator => 'eller';

  @override
  String get pasteStudentList => 'Indsæt elevliste (ét navn per linje)';

  @override
  String get importHint =>
      'Skriv navn i kolonne A. Efternavn kan placeres i kolonne B. Første række kan være overskrift — appen finder ud af det automatisk.';

  @override
  String get previewTitle => 'Forhåndsvisning';

  @override
  String foundStudentsCount(int count) {
    return 'Fandt $count elever';
  }

  @override
  String get headerSkipped => ' (overskriftsrække sprunget over)';

  @override
  String get doesThisLookRight => 'Ser dette rigtigt ud?';

  @override
  String importCountStudents(int count) {
    return 'Importer $count elever';
  }

  @override
  String studentsImported(int count) {
    return '$count elever importeret';
  }

  @override
  String get couldNotReadFile => 'Kunne ikke læse filen';

  @override
  String get noNamesFound => 'Fandt ingen navne i filen';

  @override
  String get startupError => 'Fejl ved opstart:';

  @override
  String get language => 'Sprog';

  @override
  String get languageSystem => 'Systemstandard';
}
