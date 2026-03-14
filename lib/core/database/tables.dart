import 'package:drift/drift.dart';

/// Statusmodell for inn-/utsjekk-registrering.
enum AttendanceStatus {
  ukjent,     // Ikke møtt / ikke registrert ennå (index 0)
  tilStede,   // Innsjekket / til stede (index 1)
  fravaer,    // Fravær — møter ikke opp (index 2)
  forseinka,  // Sen ankomst (index 3)
  utsjekket,  // Utsjekket / trygt hjemme (index 4, var planlagtBorte)
}

/// Gruppetype
enum GroupType {
  klasse,
  faggruppe,
  turgruppe,
  annet,
}

/// Type fraværsøkt (beholdes for bakoverkompatibilitet)
enum SessionType {
  klasseromsOkt,
  turregistrering,
}

// --- Tabeller ---

/// Lærer — eier av grupper og data.
class Laerere extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get navn => text().withLength(min: 1, max: 200)();
  TextColumn get epost => text().nullable()();
  BoolColumn get biometriskLaasAktiv => boolean().withDefault(const Constant(false))();
  DateTimeColumn get opprettetDato => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Elev — globalt objekt. Eksisterer uavhengig av grupper.
/// Slettes ALDRI ved gruppesletting.
class Elever extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get navn => text().withLength(min: 1, max: 200)();
  TextColumn get elevId => text().nullable()(); // Valgfritt skole-ID
  DateTimeColumn get opprettetDato => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Gruppe — klasse, faggruppe, turgruppe etc.
/// Arkiveres (soft-delete), slettes aldri fysisk.
class Grupper extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get navn => text().withLength(min: 1, max: 200)();
  TextColumn get fag => text().nullable()();
  IntColumn get type => intEnum<GroupType>()();
  BoolColumn get arkivert => boolean().withDefault(const Constant(false))();
  TextColumn get laererId => text().references(Laerere, #id)();
  DateTimeColumn get opprettetDato => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Medlemskap — bro mellom Elev og Gruppe.
/// Kan slettes trygt uten å påvirke elevdata.
class Medlemskap extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get elevId => text().references(Elever, #id)();
  TextColumn get gruppeId => text().references(Grupper, #id)();
  DateTimeColumn get innmeldtDato => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Fraværsøkt — representerer én registreringsrunde (tur, trening, time, etc.)
class FravaersOkter extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get navn => text().nullable()(); // Valgfritt navn, f.eks. "Tur til Gaustatoppen"
  DateTimeColumn get dato => dateTime()();
  IntColumn get type => intEnum<SessionType>()(); // Beholdes for bakoverkompatibilitet
  TextColumn get gruppeId => text().references(Grupper, #id)();
  TextColumn get laererId => text().references(Laerere, #id)();
  BoolColumn get avsluttet => boolean().withDefault(const Constant(false))();
  DateTimeColumn get opprettetDato => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Fraværspost — kjernedata. Én rad per elev per økt.
class FravaersPoster extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get elevId => text().references(Elever, #id)();
  TextColumn get oktId => text().references(FravaersOkter, #id)();
  IntColumn get status => intEnum<AttendanceStatus>()();
  IntColumn get forsinkelsesMinutter => integer().nullable()();
  TextColumn get merknad => text().nullable()();
  DateTimeColumn get tidspunkt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Merknader knyttet til elev globalt — vises i alle grupper.
class ElevMerknader extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get elevId => text().references(Elever, #id)();
  TextColumn get tekst => text()();
  BoolColumn get erPermanent => boolean().withDefault(const Constant(false))();
  DateTimeColumn get utlopsDato => dateTime().nullable()(); // Null = permanent
  DateTimeColumn get opprettetDato => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
