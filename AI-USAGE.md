# AI usage

This project was built with AI assistance. This file is the record of it.

## 1. How I used AI

### 2026-10-04 - Full UI redesign of the existing app

* Tool: Claude (Anthropic), claude.ai chat
* What I asked for: I uploaded screenshots of my PurrFile app, four reference app designs, my project proposal PDF, and my project zip. I asked for a more polished look in all screens without changing what the app does.
* What it gave back: A set of shared widgets (PurrCard, CatAvatar, PurrHeader, EmptyState, skeleton loaders, date fields), rewritten versions of every screen, and a floating bottom navigation bar, as a zip that I extracted over my project's lib/ and test/ folders.
* What I kept, what I changed, and why: I kept my existing colors, fonts, theme, and every widget constructor, so my screens and services still connect. I kept the redesign because it made the app look like a real pet-health app instead of a plain list.
* Commit: TBD

### 2026-10-04 - Fixing a hidden button-text bug

* Tool: Claude (Anthropic), claude.ai chat
* What I asked for: I did not ask for this directly. While redesigning, the AI inspected my code to find why the "Log In" and "Add Health Record" buttons looked dim in my screenshots.
* What it gave back: A fixed PrimaryButton. The old version forced a dark text style onto the green button, so the label was dark-on-dark-green.
* What I kept, what I changed, and why: I kept the fix because I could see the dim text in my own screenshots. I also kept an optional icon parameter it added to the button.
* Commit: TBD

### 2026-10-04 - Debugging "Could not save this reminder"

* Tool: Claude (Anthropic), claude.ai chat
* What I asked for: I sent a screenshot of the error and asked if the problem was in Supabase.
* What it gave back: A patched reminder_service.dart that shows the real Supabase error in debug mode, then (after I sent the real message) a model fix that writes `notification_status` as a boolean, plus unit tests for it.
* What I kept, what I changed, and why: I kept the fix that matches the app to my existing database instead of altering the table, so my existing data is safe. I checked in Supabase that `notification_status` is a boolean column.
* Commit: TBD

### 2026-10-04 - Logo from my own design

* Tool: Claude (Anthropic), claude.ai chat
* What I asked for: I uploaded my JPG logo and asked to apply it in the app.
* What it gave back: Transparent PNG versions (white, green, and a smaller one without the tagline) in assets/images, and code to show them on the login screen and Home.
* What I kept, what I changed, and why: I used it at first, then replaced it with a different logo in the next entry because I wanted it to match a new reference design.
* Commit: TBD

### 2026-10-04 - Second design pass from a reference mockup, with a code-drawn logo

* Tool: Claude (Anthropic), claude.ai chat
* What I asked for: I uploaded a mockup of the Home screen and asked for the app and the logo to look like it.
* What it gave back: A paw-with-cat-face logo drawn in code (PurrLogo), a greeting header, larger cat cards with pastel shortcut tiles, a line-art cat peeking over the first card, soft hills behind every tab, and a larger bottom navigation pill.
* What I kept, what I changed, and why: I kept the design. I did not add the mockup's bell with a red dot, because my app has no notifications screen and it would do nothing. The red dots on Reminders were also left out because they need extra database queries.
* Commit: TBD

### 2026-10-04 - Fixing Flutter setup and project-folder problems

* Tool: Claude (Anthropic), claude.ai chat
* What I asked for: The app kept loading the old design, and later `flutter run` would not finish loading. I pasted my terminal output and the analyzer errors.
* What it gave back: Step-by-step PowerShell commands to find which folder my files were in, a way to move a nested duplicate copy of the project out of the way, and a corrected zip that fixed a missing import.
* What I kept, what I changed, and why: I followed the steps and checked each result with `dir` and `flutter analyze` instead of assuming they worked.
* Commit: TBD

### 2026-10-04 - Video presentation script

* Tool: Claude (Anthropic), claude.ai chat
* What I asked for: A script and flow for my video presentation about the app.
* What it gave back: A timed outline and a word-for-word script with on-screen actions, a recording checklist, and a short outro.
* What I kept, what I changed, and why: I kept the structure. I need to keep claims honest, so the script flags things to verify before saying them, such as whether the AI replies are live or sample responses.
* Commit: TBD

## 2. Where the AI got it wrong

### Case 1 - Login logo and text were not centered

* What it gave me: A login header where the logo and tagline sat inside a Stack.
* What was wrong with it: The column shrank to the width of its content and was drawn at the top-left of the header, so the logo and text were pushed to the left instead of centered. I only found out because I ran it and sent a screenshot.
* What I did instead: I asked for a fix. The header became a full-width container with the logo centered in it, and later the new PurrLogo widget replaced it.
* Commit: TBD

### Case 2 - A missing import that stopped the app from compiling

* What it gave me: A new login_screen.dart that used `scheme.heroGradient`.
* What was wrong with it: `heroGradient` is defined in app_theme.dart, but the AI had removed that import from the file. `flutter analyze` reported an undefined getter error. The mistake was the AI's, not mine.
* What I did instead: I pasted the analyzer output. The AI re-added the import, scanned every file for the same kind of missing import, and sent a corrected zip.
* Commit: TBD

### Case 3 - The first diagnosis of the reminder error was a guess

* What it gave me: When I asked if the "Could not save this reminder" error was in Supabase, it said it was most likely a missing Row Level Security policy and told me to run my policies SQL first.
* What was wrong with it: That was a guess, because my app hides the real error behind a generic message. The real cause, once I made the real message visible, was `invalid input syntax for type boolean: "upcoming"`: my `notification_status` column is a boolean, but the app was sending text.
* What I did instead: I made the app show the real error in debug, read the message, and changed the model to read and write a boolean (true means completed). The lesson for me: read the actual error before changing the database.
* Commit: TBD

## 3. Who wrote what

### Written by me

* File: lib/utils/validators.dart
* Commit: TBD
* What it does and why it is built this way: I wrote the form checks for the login and sign-up screens, such as the email format, the 8-character password minimum, and the confirm-password match. Each check returns an error message or nothing, so I can plug it straight into a Flutter form field and reuse it on every screen. I also set up the Supabase tables and tested the checks and the forms myself to make sure they behave correctly.

### The AI-written part I understand best

* File: lib/models/reminder.dart
* Commit: TBD
* What it does and why we kept it: Claude helped fix how reminders are saved and read. My database stores the reminder status as true or false, so the code now turns that value into Upcoming, Done or Overdue, and turns it back when saving. I understand it because I found the problem myself from the error message, checked the column type in Supabase, and tested adding and completing a reminder before keeping the change.