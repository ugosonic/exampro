App launcher icon

Overview
- A new multi‑country icon SVG has been added: `assets/images/app_icon_multi.svg`.
- It represents UK, US, CA and AU with a globe and four small badges.
- Use `flutter_launcher_icons` to generate Android/iOS launcher icons from a 1024×1024 PNG.

Steps
1) Export PNG
   - Open `assets/images/app_icon_multi.svg` in an editor (Figma/Inkscape/Illustrator).
   - Export at 1024×1024 px as `assets/images/app_icon.png`.

2) Generate platform icons
   - Ensure deps are fetched: `flutter pub get`.
   - Run: `dart run flutter_launcher_icons` (or `flutter pub run flutter_launcher_icons`).

What the config does
- `pubspec.yaml` contains a `flutter_icons` section using `assets/images/app_icon.png` for both Android and iOS, with an adaptive background color for Android.

Reverting/Updating
- To change the design, edit the SVG, re‑export the PNG, and rerun the generator command above.

