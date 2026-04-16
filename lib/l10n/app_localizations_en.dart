// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'All Present';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get started';

  @override
  String get create => 'Create';

  @override
  String get importAction => 'Import';

  @override
  String get back => 'Back';

  @override
  String get restore => 'Restore';

  @override
  String get remove => 'Remove';

  @override
  String get report => 'Report';

  @override
  String get end => 'End';

  @override
  String get copy => 'Copy';

  @override
  String get statusUnknown => 'Not arrived';

  @override
  String get statusPresent => 'Checked in';

  @override
  String get statusAbsent => 'Absent';

  @override
  String get statusLate => 'Late';

  @override
  String get statusCheckedOut => 'Checked out';

  @override
  String get statusPlannedAbsent => 'Planned absent';

  @override
  String get myGroups => 'My groups';

  @override
  String get archivedGroups => 'Archived groups';

  @override
  String get settings => 'Settings';

  @override
  String get noGroupsYet => 'No groups yet';

  @override
  String get noGroupsDescription => 'Create your first group to get started.';

  @override
  String get newGroup => 'New group';

  @override
  String studentCount(int count) {
    return '$count students';
  }

  @override
  String get exportSemester => 'Export semester';

  @override
  String get sessionHistory => 'Session history';

  @override
  String get addStudent => 'Add student';

  @override
  String get importStudents => 'Import students';

  @override
  String get noStudentsInGroup => 'No students in group';

  @override
  String get addStudentsManuallyOrImport =>
      'Add students manually or import from file.';

  @override
  String get startSession => 'Start registration';

  @override
  String get sessionName => 'Session name (optional)';

  @override
  String get sessionNameHint => 'e.g. Friday practice, Trip to the mountains';

  @override
  String get noteLabel => 'Note';

  @override
  String get noteHint => 'Add note...';

  @override
  String get classroom => 'Classroom';

  @override
  String get trip => 'Trip';

  @override
  String get viewFinishedSessions => 'View finished sessions';

  @override
  String get activeSessionExistsTitle => 'Active session exists';

  @override
  String get activeSessionExistsContent =>
      'There is already an active session for this group. Do you want to continue it?';

  @override
  String get continueSession => 'Continue';

  @override
  String get renameStudentTitle => 'Rename student';

  @override
  String get newNameHint => 'New name';

  @override
  String get removeStudentTitle => 'Remove student from group?';

  @override
  String removeStudentContent(String name) {
    return '$name will be removed from this group. The student\'s data and history will be kept.';
  }

  @override
  String historyTitle(String groupName) {
    return 'History — $groupName';
  }

  @override
  String get noFinishedSessions => 'No finished sessions';

  @override
  String get finishedSessionsDescription =>
      'Finished sessions appear here so you can view reports or edit attendance afterwards.';

  @override
  String get editAbsence => 'Edit attendance';

  @override
  String classroomTitle(String groupName) {
    return '$groupName — Classroom';
  }

  @override
  String tripTitle(String groupName) {
    return '$groupName — Trip';
  }

  @override
  String sessionTitle(String sessionName) {
    return '$sessionName';
  }

  @override
  String get tapChangeStatusHint =>
      'Tap = check in/out · Hold = note and more options';

  @override
  String get phaseInnsjekk => 'Check-in';

  @override
  String get phaseUtsjekk => 'Check-out';

  @override
  String get switchToUtsjekk => 'Switch to check-out';

  @override
  String get switchToInnsjekk => '← Check-in';

  @override
  String get innsjekkHint => 'Tap to check in · Hold for note and absence';

  @override
  String get utsjekkHint => 'Tap to check out · Hold for note';

  @override
  String get endSession => 'End session';

  @override
  String get endSessionTitle => 'End session?';

  @override
  String get endTripTitle => 'End trip registration?';

  @override
  String get reportStillAvailable =>
      'You can still view the report after ending.';

  @override
  String get searchStudent => 'Search for student...';

  @override
  String registeredCount(int registered, int total) {
    return '$registered / $total registered';
  }

  @override
  String notRegisteredCount(int count) {
    return '$count not registered';
  }

  @override
  String minutesLate(int minutes) {
    return '$minutes min late';
  }

  @override
  String get lateLabel => 'Late:';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get copyToClipboard => 'Copy to clipboard';

  @override
  String get shareReport => 'Share report';

  @override
  String get reportCopied => 'Report copied';

  @override
  String get copyReport => 'Copy report';

  @override
  String get reportCopiedFull => 'Report copied to clipboard';

  @override
  String get shareVia => 'Share via...';

  @override
  String get pdfExportError => 'Error exporting PDF:';

  @override
  String exportScreenTitle(String groupName) {
    return 'Export — $groupName';
  }

  @override
  String get choosePeriod => 'Choose period';

  @override
  String get exportCsvDescription =>
      'Exports CSV with all sessions in the period. One row per student, one column per session.';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get csvLegend =>
      'Legend:\nP = Present · A = Absent · L15 = Late 15 min\nPL = Planned absence · ? = Not registered';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get noSessionsInPeriod => 'No sessions in selected period.';

  @override
  String get exportError => 'Export error:';

  @override
  String get biometricLock => 'Biometric lock';

  @override
  String get biometricLockSubtitle => 'Require fingerprint or face on startup';

  @override
  String get backup => 'Backup';

  @override
  String get backupSubtitle => 'Back up to Google Drive';

  @override
  String get aboutApp => 'About All Present';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get loadingVersion => 'Loading version...';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacySubtitle =>
      'All data is stored encrypted locally on your device. No data is sent to any server.';

  @override
  String get subscriptionActive => 'Subscription active';

  @override
  String get subscriptionActiveSubtitle => 'Annual subscription — 29 kr/year';

  @override
  String get trialStatus => 'Trial period';

  @override
  String get trialFree => 'Free for 30 days';

  @override
  String trialDaysLeft(int days) {
    return '$days days left of trial period';
  }

  @override
  String get subscriptionExpired => 'Subscription expired';

  @override
  String get subscriptionExpiredSubtitle =>
      'Subscribe to continue using the app';

  @override
  String get loadingStatus => 'Loading...';

  @override
  String get googleDriveBackup => 'Google Drive Backup';

  @override
  String get backupDescription =>
      'Save an encrypted copy of your database to Google Drive. Only you have access to the backup.';

  @override
  String lastBackup(String date) {
    return 'Last backup: $date';
  }

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get takeBackupNow => 'Back up now';

  @override
  String get restoreFromBackup => 'Restore from backup';

  @override
  String get restoreConfirmTitle => 'Restore from backup?';

  @override
  String get restoreConfirmContent =>
      'All current data will be replaced with data from the backup. The app will restart.';

  @override
  String get noBackupFound => 'No backup found on Google Drive';

  @override
  String get restoreSuccess => 'Restored. Restart the app to apply.';

  @override
  String get signedIn => 'Signed in';

  @override
  String get signInCancelled => 'Sign-in cancelled';

  @override
  String get signInError => 'Sign-in error:';

  @override
  String get backupError => 'Backup error:';

  @override
  String get restoreError => 'Restore error:';

  @override
  String get backupDone => 'Backup complete';

  @override
  String get onboarding1Title => 'Create groups';

  @override
  String get onboarding1Desc =>
      'Start by creating a group and adding students.\nImport from CSV or add manually.';

  @override
  String get onboarding2Title => 'Classroom mode';

  @override
  String get onboarding2Desc =>
      'Tap a student to register as present.\nTap again for absent. Hold for more options.';

  @override
  String get onboarding3Title => 'Trip mode';

  @override
  String get onboarding3Desc =>
      'Designed for one-handed use outdoors.\nSearch for students with three letters — one tap registers.';

  @override
  String get onboarding4Title => 'Report';

  @override
  String get onboarding4Desc =>
      'Generate a report with one tap.\nCopy or share via email, SMS etc.';

  @override
  String get onboarding5Title => 'Safe and private';

  @override
  String get onboarding5Desc =>
      'All data is stored encrypted on your device.\nBiometric lock protects student data.\nWorks completely offline.';

  @override
  String get trialExpired => 'Trial period has expired';

  @override
  String get yearlySubscription => 'Annual subscription';

  @override
  String get yearlyPrice => '29 kr / year';

  @override
  String get featureUnlimitedGroups => 'Unlimited groups and students';

  @override
  String get featureClassroomTrip => 'Classroom and trip mode';

  @override
  String get featureReports => 'Reports and export';

  @override
  String get featureEncrypted => 'Encrypted local storage';

  @override
  String get featureBiometric => 'Biometric lock';

  @override
  String get subscribeCta => 'Subscribe — 29 kr/year';

  @override
  String get restorePurchase => 'Restore previous purchase';

  @override
  String get purchaseError =>
      'Could not start purchase. Please try again later.';

  @override
  String get purchaseGenericError => 'Something went wrong:';

  @override
  String get noSubscriptionFound => 'No previous subscription found.';

  @override
  String get restoreFailedError => 'Could not restore:';

  @override
  String get authenticateToOpen => 'Authenticate to open the app';

  @override
  String get unlockApp => 'Unlock';

  @override
  String get biometricReason => 'Unlock All Present';

  @override
  String get authFailed => 'Authentication failed';

  @override
  String get noArchivedGroups => 'No archived groups';

  @override
  String groupRestored(String name) {
    return '$name restored';
  }

  @override
  String get groupNameLabel => 'Group name';

  @override
  String get groupNameHint => 'e.g. Class 10A, Mountain Trip';

  @override
  String get renameGroup => 'Rename';

  @override
  String get copyGroup => 'Copy group';

  @override
  String get copyGroupSubtitle => 'New group with same students';

  @override
  String get splitGroupAction => 'Split group';

  @override
  String get splitGroupSubtitle => 'Choose students for new subgroup';

  @override
  String get archiveGroup => 'Archive group';

  @override
  String groupArchived(String name) {
    return '$name archived';
  }

  @override
  String get undoAction => 'Undo';

  @override
  String get renameGroupTitle => 'Rename group';

  @override
  String get copyGroupTitle => 'Copy group';

  @override
  String get newGroupNameLabel => 'Name of new group';

  @override
  String groupCopied(String name) {
    return '$name created';
  }

  @override
  String get splitGroupTitle => 'Split group';

  @override
  String get splitGroupNewGroupHint => 'e.g. Trip group 1';

  @override
  String get selectStudentsForNewGroup => 'Select students for the new group:';

  @override
  String get selectAll => 'Select all';

  @override
  String get clearAll => 'Clear all';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get createGroup => 'Create group';

  @override
  String groupCreatedWithStudents(String name, int count) {
    return '$name created with $count students';
  }

  @override
  String get readingFile => 'Reading file...';

  @override
  String get chooseFile => 'Choose file (.xlsx, .csv)';

  @override
  String get orSeparator => 'or';

  @override
  String get pasteStudentList => 'Paste student list (one name per line)';

  @override
  String get importHint =>
      'Write names in column A. Last names can go in column B. The first row can be a header — the app will figure it out automatically.';

  @override
  String get previewTitle => 'Preview';

  @override
  String foundStudentsCount(int count) {
    return 'Found $count students';
  }

  @override
  String get headerSkipped => ' (header row skipped)';

  @override
  String get doesThisLookRight => 'Does this look right?';

  @override
  String importCountStudents(int count) {
    return 'Import $count students';
  }

  @override
  String studentsImported(int count) {
    return '$count students imported';
  }

  @override
  String get couldNotReadFile => 'Could not read the file';

  @override
  String get noNamesFound => 'No names found in the file';

  @override
  String get startupError => 'Startup error:';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';
}
