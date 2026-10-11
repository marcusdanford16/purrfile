# PurrFile redesign v2

Unzip over your project root (contains lib/ and test/ only).
No new packages. pubspec.yaml and assets/ are NOT included - leave yours alone.

New:  lib/widgets/paw_logo.dart  (PurrLogo + PawMarkPainter, drawn in code)
      lib/widgets/decor.dart     (PurrBackdrop hills, CatPeek, PawPrints)
Changed: Home (greeting, cat card, FAB, header), shell backdrop, bottom nav,
         login header, tile radii. Includes the reminders boolean fix.
The old logo PNGs in assets/images are no longer used (safe to keep).
