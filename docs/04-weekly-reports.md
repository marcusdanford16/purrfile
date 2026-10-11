# Weekly reports

One entry per week, newest at the top, written **during** that week. Five minutes
each. They are the record of how the project actually went, and they make your
final reflection almost write itself.

Copy this block:

---

## Week of Oct 4, 2026 to Oct 10, 2026

**Done this week**
- Finished the PurrFile app. Cat profiles, the health timeline, reminders, the AI assistant, and the profile screen all work and are connected to Supabase.
- Redesigned the UI on every screen: a new logo, a cleaner Home screen, rounder cards, color-coded health records, and a floating bottom navigation bar.
- Fixed a bug where reminders would not save. The error was "invalid input syntax for type boolean", because my `notification_status` column is true/false but the app was sending words like "upcoming". I changed the app to match the database.
- Fixed the button text that looked dim on the green buttons.
- Ran `flutter analyze` and `flutter test` and fixed a missing import that stopped a screen from compiling.
- Wrote my AI usage record and the script for my demo video.

**In progress**
- Moving the project into the course template repository in my own GitHub account.
- Filling in the README, screenshots, and project documentation.
- Recording the demo video.

**Blocked or stuck on**
- `flutter run -d web-server` took a very long time and seemed stuck on "Waiting for connection from debug service on Web Server". I found a second, nested copy of my project inside the project folder that was slowing things down, and I also learned that I have to open the link myself in the browser for that command to finish.
- For a while the app kept showing the old design, because my new files had gone into a different folder than the one I was running.

**Decisions made, and why**
- Changed the app to match my Supabase table instead of changing the table. That way I do not risk my existing data, and the screens could stay the same.
- Drew the logo in code instead of using an image file, so it stays sharp at any size and can change color on the green header.
- Kept the AI Health Assistant as a stretch feature, as in my proposal, so the main app was finished first.
- Left out the notification bell and the red dots on the mockup, because the app has no notifications screen and they would not do anything.

**Hours spent, roughly:** 
- 4 to 5 hours

**Next week I will:**
- Finish moving the project into the template repository and check that it runs from a fresh clone.
- Complete the README, the screenshots, and the Privacy and secrets section.
- Record and upload the demo video.
- If there is time, improve the AI Health Assistant so its answers use the cat's real health records more, and keep the vet-disclaimer notice.


---
