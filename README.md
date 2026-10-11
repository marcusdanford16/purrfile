# PurrFile

A Flutter app that gives cat owners one place to manage their cats' profiles,
health records, reminders, and (as a stretch feature) an AI Health Assistant.
Built for Holy Angel University's Applications Development and Emerging
Technologies course (6ADET).

> **The Supabase database already exists — do not recreate it.** This project
> connects to an existing Supabase project (`hzpixswzwktmhwfchjtr`) and its
> four tables: `cats`, `health_records`, `reminders`, `ai_conversations`. Never
> run `DROP TABLE` / `CREATE TABLE` / `ALTER TABLE` against it from this repo.
> The only schema change this repo makes is optional RLS policies, applied
> manually — see [Supabase setup](#supabase-setup).

## Features

- **Auth** — real Supabase Auth (email/password) for sign-up, login, and
  logout. No custom or fake auth.
- **Dashboard** — every registered cat, loaded live from `cats`, with
  shortcuts into that cat's Timeline, Reminders, AI Assistant, and Profile.
- **Cat Profile** — full CRUD (add/view/edit/delete) backed by `cats`.
- **Health Timeline** — view/add/edit/delete records backed by
  `health_records`, filterable by type, grouped by year.
- **Reminders & Notifications** — add/edit/delete backed by `reminders`, with
  Upcoming/History tabs and upcoming/completed/overdue status.
- **AI Health Assistant** (stretch) — a chat scoped to one cat, backed by
  `ai_conversations`. Calls a Supabase Edge Function that talks to an AI
  provider; if the function isn't deployed or reachable, the assistant
  degrades to a deterministic mock so the screen still works for a demo.

## Tech stack

- Flutter (Material 3), targeting mobile, desktop, and Flutter Web
- `supabase_flutter` for Auth + Postgres access
- `google_fonts`, `intl`, `device_preview`, `flutter_dotenv`

## Project structure

```
lib/
├── main.dart, app.dart
├── models/        Cat, HealthRecord, Reminder, AiConversation
├── services/       Supabase bootstrap + one service per table
├── screens/        auth/ dashboard/ timeline/ reminders/ ai/ profile/
├── widgets/        CatCard, HealthRecordTile, ReminderTile, PrimaryButton,
│                    FilterChipBar, StatusBadge, ChatBubble, PurrBottomNav
├── theme/          app_theme.dart (ColorScheme + TextTheme from the proposal)
└── utils/          app_spacing.dart, validators.dart
supabase/
└── rls_policies.sql   Optional RLS repair script — run manually
test/                unit tests (validators, model parsing)
```

## Flutter setup

```bash
flutter pub get
```

## Supabase setup

1. Copy the environment template and keep the real file out of git:
   ```bash
   cp .env.example .env
   ```
   `.env` already contains this project's publishable key for local dev —
   swap in your own project's values if you're pointing at a different
   Supabase instance.
2. **Do not recreate the schema.** The four tables already exist with the
   columns documented in the proposal.
3. Before writing any CRUD code, verify RLS in the Supabase dashboard
   (Authentication → Policies) for `cats`, `health_records`, `reminders`, and
   `ai_conversations`. If policies are missing or incorrect, review and run
   [`supabase/rls_policies.sql`](supabase/rls_policies.sql) in the SQL editor.
   It only adds/repairs policies — it never touches table structure or data.
4. (Optional, for the AI Assistant) Deploy an Edge Function named
   `ai-health-assistant` that accepts `{ catName, breed, question,
   recentRecords }` and returns `{ answer }`. Set the AI provider's API key
   as an Edge Function secret (`supabase secrets set AI_API_KEY=...`) —
   never in the Flutter client. Without this function deployed, the AI
   Assistant screen still works using a built-in mock responder.
5. To enable cat profile photos, run the complete
  [`supabase/rls_policies.sql`](supabase/rls_policies.sql) script. It creates
  the public `cat-photos` Storage bucket and only allows signed-in users to
  upload into their own user-id folder. The app stores the resulting public
  URL in the existing `cats.photo` column.

## Environment / configuration

Supabase credentials are read from `.env` via `flutter_dotenv` at startup,
falling back to the values in `.env.example` only so a fresh checkout can
still run locally. `.env` is git-ignored. In CI/deployment, set
`SUPABASE_URL` / `SUPABASE_PUBLISHABLE_KEY` as repository or hosting secrets
instead of committing a file.

## Running the app

```bash
flutter run                 # a connected device or emulator
flutter run -d web-server   # Flutter Web (device_preview wrapper stays on
                             # in debug builds; see main.dart)
```

## Running tests

```bash
flutter analyze
flutter test
```

`test/validators_test.dart` and `test/models_test.dart` cover form
validation and model parsing (including malformed/partial rows) without
touching the network.

## AI configuration

See [Supabase setup](#supabase-setup) step 4. The chat UI, conversation
history, and Supabase persistence work identically whether the Edge Function
is deployed or not — only the source of the answer text changes.

## Known platform limitations

- **Push notifications**: implemented as an in-app "Enable" affordance;
  actual OS-level push requires `flutter_local_notifications`/web push setup
  that's out of scope for the MVP. Reminders are always visible in-app
  (Upcoming/History) regardless of notification permission state.
- **Flutter Web**: every screen is reachable via `flutter run -d web-server`.
  Anything that would need real device hardware degrades gracefully instead
  of crashing.
- **AI Health Assistant**: stretch feature. Falls back to a mock responder
  when the Edge Function isn't deployed, so the demo never breaks.
