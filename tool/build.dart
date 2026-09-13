// Builds ../site from the legal documents the app ships, so the website and
// the app can never show two different versions of the Terms.
//
//   cd ironfit-site/tool && dart pub get && dart run build.dart
//
// Output: ../site/{index,terms,privacy,waiver,delete-account,open}/index.html
// Pretty URLs (folder + index.html) so /privacy works on every static host.

import 'dart:io';

import 'package:markdown/markdown.dart' as md;

const site = 'https://ironfituae.com';

final legal = <String, String>{
  'terms': 'terms.md',
  'privacy': 'privacy.md',
  'waiver': 'waiver.md',
};

void main() {
  final root = Directory.current.parent;
  final legalDir = Directory('${root.parent.path}/ironfit-app/assets/legal');
  final out = Directory('${root.path}/site');
  out.createSync(recursive: true);

  for (final e in legal.entries) {
    final src = File('${legalDir.path}/${e.value}').readAsStringSync();
    final body = md.markdownToHtml(src, extensionSet: md.ExtensionSet.gitHubWeb);
    final title = RegExp(r'^#\s+(.+)$', multiLine: true).firstMatch(src)?[1] ?? e.key;
    _write(out, e.key, page(title.replaceFirst('IronFit — ', ''), body));
  }

  _write(out, '', page('IronFit', home, isHome: true));
  _write(out, 'delete-account', page('Delete your account', deleteAccount));
  _write(out, 'open', page('Open the app', openApp, extraHead: openRedirect));
  File('${out.path}/style.css').writeAsStringSync(css);
  File('${out.path}/CNAME').writeAsStringSync('ironfituae.com\n');
  File('${out.path}/.nojekyll').writeAsStringSync('');
  stdout.writeln('Built ${out.path}');
}

void _write(Directory out, String path, String html) {
  final dir = path.isEmpty ? out : Directory('${out.path}/$path')..createSync();
  File('${dir.path}/index.html').writeAsStringSync(html);
}

String page(String title, String body, {bool isHome = false, String extraHead = ''}) => '''
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${_esc(title)} · IronFit</title>
<link rel="stylesheet" href="/style.css">
$extraHead
</head>
<body>
<header>
  <a class="brand" href="/">IRONFIT</a>
  <nav>
    <a href="/terms/">Terms</a>
    <a href="/privacy/">Privacy</a>
    <a href="/waiver/">Waiver</a>
    <a href="/delete-account/">Delete account</a>
  </nav>
</header>
<main class="${isHome ? 'home' : 'doc'}">
$body
</main>
<footer>
  <p>IronFit · Dubai · <a href="mailto:ironfituae.app@gmail.com">ironfituae.app@gmail.com</a></p>
</footer>
</body>
</html>
''';

String _esc(String s) => s.replaceAll('&', '&amp;').replaceAll('<', '&lt;');

const home = '''
<h1>Iron sharpens iron.</h1>
<p class="lede">IronFit is the members' app for our CrossFit community in Dubai:
training cycles, Saturday sessions, guests, the community board and your own
training log.</p>
<p>The app is by invitation. Register from the app with your Google account and
a coach will approve you.</p>
<p class="stores">
  <a class="btn" href="https://play.google.com/store/apps/details?id=com.ironfit.ironfit">Get it on Google Play</a>
</p>
<p class="muted">iPhone: coming after the Android release.</p>
''';

const deleteAccount = '''
<h1>Delete your IronFit account</h1>
<p>You can delete your account and its data yourself, from inside the app:</p>
<ol>
  <li>Open IronFit and go to <strong>Profile</strong>.</li>
  <li>Scroll to <strong>Danger zone</strong> at the bottom.</li>
  <li>Tap <strong>Delete account</strong> and confirm.</li>
</ol>
<h2>What is deleted</h2>
<p>It is permanent. Your profile, emergency contact, weigh-ins, nutrition
diary, personal workouts, records, scores, completed workouts, reactions and
your sign-in identity all go. Everything is removed or anonymised within
30 days, and clears from backups within 30 days as they rotate.</p>
<h2>What is kept</h2>
<p>A record of your waiver acceptance (the name you typed, your guardian's
name if you were under 18, the version and the date) is kept for 6 years,
with no link back to an account. Where you were part of a team result, the
result stays for your teammates with your name removed. Bookkeeping entries
stay in the gym's books against an anonymised account. Details are in the
<a href="/privacy/">Privacy Policy</a>.</p>
<h2>If you no longer have the app</h2>
<p>Email <a href="mailto:ironfituae.app@gmail.com?subject=Delete%20my%20IronFit%20account">ironfituae.app@gmail.com</a>
from the Google account you registered with, with the subject
"Delete my IronFit account". We will confirm within 7 days.</p>
''';

const openApp = '''
<h1>Open the IronFit app</h1>
<p>If the app is installed, it should open now. If not:</p>
<p class="stores">
  <a class="btn" href="https://play.google.com/store/apps/details?id=com.ironfit.ironfit">Get it on Google Play</a>
</p>
<p class="muted">Then sign in with the same Google account you registered with.</p>
''';

// Try the app's own scheme first; the page stays behind as the fallback.
const openRedirect = '''
<script>
  setTimeout(function () { window.location.href = 'ironfit://open'; }, 150);
</script>
''';

const css = '''
:root { color-scheme: dark; }
* { box-sizing: border-box; }
body { margin: 0; background: #0B0B0D; color: #F5F5F5;
  font: 16px/1.6 Inter, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif; }
a { color: #F5F5F5; }
header { display: flex; align-items: center; justify-content: space-between; gap: 16px;
  padding: 20px 24px; border-bottom: 1px solid #2A2A30; flex-wrap: wrap; }
.brand { font-weight: 800; letter-spacing: 3px; color: #D22B2B; text-decoration: none; font-size: 22px; }
nav a { margin-left: 18px; color: #9E9EA6; text-decoration: none; font-size: 14px; }
nav a:hover { color: #F5F5F5; }
main { max-width: 720px; margin: 0 auto; padding: 32px 24px 64px; }
main.home h1 { font-size: 44px; line-height: 1.05; letter-spacing: 1px; margin: 24px 0 8px; }
.lede { font-size: 19px; color: #F5F5F5; }
.muted { color: #9E9EA6; font-size: 14px; }
.btn { display: inline-block; background: #D22B2B; color: #fff; text-decoration: none;
  padding: 12px 20px; border-radius: 12px; font-weight: 600; }
.btn:hover { background: #A31F1F; }
main.doc h1 { font-size: 32px; line-height: 1.15; }
main.doc h2 { font-size: 22px; margin-top: 32px; }
main.doc h3 { font-size: 17px; }
main.doc p, main.doc li { color: #E6E6EA; }
main.doc hr { border: 0; border-top: 1px solid #2A2A30; margin: 24px 0; }
main.doc table { border-collapse: collapse; width: 100%; font-size: 14px; }
main.doc th, main.doc td { border: 1px solid #2A2A30; padding: 8px; text-align: left; vertical-align: top; }
footer { border-top: 1px solid #2A2A30; padding: 20px 24px; color: #9E9EA6; font-size: 13px; text-align: center; }
footer a { color: #9E9EA6; }
''';
