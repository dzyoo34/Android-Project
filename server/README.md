# Dart + Shelf — implementarea de referință

Portul de referință al backend-șablonului PAM. Implementează exact
[`../openapi.yaml`](../openapi.yaml); contractul și regulile sunt în
README-ul șablonului (`../README_RO.md` / `_RU` / `_EN`).

## Pornire

```bash
dart pub get
dart run
```

Atât. `app.db` (SQLite) și `uploads/` se creează automat la prima
pornire.

- Env: `PORT` (implicit 8080), `JWT_SECRET` (implicit `dev-secret-change-me`).
- Upload-urile sunt limitate la 5 MB per fișier (`POST /files` răspunde
  400 `VALIDATION_ERROR` peste limită). Implicititele — CORS deschis,
  secretul JWT de dezvoltare, plafonul de 5 MB — sunt pentru laborator,
  nu pentru producție.
- Descărcările (`GET /files/{id}`) se servesc cu `Content-Disposition:
  attachment` și `Content-Security-Policy: default-src 'none'; sandbox`:
  oricine poate încărca `text/html` sau `image/svg+xml`, iar fără aceste
  antete un link deschis direct în browser ar rula scriptul celui care a
  încărcat fișierul pe originea API-ului (stored XSS).
  `Image.network`/`<img>` ignoră ambele antete, deci afișarea imaginilor
  în laborator rămâne neschimbată — dar șablonul rămâne o configurație
  de laborator, nu de producție.
- Notă Windows: `package:sqlite3` are nevoie de `sqlite3.dll` în PATH sau
  lângă executabil — descărcați-l de pe sqlite.org (pe macOS/Linux se
  folosește biblioteca de sistem, nimic de făcut).

## Verificarea contra contractului

```bash
# cu serverul pornit:
cd ../conformance
dart pub get
dart run bin/conformance.dart --base-url http://localhost:8080
```

## Structura

```
bin/server.dart   — pornirea: env, rute, middleware (CORS, logging)
lib/db.dart       — schema SQLite, aplicată automat la pornire
lib/auth.dart     — register/login/me, parole PBKDF2, JWT (HS256, scris de mână)
lib/notes.dart    — entitatea-exemplu: CRUD + paginare + search
lib/files.dart    — upload multipart, download binar
lib/errors.dart   — forma standard a erorilor + helperi JSON
```

Parolele sunt hash-uite cu PBKDF2-HMAC-SHA256 (100k iterații, salt
aleator) peste `package:crypto` — în Dart nu e nevoie de o dependență
bcrypt. JWT-ul e implementat de mână (~40 de linii în `lib/auth.dart`),
ca să vedeți exact ce este un token.

## Adaugă-ți propria entitate

`lib/notes.dart` este șablonul — copiați-l:

1. Adăugați un `CREATE TABLE` pentru entitatea voastră în `lib/db.dart`
   (cu o coloană `user_id` dacă aparține unui utilizator).
2. Copiați `lib/notes.dart` în, de exemplu, `lib/recipes.dart`;
   redenumiți tabelul și câmpurile JSON.
3. Înregistrați rutele noi în `bin/server.dart` lângă cele `/notes`
   (împachetate în `requireAuth`).
4. Reporniți, testați cu `curl` sau cu aplicația Flutter, apoi re-rulați
   suita de conformitate ca să confirmați că contractul de bază trece în
   continuare.
