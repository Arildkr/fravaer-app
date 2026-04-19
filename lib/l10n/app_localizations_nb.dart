// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get appTitle => 'Alle med';

  @override
  String get cancel => 'Avbryt';

  @override
  String get save => 'Lagre';

  @override
  String get next => 'Neste';

  @override
  String get skip => 'Hopp over';

  @override
  String get getStarted => 'Kom i gang';

  @override
  String get create => 'Opprett';

  @override
  String get importAction => 'Importer';

  @override
  String get back => 'Tilbake';

  @override
  String get restore => 'Gjenopprett';

  @override
  String get remove => 'Fjern';

  @override
  String get report => 'Rapport';

  @override
  String get end => 'Avslutt';

  @override
  String get copy => 'Kopier';

  @override
  String get statusUnknown => 'Ikke møtt';

  @override
  String get statusPresent => 'Innsjekket';

  @override
  String get statusAbsent => 'Fravær';

  @override
  String get statusLate => 'Forsinket';

  @override
  String get statusCheckedOut => 'Utsjekket';

  @override
  String get statusPlannedAbsent => 'Planlagt borte';

  @override
  String get myGroups => 'Mine grupper';

  @override
  String get archivedGroups => 'Arkiverte grupper';

  @override
  String get settings => 'Innstillinger';

  @override
  String get noGroupsYet => 'Ingen grupper ennå';

  @override
  String get noGroupsDescription =>
      'Opprett din første gruppe for å komme i gang.';

  @override
  String get newGroup => 'Ny gruppe';

  @override
  String studentCount(int count) {
    return '$count elever';
  }

  @override
  String get exportSemester => 'Eksporter semester';

  @override
  String get sessionHistory => 'Økthistorikk';

  @override
  String get addStudent => 'Legg til elev';

  @override
  String get importStudents => 'Importer elever';

  @override
  String get noStudentsInGroup => 'Ingen elever i gruppen';

  @override
  String get addStudentsManuallyOrImport =>
      'Legg til elever manuelt eller importer fra fil.';

  @override
  String get startSession => 'Start registrering';

  @override
  String get sessionName => 'Navn på registreringen (valgfritt)';

  @override
  String get sessionNameHint => 'f.eks. Fredagstrening, Tur til Gaustatoppen';

  @override
  String get noteLabel => 'Merknad';

  @override
  String get noteHint => 'Legg til merknad...';

  @override
  String get classroom => 'Klasserom';

  @override
  String get trip => 'Tur';

  @override
  String get viewFinishedSessions => 'Vis avsluttede økter';

  @override
  String get activeSessionExistsTitle => 'Aktiv økt finnes';

  @override
  String get activeSessionExistsContent =>
      'Det finnes allerede en aktiv økt for denne gruppen. Vil du fortsette den?';

  @override
  String get continueSession => 'Fortsett';

  @override
  String get renameStudentTitle => 'Endre elevnavn';

  @override
  String get newNameHint => 'Nytt navn';

  @override
  String get removeStudentTitle => 'Fjern elev fra gruppen?';

  @override
  String removeStudentContent(String name) {
    return '$name fjernes fra denne gruppen. Elevens data og historikk beholdes.';
  }

  @override
  String historyTitle(String groupName) {
    return 'Historikk — $groupName';
  }

  @override
  String get noFinishedSessions => 'Ingen avsluttede økter';

  @override
  String get finishedSessionsDescription =>
      'Avsluttede økter vises her slik at du kan se rapport eller redigere fravær i ettertid.';

  @override
  String get editAbsence => 'Rediger fravær';

  @override
  String classroomTitle(String groupName) {
    return '$groupName — Klasserom';
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
      'Trykk = innsjekk/utsjekk · Hold inne = merknad og flere valg';

  @override
  String get phaseInnsjekk => 'Innsjekk';

  @override
  String get phaseUtsjekk => 'Utsjekk';

  @override
  String get switchToUtsjekk => 'Bytt til utsjekk';

  @override
  String get switchToInnsjekk => '← Innsjekk';

  @override
  String get innsjekkHint =>
      'Trykk for å sjekke inn · Hold inne for merknad og fravær';

  @override
  String get utsjekkHint => 'Trykk for å sjekke ut · Hold inne for merknad';

  @override
  String get endSession => 'Avslutt økt';

  @override
  String get endSessionTitle => 'Avslutt økt?';

  @override
  String get endTripTitle => 'Avslutt turregistrering?';

  @override
  String get reportStillAvailable =>
      'Du kan fortsatt se rapporten etter avslutning.';

  @override
  String get searchStudent => 'Søk etter elev...';

  @override
  String registeredCount(int registered, int total) {
    return '$registered / $total registrert';
  }

  @override
  String notRegisteredCount(int count) {
    return '$count ikke registrert';
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
  String get copyToClipboard => 'Kopier til utklippstavle';

  @override
  String get shareReport => 'Del rapport';

  @override
  String get reportCopied => 'Rapport kopiert';

  @override
  String get copyReport => 'Kopier rapport';

  @override
  String get reportCopiedFull => 'Rapport kopiert til utklippstavle';

  @override
  String get shareVia => 'Del via...';

  @override
  String get pdfExportError => 'Feil ved PDF-eksport:';

  @override
  String exportScreenTitle(String groupName) {
    return 'Eksporter — $groupName';
  }

  @override
  String get choosePeriod => 'Velg periode';

  @override
  String get exportCsvDescription =>
      'Eksporterer CSV med alle økter i perioden. Én rad per elev, én kolonne per økt.';

  @override
  String get from => 'Fra';

  @override
  String get to => 'Til';

  @override
  String get csvLegend =>
      'Forklaring:\nI = Innsjekket · F = Fravær · S15 = Forsinket 15 min\nU = Utsjekket · ? = Ikke registrert';

  @override
  String get exportCsv => 'Eksporter CSV';

  @override
  String get noSessionsInPeriod => 'Ingen økter i valgt periode.';

  @override
  String get exportError => 'Feil ved eksport:';

  @override
  String get biometricLock => 'Biometrisk lås';

  @override
  String get biometricLockSubtitle =>
      'Krev fingeravtrykk eller ansikt ved oppstart';

  @override
  String get backup => 'Backup';

  @override
  String get backupSubtitle => 'Sikkerhetskopi til Google Drive';

  @override
  String get aboutApp => 'Om Alle med';

  @override
  String versionLabel(String version) {
    return 'Versjon $version';
  }

  @override
  String get loadingVersion => 'Laster versjon...';

  @override
  String get privacyTitle => 'Personvern';

  @override
  String get privacySubtitle =>
      'All data lagres kryptert lokalt på din enhet. Ingen data sendes til noen server.';

  @override
  String get subscriptionActive => 'Abonnement aktivt';

  @override
  String get subscriptionActiveSubtitle => 'Årsabonnement — 29 kr/år';

  @override
  String get trialStatus => 'Prøveperiode';

  @override
  String get trialFree => 'Gratis i 30 dager';

  @override
  String trialDaysLeft(int days) {
    return '$days dager igjen av prøveperioden';
  }

  @override
  String get subscriptionExpired => 'Abonnement utløpt';

  @override
  String get subscriptionExpiredSubtitle =>
      'Abonner for å fortsette å bruke appen';

  @override
  String get loadingStatus => 'Laster...';

  @override
  String get googleDriveBackup => 'Google Drive Backup';

  @override
  String get backupDescription =>
      'Lagre en kryptert kopi av databasen din på Google Drive. Kun du har tilgang til backupen.';

  @override
  String lastBackup(String date) {
    return 'Siste backup: $date';
  }

  @override
  String get signInWithGoogle => 'Logg inn med Google';

  @override
  String get takeBackupNow => 'Ta backup nå';

  @override
  String get restoreFromBackup => 'Gjenopprett fra backup';

  @override
  String get restoreConfirmTitle => 'Gjenopprett fra backup?';

  @override
  String get restoreConfirmContent =>
      'All nåværende data erstattes med dataen fra backup. Appen vil starte på nytt.';

  @override
  String get noBackupFound => 'Ingen backup funnet på Google Drive';

  @override
  String get restoreSuccess =>
      'Gjenopprettet. Start appen på nytt for å ta i bruk.';

  @override
  String get signedIn => 'Logget inn';

  @override
  String get signInCancelled => 'Innlogging avbrutt';

  @override
  String get signInError => 'Feil ved innlogging:';

  @override
  String get backupError => 'Feil ved backup:';

  @override
  String get restoreError => 'Feil ved gjenoppretting:';

  @override
  String get backupDone => 'Backup fullført';

  @override
  String get onboarding1Title => 'Opprett grupper';

  @override
  String get onboarding1Desc =>
      'Start med å opprette en gruppe og legg til elever.\nImporter fra CSV eller legg til manuelt.';

  @override
  String get onboarding2Title => 'Innsjekk og utsjekk';

  @override
  String get onboarding2Desc =>
      'Trykk én gang for å sjekke inn en person.\nTrykk igjen for å sjekke ut. Søk etter navn øverst.';

  @override
  String get onboarding3Title => 'Merknader og fravær';

  @override
  String get onboarding3Desc =>
      'Hold inne på en person for merknad eller andre statuser.\nMerknader vises i rapporten.';

  @override
  String get onboarding4Title => 'Rapport';

  @override
  String get onboarding4Desc =>
      'Generer rapport med ett trykk.\nKopier eller del via e-post, SMS etc.';

  @override
  String get onboarding5Title => 'Trygt og privat';

  @override
  String get onboarding5Desc =>
      'All data lagres kryptert på din enhet.\nBiometrisk lås beskytter elevdata.\nFungerer helt uten internett.';

  @override
  String get trialExpired => 'Prøveperioden er utløpt';

  @override
  String get yearlySubscription => 'Årsabonnement';

  @override
  String get yearlyPrice => '29 kr / år';

  @override
  String get featureUnlimitedGroups => 'Ubegrenset antall grupper og elever';

  @override
  String get featureClassroomTrip => 'Innsjekk og utsjekk med merknader';

  @override
  String get featureReports => 'Rapporter og eksport';

  @override
  String get featureEncrypted => 'Kryptert lokal lagring';

  @override
  String get featureBiometric => 'Biometrisk lås';

  @override
  String get subscribeCta => 'Abonner — 29 kr/år';

  @override
  String get restorePurchase => 'Gjenopprett tidligere kjøp';

  @override
  String get purchaseError => 'Kunne ikke starte kjøp. Prøv igjen senere.';

  @override
  String get purchaseGenericError => 'Noe gikk galt:';

  @override
  String get noSubscriptionFound => 'Ingen tidligere abonnement funnet.';

  @override
  String get restoreFailedError => 'Kunne ikke gjenopprette:';

  @override
  String get authenticateToOpen => 'Autentiser for å åpne appen';

  @override
  String get unlockApp => 'Lås opp';

  @override
  String get biometricReason => 'Lås opp Alle med';

  @override
  String get authFailed => 'Autentisering mislyktes';

  @override
  String get noArchivedGroups => 'Ingen arkiverte grupper';

  @override
  String groupRestored(String name) {
    return '$name gjenopprettet';
  }

  @override
  String get groupNameLabel => 'Gruppenavn';

  @override
  String get groupNameHint => 'f.eks. 10A, Tur Hardangervidda';

  @override
  String get renameGroup => 'Endre navn';

  @override
  String get copyGroup => 'Kopier gruppe';

  @override
  String get copyGroupSubtitle => 'Ny gruppe med samme elever';

  @override
  String get splitGroupAction => 'Del gruppe';

  @override
  String get splitGroupSubtitle => 'Velg elever for ny undergruppe';

  @override
  String get archiveGroup => 'Arkiver gruppe';

  @override
  String groupArchived(String name) {
    return '$name arkivert';
  }

  @override
  String get undoAction => 'Angre';

  @override
  String get renameGroupTitle => 'Endre gruppenavn';

  @override
  String get copyGroupTitle => 'Kopier gruppe';

  @override
  String get newGroupNameLabel => 'Navn på ny gruppe';

  @override
  String groupCopied(String name) {
    return '$name opprettet';
  }

  @override
  String get splitGroupTitle => 'Del gruppe';

  @override
  String get splitGroupNewGroupHint => 'f.eks. Turgruppe 1';

  @override
  String get selectStudentsForNewGroup => 'Velg elever for den nye gruppen:';

  @override
  String get selectAll => 'Velg alle';

  @override
  String get clearAll => 'Fjern alle';

  @override
  String selectedCount(int count) {
    return '$count valgt';
  }

  @override
  String get createGroup => 'Opprett gruppe';

  @override
  String groupCreatedWithStudents(String name, int count) {
    return '$name opprettet med $count elever';
  }

  @override
  String get readingFile => 'Leser fil...';

  @override
  String get chooseFile => 'Velg fil (.xlsx, .csv)';

  @override
  String get orSeparator => 'eller';

  @override
  String get pasteStudentList => 'Lim inn elevliste (ett navn per linje)';

  @override
  String get importHint =>
      'Skriv navn i kolonne A. Etternavn kan legges i kolonne B. Første rad kan være overskrift — appen finner ut av det automatisk.';

  @override
  String get previewTitle => 'Forhåndsvisning';

  @override
  String foundStudentsCount(int count) {
    return 'Fant $count elever';
  }

  @override
  String get headerSkipped => ' (overskriftsrad hoppet over)';

  @override
  String get doesThisLookRight => 'Ser dette riktig ut?';

  @override
  String importCountStudents(int count) {
    return 'Importer $count elever';
  }

  @override
  String studentsImported(int count) {
    return '$count elever importert';
  }

  @override
  String get couldNotReadFile => 'Kunne ikke lese filen';

  @override
  String get noNamesFound => 'Fant ingen navn i filen';

  @override
  String get startupError => 'Feil ved oppstart:';

  @override
  String get language => 'Språk';

  @override
  String get languageSystem => 'Systemstandard';

  @override
  String get shareSession => 'Del økt';

  @override
  String get joinSession => 'Bli med i økt';

  @override
  String get sharingConsentTitle => 'Deling av fraværsdata';

  @override
  String get sharingConsentBody =>
      'Elevnavn og oppmøtestatus vil midlertidig lagres i skyen (Google Firebase) under delingen. Dataene slettes automatisk når du avslutter deling.';

  @override
  String get sharingFirstNamesHint =>
      'Anbefaling: bruk kun fornavn i elevlisten for å minimere personopplysningene som deles.';

  @override
  String get sharingResponsibility =>
      'Du er selv ansvarlig for at delingen er i tråd med skolens retningslinjer og GDPR.';

  @override
  String get sharingConsentAccept => 'Jeg forstår, del økt';

  @override
  String get shareSessionTitle => 'Del denne økten';

  @override
  String get shareSessionInstructions =>
      'Del denne koden med kolleger som skal registrere fravær i samme økt:';

  @override
  String get tapToCopy => 'Trykk på koden for å kopiere';

  @override
  String get codeCopied => 'Kode kopiert';

  @override
  String get stopSharing => 'Stopp deling og slett skydata';

  @override
  String get stopSharingTitle => 'Stopp deling?';

  @override
  String get stopSharingConfirm =>
      'All skydata for denne økten slettes umiddelbart. Din lokale kopi beholdes.';

  @override
  String get stopSharingDone => 'Deling stoppet og skydata slettet';

  @override
  String get close => 'Lukk';

  @override
  String get joinSessionTitle => 'Bli med i økt';

  @override
  String get joinSessionCodeHint =>
      'Skriv inn invitasjonskoden du har mottatt:';

  @override
  String get invalidCode => 'Koden må være 6 tegn';

  @override
  String get codeNotFound =>
      'Koden ble ikke funnet. Sjekk at den er riktig og at økten fortsatt er aktiv.';

  @override
  String get sharingError =>
      'Noe gikk galt. Sjekk internettforbindelsen og prøv igjen.';

  @override
  String joinSessionConfirmGroup(String name) {
    return 'Gruppe: $name';
  }

  @override
  String joinSessionStudentCount(int count) {
    return '$count elever';
  }

  @override
  String get joinSessionGroupKept =>
      'Gruppen lagres lokalt på din enhet og kan brukes til fremtidige egne økter.';

  @override
  String get joinSessionAccept => 'Bli med';

  @override
  String get activeSharingBanner => 'Aktiv deling — data er i skyen';

  @override
  String sharingMemberCount(int count) {
    return 'Deler med $count kollega(er)';
  }
}
