import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_da.dart';
import 'app_localizations_en.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_sv.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('da'),
    Locale('en'),
    Locale('nb'),
    Locale('sv')
  ];

  /// No description provided for @appTitle.
  ///
  /// In nb, this message translates to:
  /// **'Alle med'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In nb, this message translates to:
  /// **'Avbryt'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In nb, this message translates to:
  /// **'Lagre'**
  String get save;

  /// No description provided for @next.
  ///
  /// In nb, this message translates to:
  /// **'Neste'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In nb, this message translates to:
  /// **'Hopp over'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In nb, this message translates to:
  /// **'Kom i gang'**
  String get getStarted;

  /// No description provided for @create.
  ///
  /// In nb, this message translates to:
  /// **'Opprett'**
  String get create;

  /// No description provided for @importAction.
  ///
  /// In nb, this message translates to:
  /// **'Importer'**
  String get importAction;

  /// No description provided for @back.
  ///
  /// In nb, this message translates to:
  /// **'Tilbake'**
  String get back;

  /// No description provided for @restore.
  ///
  /// In nb, this message translates to:
  /// **'Gjenopprett'**
  String get restore;

  /// No description provided for @remove.
  ///
  /// In nb, this message translates to:
  /// **'Fjern'**
  String get remove;

  /// No description provided for @report.
  ///
  /// In nb, this message translates to:
  /// **'Rapport'**
  String get report;

  /// No description provided for @end.
  ///
  /// In nb, this message translates to:
  /// **'Avslutt'**
  String get end;

  /// No description provided for @copy.
  ///
  /// In nb, this message translates to:
  /// **'Kopier'**
  String get copy;

  /// No description provided for @statusUnknown.
  ///
  /// In nb, this message translates to:
  /// **'Ikke møtt'**
  String get statusUnknown;

  /// No description provided for @statusPresent.
  ///
  /// In nb, this message translates to:
  /// **'Innsjekket'**
  String get statusPresent;

  /// No description provided for @statusAbsent.
  ///
  /// In nb, this message translates to:
  /// **'Fravær'**
  String get statusAbsent;

  /// No description provided for @statusLate.
  ///
  /// In nb, this message translates to:
  /// **'Forsinket'**
  String get statusLate;

  /// No description provided for @statusCheckedOut.
  ///
  /// In nb, this message translates to:
  /// **'Utsjekket'**
  String get statusCheckedOut;

  /// No description provided for @statusPlannedAbsent.
  ///
  /// In nb, this message translates to:
  /// **'Planlagt borte'**
  String get statusPlannedAbsent;

  /// No description provided for @myGroups.
  ///
  /// In nb, this message translates to:
  /// **'Mine grupper'**
  String get myGroups;

  /// No description provided for @archivedGroups.
  ///
  /// In nb, this message translates to:
  /// **'Arkiverte grupper'**
  String get archivedGroups;

  /// No description provided for @settings.
  ///
  /// In nb, this message translates to:
  /// **'Innstillinger'**
  String get settings;

  /// No description provided for @noGroupsYet.
  ///
  /// In nb, this message translates to:
  /// **'Ingen grupper ennå'**
  String get noGroupsYet;

  /// No description provided for @noGroupsDescription.
  ///
  /// In nb, this message translates to:
  /// **'Opprett din første gruppe for å komme i gang.'**
  String get noGroupsDescription;

  /// No description provided for @newGroup.
  ///
  /// In nb, this message translates to:
  /// **'Ny gruppe'**
  String get newGroup;

  /// No description provided for @studentCount.
  ///
  /// In nb, this message translates to:
  /// **'{count} elever'**
  String studentCount(int count);

  /// No description provided for @exportSemester.
  ///
  /// In nb, this message translates to:
  /// **'Eksporter semester'**
  String get exportSemester;

  /// No description provided for @sessionHistory.
  ///
  /// In nb, this message translates to:
  /// **'Økthistorikk'**
  String get sessionHistory;

  /// No description provided for @addStudent.
  ///
  /// In nb, this message translates to:
  /// **'Legg til elev'**
  String get addStudent;

  /// No description provided for @importStudents.
  ///
  /// In nb, this message translates to:
  /// **'Importer elever'**
  String get importStudents;

  /// No description provided for @noStudentsInGroup.
  ///
  /// In nb, this message translates to:
  /// **'Ingen elever i gruppen'**
  String get noStudentsInGroup;

  /// No description provided for @addStudentsManuallyOrImport.
  ///
  /// In nb, this message translates to:
  /// **'Legg til elever manuelt eller importer fra fil.'**
  String get addStudentsManuallyOrImport;

  /// No description provided for @startSession.
  ///
  /// In nb, this message translates to:
  /// **'Start registrering'**
  String get startSession;

  /// No description provided for @sessionName.
  ///
  /// In nb, this message translates to:
  /// **'Navn på registreringen (valgfritt)'**
  String get sessionName;

  /// No description provided for @sessionNameHint.
  ///
  /// In nb, this message translates to:
  /// **'f.eks. Fredagstrening, Tur til Gaustatoppen'**
  String get sessionNameHint;

  /// No description provided for @noteLabel.
  ///
  /// In nb, this message translates to:
  /// **'Merknad'**
  String get noteLabel;

  /// No description provided for @noteHint.
  ///
  /// In nb, this message translates to:
  /// **'Legg til merknad...'**
  String get noteHint;

  /// No description provided for @classroom.
  ///
  /// In nb, this message translates to:
  /// **'Klasserom'**
  String get classroom;

  /// No description provided for @trip.
  ///
  /// In nb, this message translates to:
  /// **'Tur'**
  String get trip;

  /// No description provided for @viewFinishedSessions.
  ///
  /// In nb, this message translates to:
  /// **'Vis avsluttede økter'**
  String get viewFinishedSessions;

  /// No description provided for @activeSessionExistsTitle.
  ///
  /// In nb, this message translates to:
  /// **'Aktiv økt finnes'**
  String get activeSessionExistsTitle;

  /// No description provided for @activeSessionExistsContent.
  ///
  /// In nb, this message translates to:
  /// **'Det finnes allerede en aktiv økt for denne gruppen. Vil du fortsette den?'**
  String get activeSessionExistsContent;

  /// No description provided for @continueSession.
  ///
  /// In nb, this message translates to:
  /// **'Fortsett'**
  String get continueSession;

  /// No description provided for @renameStudentTitle.
  ///
  /// In nb, this message translates to:
  /// **'Endre elevnavn'**
  String get renameStudentTitle;

  /// No description provided for @newNameHint.
  ///
  /// In nb, this message translates to:
  /// **'Nytt navn'**
  String get newNameHint;

  /// No description provided for @removeStudentTitle.
  ///
  /// In nb, this message translates to:
  /// **'Fjern elev fra gruppen?'**
  String get removeStudentTitle;

  /// No description provided for @removeStudentContent.
  ///
  /// In nb, this message translates to:
  /// **'{name} fjernes fra denne gruppen. Elevens data og historikk beholdes.'**
  String removeStudentContent(String name);

  /// No description provided for @historyTitle.
  ///
  /// In nb, this message translates to:
  /// **'Historikk — {groupName}'**
  String historyTitle(String groupName);

  /// No description provided for @noFinishedSessions.
  ///
  /// In nb, this message translates to:
  /// **'Ingen avsluttede økter'**
  String get noFinishedSessions;

  /// No description provided for @finishedSessionsDescription.
  ///
  /// In nb, this message translates to:
  /// **'Avsluttede økter vises her slik at du kan se rapport eller redigere fravær i ettertid.'**
  String get finishedSessionsDescription;

  /// No description provided for @editAbsence.
  ///
  /// In nb, this message translates to:
  /// **'Rediger fravær'**
  String get editAbsence;

  /// No description provided for @classroomTitle.
  ///
  /// In nb, this message translates to:
  /// **'{groupName} — Klasserom'**
  String classroomTitle(String groupName);

  /// No description provided for @tripTitle.
  ///
  /// In nb, this message translates to:
  /// **'{groupName} — Tur'**
  String tripTitle(String groupName);

  /// No description provided for @sessionTitle.
  ///
  /// In nb, this message translates to:
  /// **'{sessionName}'**
  String sessionTitle(String sessionName);

  /// No description provided for @tapChangeStatusHint.
  ///
  /// In nb, this message translates to:
  /// **'Trykk = innsjekk/utsjekk · Hold inne = merknad og flere valg'**
  String get tapChangeStatusHint;

  /// No description provided for @phaseInnsjekk.
  ///
  /// In nb, this message translates to:
  /// **'Innsjekk'**
  String get phaseInnsjekk;

  /// No description provided for @phaseUtsjekk.
  ///
  /// In nb, this message translates to:
  /// **'Utsjekk'**
  String get phaseUtsjekk;

  /// No description provided for @switchToUtsjekk.
  ///
  /// In nb, this message translates to:
  /// **'Bytt til utsjekk'**
  String get switchToUtsjekk;

  /// No description provided for @switchToInnsjekk.
  ///
  /// In nb, this message translates to:
  /// **'← Innsjekk'**
  String get switchToInnsjekk;

  /// No description provided for @innsjekkHint.
  ///
  /// In nb, this message translates to:
  /// **'Trykk for å sjekke inn · Hold inne for merknad og fravær'**
  String get innsjekkHint;

  /// No description provided for @utsjekkHint.
  ///
  /// In nb, this message translates to:
  /// **'Trykk for å sjekke ut · Hold inne for merknad'**
  String get utsjekkHint;

  /// No description provided for @endSession.
  ///
  /// In nb, this message translates to:
  /// **'Avslutt økt'**
  String get endSession;

  /// No description provided for @endSessionTitle.
  ///
  /// In nb, this message translates to:
  /// **'Avslutt økt?'**
  String get endSessionTitle;

  /// No description provided for @endTripTitle.
  ///
  /// In nb, this message translates to:
  /// **'Avslutt turregistrering?'**
  String get endTripTitle;

  /// No description provided for @reportStillAvailable.
  ///
  /// In nb, this message translates to:
  /// **'Du kan fortsatt se rapporten etter avslutning.'**
  String get reportStillAvailable;

  /// No description provided for @searchStudent.
  ///
  /// In nb, this message translates to:
  /// **'Søk etter elev...'**
  String get searchStudent;

  /// No description provided for @registeredCount.
  ///
  /// In nb, this message translates to:
  /// **'{registered} / {total} registrert'**
  String registeredCount(int registered, int total);

  /// No description provided for @notRegisteredCount.
  ///
  /// In nb, this message translates to:
  /// **'{count} ikke registrert'**
  String notRegisteredCount(int count);

  /// No description provided for @minutesLate.
  ///
  /// In nb, this message translates to:
  /// **'{minutes} min forsinket'**
  String minutesLate(int minutes);

  /// No description provided for @lateLabel.
  ///
  /// In nb, this message translates to:
  /// **'Forsinket:'**
  String get lateLabel;

  /// No description provided for @exportPdf.
  ///
  /// In nb, this message translates to:
  /// **'Eksporter PDF'**
  String get exportPdf;

  /// No description provided for @copyToClipboard.
  ///
  /// In nb, this message translates to:
  /// **'Kopier til utklippstavle'**
  String get copyToClipboard;

  /// No description provided for @shareReport.
  ///
  /// In nb, this message translates to:
  /// **'Del rapport'**
  String get shareReport;

  /// No description provided for @reportCopied.
  ///
  /// In nb, this message translates to:
  /// **'Rapport kopiert'**
  String get reportCopied;

  /// No description provided for @copyReport.
  ///
  /// In nb, this message translates to:
  /// **'Kopier rapport'**
  String get copyReport;

  /// No description provided for @reportCopiedFull.
  ///
  /// In nb, this message translates to:
  /// **'Rapport kopiert til utklippstavle'**
  String get reportCopiedFull;

  /// No description provided for @shareVia.
  ///
  /// In nb, this message translates to:
  /// **'Del via...'**
  String get shareVia;

  /// No description provided for @pdfExportError.
  ///
  /// In nb, this message translates to:
  /// **'Feil ved PDF-eksport:'**
  String get pdfExportError;

  /// No description provided for @exportScreenTitle.
  ///
  /// In nb, this message translates to:
  /// **'Eksporter — {groupName}'**
  String exportScreenTitle(String groupName);

  /// No description provided for @choosePeriod.
  ///
  /// In nb, this message translates to:
  /// **'Velg periode'**
  String get choosePeriod;

  /// No description provided for @exportCsvDescription.
  ///
  /// In nb, this message translates to:
  /// **'Eksporterer CSV med alle økter i perioden. Én rad per elev, én kolonne per økt.'**
  String get exportCsvDescription;

  /// No description provided for @from.
  ///
  /// In nb, this message translates to:
  /// **'Fra'**
  String get from;

  /// No description provided for @to.
  ///
  /// In nb, this message translates to:
  /// **'Til'**
  String get to;

  /// No description provided for @csvLegend.
  ///
  /// In nb, this message translates to:
  /// **'Forklaring:\nI = Innsjekket · F = Fravær · S15 = Forsinket 15 min\nU = Utsjekket · ? = Ikke registrert'**
  String get csvLegend;

  /// No description provided for @exportCsv.
  ///
  /// In nb, this message translates to:
  /// **'Eksporter CSV'**
  String get exportCsv;

  /// No description provided for @noSessionsInPeriod.
  ///
  /// In nb, this message translates to:
  /// **'Ingen økter i valgt periode.'**
  String get noSessionsInPeriod;

  /// No description provided for @exportError.
  ///
  /// In nb, this message translates to:
  /// **'Feil ved eksport:'**
  String get exportError;

  /// No description provided for @biometricLock.
  ///
  /// In nb, this message translates to:
  /// **'Biometrisk lås'**
  String get biometricLock;

  /// No description provided for @biometricLockSubtitle.
  ///
  /// In nb, this message translates to:
  /// **'Krev fingeravtrykk eller ansikt ved oppstart'**
  String get biometricLockSubtitle;

  /// No description provided for @backup.
  ///
  /// In nb, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @backupSubtitle.
  ///
  /// In nb, this message translates to:
  /// **'Sikkerhetskopi til Google Drive'**
  String get backupSubtitle;

  /// No description provided for @aboutApp.
  ///
  /// In nb, this message translates to:
  /// **'Om Alle med'**
  String get aboutApp;

  /// No description provided for @versionLabel.
  ///
  /// In nb, this message translates to:
  /// **'Versjon {version}'**
  String versionLabel(String version);

  /// No description provided for @loadingVersion.
  ///
  /// In nb, this message translates to:
  /// **'Laster versjon...'**
  String get loadingVersion;

  /// No description provided for @privacyTitle.
  ///
  /// In nb, this message translates to:
  /// **'Personvern'**
  String get privacyTitle;

  /// No description provided for @privacySubtitle.
  ///
  /// In nb, this message translates to:
  /// **'All data lagres kryptert lokalt på din enhet. Ingen data sendes til noen server.'**
  String get privacySubtitle;

  /// No description provided for @subscriptionActive.
  ///
  /// In nb, this message translates to:
  /// **'Abonnement aktivt'**
  String get subscriptionActive;

  /// No description provided for @subscriptionActiveSubtitle.
  ///
  /// In nb, this message translates to:
  /// **'Årsabonnement — 29 kr/år'**
  String get subscriptionActiveSubtitle;

  /// No description provided for @trialStatus.
  ///
  /// In nb, this message translates to:
  /// **'Prøveperiode'**
  String get trialStatus;

  /// No description provided for @trialFree.
  ///
  /// In nb, this message translates to:
  /// **'Gratis i 30 dager'**
  String get trialFree;

  /// No description provided for @trialDaysLeft.
  ///
  /// In nb, this message translates to:
  /// **'{days} dager igjen av prøveperioden'**
  String trialDaysLeft(int days);

  /// No description provided for @subscriptionExpired.
  ///
  /// In nb, this message translates to:
  /// **'Abonnement utløpt'**
  String get subscriptionExpired;

  /// No description provided for @subscriptionExpiredSubtitle.
  ///
  /// In nb, this message translates to:
  /// **'Abonner for å fortsette å bruke appen'**
  String get subscriptionExpiredSubtitle;

  /// No description provided for @loadingStatus.
  ///
  /// In nb, this message translates to:
  /// **'Laster...'**
  String get loadingStatus;

  /// No description provided for @googleDriveBackup.
  ///
  /// In nb, this message translates to:
  /// **'Google Drive Backup'**
  String get googleDriveBackup;

  /// No description provided for @backupDescription.
  ///
  /// In nb, this message translates to:
  /// **'Lagre en kryptert kopi av databasen din på Google Drive. Kun du har tilgang til backupen.'**
  String get backupDescription;

  /// No description provided for @lastBackup.
  ///
  /// In nb, this message translates to:
  /// **'Siste backup: {date}'**
  String lastBackup(String date);

  /// No description provided for @signInWithGoogle.
  ///
  /// In nb, this message translates to:
  /// **'Logg inn med Google'**
  String get signInWithGoogle;

  /// No description provided for @takeBackupNow.
  ///
  /// In nb, this message translates to:
  /// **'Ta backup nå'**
  String get takeBackupNow;

  /// No description provided for @restoreFromBackup.
  ///
  /// In nb, this message translates to:
  /// **'Gjenopprett fra backup'**
  String get restoreFromBackup;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In nb, this message translates to:
  /// **'Gjenopprett fra backup?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmContent.
  ///
  /// In nb, this message translates to:
  /// **'All nåværende data erstattes med dataen fra backup. Appen vil starte på nytt.'**
  String get restoreConfirmContent;

  /// No description provided for @noBackupFound.
  ///
  /// In nb, this message translates to:
  /// **'Ingen backup funnet på Google Drive'**
  String get noBackupFound;

  /// No description provided for @restoreSuccess.
  ///
  /// In nb, this message translates to:
  /// **'Gjenopprettet. Start appen på nytt for å ta i bruk.'**
  String get restoreSuccess;

  /// No description provided for @signedIn.
  ///
  /// In nb, this message translates to:
  /// **'Logget inn'**
  String get signedIn;

  /// No description provided for @signInCancelled.
  ///
  /// In nb, this message translates to:
  /// **'Innlogging avbrutt'**
  String get signInCancelled;

  /// No description provided for @signInError.
  ///
  /// In nb, this message translates to:
  /// **'Feil ved innlogging:'**
  String get signInError;

  /// No description provided for @backupError.
  ///
  /// In nb, this message translates to:
  /// **'Feil ved backup:'**
  String get backupError;

  /// No description provided for @restoreError.
  ///
  /// In nb, this message translates to:
  /// **'Feil ved gjenoppretting:'**
  String get restoreError;

  /// No description provided for @backupDone.
  ///
  /// In nb, this message translates to:
  /// **'Backup fullført'**
  String get backupDone;

  /// No description provided for @onboarding1Title.
  ///
  /// In nb, this message translates to:
  /// **'Opprett grupper'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Desc.
  ///
  /// In nb, this message translates to:
  /// **'Start med å opprette en gruppe og legg til elever.\nImporter fra CSV eller legg til manuelt.'**
  String get onboarding1Desc;

  /// No description provided for @onboarding2Title.
  ///
  /// In nb, this message translates to:
  /// **'Innsjekk og utsjekk'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Desc.
  ///
  /// In nb, this message translates to:
  /// **'Trykk én gang for å sjekke inn en person.\nTrykk igjen for å sjekke ut. Søk etter navn øverst.'**
  String get onboarding2Desc;

  /// No description provided for @onboarding3Title.
  ///
  /// In nb, this message translates to:
  /// **'Merknader og fravær'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Desc.
  ///
  /// In nb, this message translates to:
  /// **'Hold inne på en person for merknad eller andre statuser.\nMerknader vises i rapporten.'**
  String get onboarding3Desc;

  /// No description provided for @onboarding4Title.
  ///
  /// In nb, this message translates to:
  /// **'Rapport'**
  String get onboarding4Title;

  /// No description provided for @onboarding4Desc.
  ///
  /// In nb, this message translates to:
  /// **'Generer rapport med ett trykk.\nKopier eller del via e-post, SMS etc.'**
  String get onboarding4Desc;

  /// No description provided for @onboarding5Title.
  ///
  /// In nb, this message translates to:
  /// **'Trygt og privat'**
  String get onboarding5Title;

  /// No description provided for @onboarding5Desc.
  ///
  /// In nb, this message translates to:
  /// **'All data lagres kryptert på din enhet.\nBiometrisk lås beskytter elevdata.\nFungerer helt uten internett.'**
  String get onboarding5Desc;

  /// No description provided for @trialExpired.
  ///
  /// In nb, this message translates to:
  /// **'Prøveperioden er utløpt'**
  String get trialExpired;

  /// No description provided for @yearlySubscription.
  ///
  /// In nb, this message translates to:
  /// **'Årsabonnement'**
  String get yearlySubscription;

  /// No description provided for @yearlyPrice.
  ///
  /// In nb, this message translates to:
  /// **'29 kr / år'**
  String get yearlyPrice;

  /// No description provided for @featureUnlimitedGroups.
  ///
  /// In nb, this message translates to:
  /// **'Ubegrenset antall grupper og elever'**
  String get featureUnlimitedGroups;

  /// No description provided for @featureClassroomTrip.
  ///
  /// In nb, this message translates to:
  /// **'Innsjekk og utsjekk med merknader'**
  String get featureClassroomTrip;

  /// No description provided for @featureReports.
  ///
  /// In nb, this message translates to:
  /// **'Rapporter og eksport'**
  String get featureReports;

  /// No description provided for @featureEncrypted.
  ///
  /// In nb, this message translates to:
  /// **'Kryptert lokal lagring'**
  String get featureEncrypted;

  /// No description provided for @featureBiometric.
  ///
  /// In nb, this message translates to:
  /// **'Biometrisk lås'**
  String get featureBiometric;

  /// No description provided for @subscribeCta.
  ///
  /// In nb, this message translates to:
  /// **'Abonner — 29 kr/år'**
  String get subscribeCta;

  /// No description provided for @restorePurchase.
  ///
  /// In nb, this message translates to:
  /// **'Gjenopprett tidligere kjøp'**
  String get restorePurchase;

  /// No description provided for @purchaseError.
  ///
  /// In nb, this message translates to:
  /// **'Kunne ikke starte kjøp. Prøv igjen senere.'**
  String get purchaseError;

  /// No description provided for @purchaseGenericError.
  ///
  /// In nb, this message translates to:
  /// **'Noe gikk galt:'**
  String get purchaseGenericError;

  /// No description provided for @noSubscriptionFound.
  ///
  /// In nb, this message translates to:
  /// **'Ingen tidligere abonnement funnet.'**
  String get noSubscriptionFound;

  /// No description provided for @restoreFailedError.
  ///
  /// In nb, this message translates to:
  /// **'Kunne ikke gjenopprette:'**
  String get restoreFailedError;

  /// No description provided for @authenticateToOpen.
  ///
  /// In nb, this message translates to:
  /// **'Autentiser for å åpne appen'**
  String get authenticateToOpen;

  /// No description provided for @unlockApp.
  ///
  /// In nb, this message translates to:
  /// **'Lås opp'**
  String get unlockApp;

  /// No description provided for @biometricReason.
  ///
  /// In nb, this message translates to:
  /// **'Lås opp Alle med'**
  String get biometricReason;

  /// No description provided for @authFailed.
  ///
  /// In nb, this message translates to:
  /// **'Autentisering mislyktes'**
  String get authFailed;

  /// No description provided for @noArchivedGroups.
  ///
  /// In nb, this message translates to:
  /// **'Ingen arkiverte grupper'**
  String get noArchivedGroups;

  /// No description provided for @groupRestored.
  ///
  /// In nb, this message translates to:
  /// **'{name} gjenopprettet'**
  String groupRestored(String name);

  /// No description provided for @groupNameLabel.
  ///
  /// In nb, this message translates to:
  /// **'Gruppenavn'**
  String get groupNameLabel;

  /// No description provided for @groupNameHint.
  ///
  /// In nb, this message translates to:
  /// **'f.eks. 10A, Tur Hardangervidda'**
  String get groupNameHint;

  /// No description provided for @renameGroup.
  ///
  /// In nb, this message translates to:
  /// **'Endre navn'**
  String get renameGroup;

  /// No description provided for @copyGroup.
  ///
  /// In nb, this message translates to:
  /// **'Kopier gruppe'**
  String get copyGroup;

  /// No description provided for @copyGroupSubtitle.
  ///
  /// In nb, this message translates to:
  /// **'Ny gruppe med samme elever'**
  String get copyGroupSubtitle;

  /// No description provided for @splitGroupAction.
  ///
  /// In nb, this message translates to:
  /// **'Del gruppe'**
  String get splitGroupAction;

  /// No description provided for @splitGroupSubtitle.
  ///
  /// In nb, this message translates to:
  /// **'Velg elever for ny undergruppe'**
  String get splitGroupSubtitle;

  /// No description provided for @archiveGroup.
  ///
  /// In nb, this message translates to:
  /// **'Arkiver gruppe'**
  String get archiveGroup;

  /// No description provided for @groupArchived.
  ///
  /// In nb, this message translates to:
  /// **'{name} arkivert'**
  String groupArchived(String name);

  /// No description provided for @undoAction.
  ///
  /// In nb, this message translates to:
  /// **'Angre'**
  String get undoAction;

  /// No description provided for @renameGroupTitle.
  ///
  /// In nb, this message translates to:
  /// **'Endre gruppenavn'**
  String get renameGroupTitle;

  /// No description provided for @copyGroupTitle.
  ///
  /// In nb, this message translates to:
  /// **'Kopier gruppe'**
  String get copyGroupTitle;

  /// No description provided for @newGroupNameLabel.
  ///
  /// In nb, this message translates to:
  /// **'Navn på ny gruppe'**
  String get newGroupNameLabel;

  /// No description provided for @groupCopied.
  ///
  /// In nb, this message translates to:
  /// **'{name} opprettet'**
  String groupCopied(String name);

  /// No description provided for @splitGroupTitle.
  ///
  /// In nb, this message translates to:
  /// **'Del gruppe'**
  String get splitGroupTitle;

  /// No description provided for @splitGroupNewGroupHint.
  ///
  /// In nb, this message translates to:
  /// **'f.eks. Turgruppe 1'**
  String get splitGroupNewGroupHint;

  /// No description provided for @selectStudentsForNewGroup.
  ///
  /// In nb, this message translates to:
  /// **'Velg elever for den nye gruppen:'**
  String get selectStudentsForNewGroup;

  /// No description provided for @selectAll.
  ///
  /// In nb, this message translates to:
  /// **'Velg alle'**
  String get selectAll;

  /// No description provided for @clearAll.
  ///
  /// In nb, this message translates to:
  /// **'Fjern alle'**
  String get clearAll;

  /// No description provided for @selectedCount.
  ///
  /// In nb, this message translates to:
  /// **'{count} valgt'**
  String selectedCount(int count);

  /// No description provided for @createGroup.
  ///
  /// In nb, this message translates to:
  /// **'Opprett gruppe'**
  String get createGroup;

  /// No description provided for @groupCreatedWithStudents.
  ///
  /// In nb, this message translates to:
  /// **'{name} opprettet med {count} elever'**
  String groupCreatedWithStudents(String name, int count);

  /// No description provided for @readingFile.
  ///
  /// In nb, this message translates to:
  /// **'Leser fil...'**
  String get readingFile;

  /// No description provided for @chooseFile.
  ///
  /// In nb, this message translates to:
  /// **'Velg fil (.xlsx, .csv)'**
  String get chooseFile;

  /// No description provided for @orSeparator.
  ///
  /// In nb, this message translates to:
  /// **'eller'**
  String get orSeparator;

  /// No description provided for @pasteStudentList.
  ///
  /// In nb, this message translates to:
  /// **'Lim inn elevliste (ett navn per linje)'**
  String get pasteStudentList;

  /// No description provided for @importHint.
  ///
  /// In nb, this message translates to:
  /// **'Skriv navn i kolonne A. Etternavn kan legges i kolonne B. Første rad kan være overskrift — appen finner ut av det automatisk.'**
  String get importHint;

  /// No description provided for @previewTitle.
  ///
  /// In nb, this message translates to:
  /// **'Forhåndsvisning'**
  String get previewTitle;

  /// No description provided for @foundStudentsCount.
  ///
  /// In nb, this message translates to:
  /// **'Fant {count} elever'**
  String foundStudentsCount(int count);

  /// No description provided for @headerSkipped.
  ///
  /// In nb, this message translates to:
  /// **' (overskriftsrad hoppet over)'**
  String get headerSkipped;

  /// No description provided for @doesThisLookRight.
  ///
  /// In nb, this message translates to:
  /// **'Ser dette riktig ut?'**
  String get doesThisLookRight;

  /// No description provided for @importCountStudents.
  ///
  /// In nb, this message translates to:
  /// **'Importer {count} elever'**
  String importCountStudents(int count);

  /// No description provided for @studentsImported.
  ///
  /// In nb, this message translates to:
  /// **'{count} elever importert'**
  String studentsImported(int count);

  /// No description provided for @couldNotReadFile.
  ///
  /// In nb, this message translates to:
  /// **'Kunne ikke lese filen'**
  String get couldNotReadFile;

  /// No description provided for @noNamesFound.
  ///
  /// In nb, this message translates to:
  /// **'Fant ingen navn i filen'**
  String get noNamesFound;

  /// No description provided for @startupError.
  ///
  /// In nb, this message translates to:
  /// **'Feil ved oppstart:'**
  String get startupError;

  /// No description provided for @language.
  ///
  /// In nb, this message translates to:
  /// **'Språk'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In nb, this message translates to:
  /// **'Systemstandard'**
  String get languageSystem;

  /// No description provided for @shareSession.
  ///
  /// In nb, this message translates to:
  /// **'Del økt'**
  String get shareSession;

  /// No description provided for @joinSession.
  ///
  /// In nb, this message translates to:
  /// **'Bli med i økt'**
  String get joinSession;

  /// No description provided for @sharingConsentTitle.
  ///
  /// In nb, this message translates to:
  /// **'Deling av fraværsdata'**
  String get sharingConsentTitle;

  /// No description provided for @sharingConsentBody.
  ///
  /// In nb, this message translates to:
  /// **'Elevnavn og oppmøtestatus vil midlertidig lagres i skyen (Google Firebase) under delingen. Dataene slettes automatisk når du avslutter deling.'**
  String get sharingConsentBody;

  /// No description provided for @sharingFirstNamesHint.
  ///
  /// In nb, this message translates to:
  /// **'Anbefaling: bruk kun fornavn i elevlisten for å minimere personopplysningene som deles.'**
  String get sharingFirstNamesHint;

  /// No description provided for @sharingResponsibility.
  ///
  /// In nb, this message translates to:
  /// **'Du er selv ansvarlig for at delingen er i tråd med skolens retningslinjer og GDPR.'**
  String get sharingResponsibility;

  /// No description provided for @sharingConsentAccept.
  ///
  /// In nb, this message translates to:
  /// **'Jeg forstår, del økt'**
  String get sharingConsentAccept;

  /// No description provided for @shareSessionTitle.
  ///
  /// In nb, this message translates to:
  /// **'Del denne økten'**
  String get shareSessionTitle;

  /// No description provided for @shareSessionInstructions.
  ///
  /// In nb, this message translates to:
  /// **'Del denne koden med kolleger som skal registrere fravær i samme økt:'**
  String get shareSessionInstructions;

  /// No description provided for @tapToCopy.
  ///
  /// In nb, this message translates to:
  /// **'Trykk på koden for å kopiere'**
  String get tapToCopy;

  /// No description provided for @codeCopied.
  ///
  /// In nb, this message translates to:
  /// **'Kode kopiert'**
  String get codeCopied;

  /// No description provided for @stopSharing.
  ///
  /// In nb, this message translates to:
  /// **'Stopp deling og slett skydata'**
  String get stopSharing;

  /// No description provided for @stopSharingTitle.
  ///
  /// In nb, this message translates to:
  /// **'Stopp deling?'**
  String get stopSharingTitle;

  /// No description provided for @stopSharingConfirm.
  ///
  /// In nb, this message translates to:
  /// **'All skydata for denne økten slettes umiddelbart. Din lokale kopi beholdes.'**
  String get stopSharingConfirm;

  /// No description provided for @stopSharingDone.
  ///
  /// In nb, this message translates to:
  /// **'Deling stoppet og skydata slettet'**
  String get stopSharingDone;

  /// No description provided for @close.
  ///
  /// In nb, this message translates to:
  /// **'Lukk'**
  String get close;

  /// No description provided for @joinSessionTitle.
  ///
  /// In nb, this message translates to:
  /// **'Bli med i økt'**
  String get joinSessionTitle;

  /// No description provided for @joinSessionCodeHint.
  ///
  /// In nb, this message translates to:
  /// **'Skriv inn invitasjonskoden du har mottatt:'**
  String get joinSessionCodeHint;

  /// No description provided for @invalidCode.
  ///
  /// In nb, this message translates to:
  /// **'Koden må være 6 tegn'**
  String get invalidCode;

  /// No description provided for @codeNotFound.
  ///
  /// In nb, this message translates to:
  /// **'Koden ble ikke funnet. Sjekk at den er riktig og at økten fortsatt er aktiv.'**
  String get codeNotFound;

  /// No description provided for @sharingError.
  ///
  /// In nb, this message translates to:
  /// **'Noe gikk galt. Sjekk internettforbindelsen og prøv igjen.'**
  String get sharingError;

  /// No description provided for @joinSessionConfirmGroup.
  ///
  /// In nb, this message translates to:
  /// **'Gruppe: {name}'**
  String joinSessionConfirmGroup(String name);

  /// No description provided for @joinSessionStudentCount.
  ///
  /// In nb, this message translates to:
  /// **'{count} elever'**
  String joinSessionStudentCount(int count);

  /// No description provided for @joinSessionGroupKept.
  ///
  /// In nb, this message translates to:
  /// **'Gruppen lagres lokalt på din enhet og kan brukes til fremtidige egne økter.'**
  String get joinSessionGroupKept;

  /// No description provided for @joinSessionAccept.
  ///
  /// In nb, this message translates to:
  /// **'Bli med'**
  String get joinSessionAccept;

  /// No description provided for @activeSharingBanner.
  ///
  /// In nb, this message translates to:
  /// **'Aktiv deling — data er i skyen'**
  String get activeSharingBanner;

  /// No description provided for @sharingMemberCount.
  ///
  /// In nb, this message translates to:
  /// **'Deler med {count} kollega(er)'**
  String sharingMemberCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['da', 'en', 'nb', 'sv'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'da':
      return AppLocalizationsDa();
    case 'en':
      return AppLocalizationsEn();
    case 'nb':
      return AppLocalizationsNb();
    case 'sv':
      return AppLocalizationsSv();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
