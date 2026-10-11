# Security checklist

## Secrets and credentials

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 1 | No API key, token or password is hardcoded in lib/, including in comments and commented-out code | No | I searched lib/ for keys, tokens, passwords and private-key patterns. No secret was found, but `lib/services/supabase_service.dart` has the Supabase URL and the publishable (anon) key written in as a fallback when `.env` is missing. This key is public by design and protected by Row Level Security, but it is still a key written in code. I plan to remove it. |
| 2 | Anything private is in a gitignored config or passed with --dart-define, with an example file committed | Yes | `.gitignore` includes `.env`. `.env.example` is committed with the variable names `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`. It currently holds the real public values instead of placeholders, which I plan to change. The AI key is documented there only as a comment, to be set as a Supabase Edge Function secret. |
| 3 | No keystore, key.properties or signing credential is in the repository | Yes | I searched the project for `.jks`, `.keystore`, `key.properties`, `google-services.json`, service account files and `.pem` files. None exist. `android/.gitignore` also ignores `key.properties`, `*.keystore`, `*.jks` and `local.properties`. |
| 4 | Git history is clean: I searched git log -p for password, secret, api key and token | Yes | I searched `git log -p` for api_key, secret, password, token, service_role, sb_publishable, AIza and private-key patterns. The only matches are commented-out `secrets.NAME` lines and words in commit messages from the course template. No real key value is in the history. I will repeat this search after my first PurrFile commit. |
| 5 | Any credential that was ever committed has been rotated | N/A | No private credential was ever committed. The project has no `service_role` key, AI key or service account file. The publishable key is public by design. |

## GitHub Actions

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 6 | No secret value is written literally in any workflow YAML file | Yes | I read `.github/workflows/deploy-web.yml`. It contains no key values. The only environment entry that is active is `DUMMY: unused`, and the secret entries are commented out. |
| 7 | Secrets are stored in repository Actions secrets and read with ${{ secrets.NAME }} | No | The workflow has `${{ secrets.SUPABASE_URL }}` and `${{ secrets.SUPABASE_PUBLISHABLE_KEY }}`, but both lines are still commented out, and I have not yet added the secrets in Settings. I will connect them when I move the config to `--dart-define`. |
| 8 | No workflow step echoes, dumps or debug-prints a secret, and I opened a recent run's log to confirm | No | No step in the workflow prints a secret. I have not pushed PurrFile yet, so there is no run log to open. I will check one after my first deploy. |
| 9 | If I build a signed APK: the keystore is a base64 secret decoded to a file at build time, never printed | N/A | The workflow builds only the Flutter web app. There is no Android signing step. |
| 10 | Uploaded build artifacts contain no key file, keystore or generated config | Yes | The workflow uploads only `build/web` through `actions/upload-pages-artifact`. No keystore or service account file is added. |
| 11 | Third-party actions are pinned to a commit SHA, not a moveable tag | No | The workflow uses `actions/checkout@v7`, `subosito/flutter-action@v2`, `actions/upload-pages-artifact@v5` and `actions/deploy-pages@v5`, which are version tags, not commit SHAs. |
| 12 | Secret scanning and push protection are enabled on the repository | Yes | I checked Settings > Advanced Security on the repository and confirmed that Secret scanning and Push protection are both enabled. GitHub turns both on by default for public repositories. |

## Backend and security rules

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 13 | Firestore and Storage rules are not left open to anyone; they require an authenticated user | N/A | PurrFile uses Supabase, not Firebase. The equivalent protection is in `supabase/rls_policies.sql`: every table policy requires `auth.uid()`, and photo uploads to the `cat-photos` bucket are limited to `authenticated` users. |
| 14 | Rules restrict a user to their own documents where that makes sense | Yes | `cats` rows are limited to `auth.uid() = user_id`. `health_records` and `reminders` check ownership through the parent cat. `ai_conversations` is limited to `auth.uid() = user_id`. Photo uploads are limited to a folder named after the user's own id. |
| 15 | If Supabase: Row Level Security is on for every table | Yes | `rls_policies.sql` enables RLS on `cats`, `health_records`, `reminders` and `ai_conversations`. I ran the file in the Supabase SQL editor and confirmed in Authentication > Policies that all four tables show RLS enabled. |
| 16 | Firebase and Google API keys are restricted in the Google Cloud console to the APIs and app they are for | N/A | The app uses no Firebase or Google API keys. The only key is the Supabase publishable key, limited by RLS. |
| 17 | I opened the app signed out and confirmed I could not read or write data I should not | Yes | I opened the app in a private window without logging in, and only the login screen showed. I then logged in as two different accounts, and neither could see the other's cats, health records or reminders. |
| 18 | Seed and sample data is invented, not real people's data | Yes | The sample cats, health records and reminders are test data I created for the demo. The owner name is my own, and the cat photos are of my own cats. |

## Input and app surface

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 19 | Input is validated before it is written, not only styled as valid in the UI | Yes | `lib/utils/validators.dart` checks email format, an 8-character minimum password, the confirm-password match and required names, and the sign-up, login and cat forms call these before saving. The reminder dialog rejects an empty type before saving. The database also rejects wrong types, and RLS rejects other users' rows. Free-text fields such as notes and description have no length limit, which I note as an improvement. |
| 20 | Nothing secret is recoverable from the built app, since a shipped binary can be unpacked | Yes | The built app contains only the Supabase URL and publishable key, which are public by design and protected by RLS. There is no `service_role` key, AI key or service account in the app. |

## Repository and privacy

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 21 | No student number, personal email, phone number or home address in the repository or in commit messages | Yes | I searched the project text and docs for emails, student numbers and phone numbers. The only email is the fictional `marcus@purrfile.app` in `test/validators_test.dart`. I deleted the Java crash logs, which contained my Windows username and file paths, before committing. My commit messages contain no personal details. |
| 22 | No classmate's personal data in the repository | Yes | This is an individual project and contains no classmate names, contacts or data. |
| 23 | Dependencies come from pub.dev, and build/ and .dart_tool/ are gitignored | Yes | `pubspec.yaml` has no `git:` or `path:` dependencies. `.gitignore` includes `build/` and `.dart_tool/`. |
| 24 | Images, fonts and other assets are mine, licensed, or credited | Yes | The logo files in `assets/images` are my own design. The Baloo 2 and Inter fonts load through the `google_fonts` package under the SIL Open Font License. App screenshots are of my own app. |
| 25 | Repository visibility is deliberate, and I checked it after my last push | Yes | The repository is set to Public, as the course requires. I checked Settings > General > Danger Zone, and opened the repository in a private window, after my last push. |

## Anything I found and fixed

During the security review, I checked the project for committed credentials, signing files, the Git history, the GitHub Actions workflow, the Supabase security policies, input validation, sample data and personal information. No `service_role` key, AI key, keystore, service account file or private credential was found. I found Java crash logs (`hs_err_pid*.log`) in the project root that contained my Windows username and file paths and were not git-ignored; I deleted them and added them to `.gitignore` before the first commit. I also removed a stray `lib/widgets/macos` folder. I found that the Supabase URL and publishable key are written as a fallback in `lib/services/supabase_service.dart` and in `.env.example`. They are public by design and protected by Row Level Security, but my proposal said credentials would stay out of the repository, so I am moving them to `--dart-define` and repository secrets. The deploy workflow's secret lines are still commented out, and its actions use version tags instead of pinned commit SHAs. Free-text fields have no length limits. The sample data is invented for the demo and contains no classmate or real user data.