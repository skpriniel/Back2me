# Security Checklist

## Secrets and credentials

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 1 | No API key, token or password is hardcoded in `lib/`, including in comments and commented-out code | Yes | I reviewed the Dart files in `lib/` for credential-like values such as API keys, tokens, passwords, Firebase keys, and secret strings. The `_password` value in `login_screen.dart` is only a `TextEditingController` for the local demo login and does not contain a hardcoded password. No real credential value is stored in the source code. |
| 2 | Anything private is in a gitignored config or passed with `--dart-define`, with an example file committed | N/A | Back2me uses local Hive storage and does not connect to a backend or third-party API, so there is no private API URL, key, token, or other runtime configuration that needs to be stored separately. |
| 3 | No keystore, `key.properties` or signing credential is in the repository | Yes | I checked the project for Android signing files such as `*.jks`, `*.keystore`, and `key.properties` and found none. The current deployment targets Flutter web and does not require Android signing credentials. |
| 4 | Git history is clean: I searched `git log -p` for password, secret, api key and token | No | I reviewed the current source code for credentials, but I have not yet completed a final search of the complete Git history for `password`, `secret`, `api key`, and `token`. |
| 5 | Any credential that was ever committed has been rotated | N/A | No real credential has been found in the current source code, so there is no known credential that needs to be rotated. |

## GitHub Actions

The current GitHub Actions workflow builds and deploys the Flutter web application. Back2me does not require application secrets or Android signing credentials for this workflow.

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 6 | No secret value is written literally in any workflow YAML file | Yes | The current web deployment workflow does not contain a hardcoded application API key, password, authentication token, signing credential, or other private application value. |
| 7 | Secrets are stored in repository Actions secrets and read with `${{ secrets.NAME }}` | N/A | Back2me does not currently require application secrets for its Flutter web build, so there are no application credentials that need to be stored as GitHub Actions secrets. |
| 8 | No workflow step echoes, dumps or debug-prints a secret, and I opened a recent run's log to confirm | Yes | I reviewed recent GitHub Actions build and deployment logs while troubleshooting the web deployment. The workflow does not use application secrets and no application credential was printed in the logs. |
| 9 | If I build a signed APK: the keystore is a base64 secret decoded to a file at build time, never printed | N/A | The current workflow builds and deploys Flutter web only. It does not build or sign an Android APK. |
| 10 | Uploaded build artifacts contain no key file, keystore or generated config | Yes | The project contains no signing keystore or private application configuration. The uploaded deployment artifact consists of the Flutter web build. |
| 11 | Third-party actions are pinned to a commit SHA, not a moveable tag | No | The current workflow uses versioned GitHub Action references rather than exact immutable commit SHAs, so it does not fully meet this checklist requirement. |
| 12 | Secret scanning and push protection are enabled on the repository | No | Secret scanning and push protection have not yet been confirmed as enabled in the repository security settings. |

## Backend and security rules

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 13 | Firestore and Storage rules are not left open to anyone; they require an authenticated user | N/A | Back2me does not use Firebase Firestore, Firebase Storage, or another remote backend. Application data is stored locally through Hive. |
| 14 | Rules restrict a user to their own documents where that makes sense | N/A | There is no shared backend or remote user-document access model in the current version of Back2me. |
| 15 | If Supabase: Row Level Security is on for every table | N/A | Supabase is not used anywhere in Back2me. |
| 16 | Firebase and Google API keys are restricted in the Google Cloud console to the APIs and app they are for | N/A | Back2me does not use Firebase or a Google Cloud API key. The `google_fonts` package is used without an application API key. |
| 17 | I opened the app signed out and confirmed I could not read or write data I should not | N/A | The login screen is a local demonstration flow rather than real authentication. There is no server session or backend authorization boundary to test because the application's data is stored locally. |
| 18 | Seed and sample data is invented, not real people's data | Yes | `seedSampleData()` contains demonstration items, borrower names, PH-style phone numbers, dates, and lending records used for the project mockup. These values are sample data and are not intended to represent real people's personal information. |

## Input and app surface

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 19 | Input is validated before it is written, not only styled as valid in the UI | Yes | The lending form requires a borrower name and contact number, requires an item to be selected, and prevents the due date from being earlier than the borrow date. `AppState.createLendingRecord()` also refuses to create another active lending record when the selected item is already borrowed. |
| 20 | Nothing secret is recoverable from the built app, since a shipped binary can be unpacked | Yes | The application source contains no real API key, authentication token, backend password, signing credential, or other application secret that would be exposed through the Flutter web build. |

## Repository and privacy

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 21 | No student number, personal email, phone number or home address in the repository or in commit messages | No | The source code I reviewed contains only placeholder or demonstration contact information, but I have not yet completed a final review of the full commit history and commit messages for personal information. |
| 22 | No classmate's personal data in the repository | Yes | The borrower names and contact numbers in the sample dataset are demonstration values used for the application mockup and are not intended to contain actual classmate records. |
| 23 | Dependencies come from pub.dev, and `build/` and `.dart_tool/` are gitignored | Yes | `pubspec.yaml` uses packages published through pub.dev, including `hive`, `hive_flutter`, `google_fonts`, `intl`, `device_preview`, and `flutter_lints`. Generated Flutter directories such as `build/` and `.dart_tool/` are excluded by `.gitignore`. |
| 24 | Images, fonts and other assets are mine, licensed, or credited | Yes | Back2me uses Plus Jakarta Sans through the `google_fonts` package and Flutter's Material Icons. No separate uncredited third-party image assets are included in the submitted application code. |
| 25 | Repository visibility is deliberate, and I checked it after my last push | No | The repository is already hosted on GitHub, but I have not yet completed the final visibility check after the last push. |

## Anything I found and fixed

I did not find any hardcoded API keys, passwords, authentication tokens, backend credentials, or signing credentials in the Back2me application source.

Back2me currently uses local Hive storage instead of a remote backend. This includes items, borrower details, lending records, and profile information. The current Hive implementation does not configure an encryption cipher, so I have not claimed that locally stored information is encrypted.

The remaining issues identified by this checklist are repository-level rather than application-level. I still need to complete the final Git history and commit-message review, confirm or enable GitHub secret scanning and push protection, verify the repository visibility after the final push, and improve GitHub Actions third-party action pinning where applicable.
