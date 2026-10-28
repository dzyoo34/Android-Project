// SQLite setup. The database file is created automatically on first start.
//
// To add your own entity: add a CREATE TABLE below, then copy the pattern
// of lib/notes.dart for its routes.

import 'package:sqlite3/sqlite3.dart';

/// The single database connection, opened once at startup by [initDb].
late final Database db;

/// Opens (and creates, on first run) the database and its schema.
void initDb(String path) {
  db = sqlite3.open(path);
  db.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      email         TEXT    NOT NULL UNIQUE,
      password_hash TEXT    NOT NULL,
      name          TEXT    NOT NULL,
      created_at    TEXT    NOT NULL
    );

    CREATE TABLE IF NOT EXISTS notes (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id    INTEGER NOT NULL REFERENCES users (id),
      title      TEXT    NOT NULL,
      content    TEXT    NOT NULL DEFAULT '',
      created_at TEXT    NOT NULL
    );

    CREATE TABLE IF NOT EXISTS clients (
      id             INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id        INTEGER NOT NULL REFERENCES users (id),
      name           TEXT    NOT NULL,
      contact_person TEXT    NOT NULL DEFAULT '',
      phone          TEXT    NOT NULL DEFAULT '',
      stage          TEXT    NOT NULL DEFAULT 'Новый лид',
      last_visit     TEXT    NOT NULL DEFAULT '',
      created_at     TEXT    NOT NULL
    );

    CREATE TABLE IF NOT EXISTS files (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id    INTEGER NOT NULL REFERENCES users (id),
      name       TEXT    NOT NULL,
      mime_type  TEXT    NOT NULL,
      size       INTEGER NOT NULL,
      path       TEXT    NOT NULL,
      created_at TEXT    NOT NULL
    );
  ''');
}

String nowIso() => DateTime.now().toUtc().toIso8601String();