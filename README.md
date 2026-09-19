# ironfituae.com

The public site: home, Terms, Privacy Policy, Waiver, account deletion,
and the `/open` landing the emails link to. Built from the same markdown
the app ships (`ironfit-app/assets/legal`), so the site and the app cannot
disagree about what a member accepted.

The domain is registered at AEserver and currently points at their parking
page. Port 443 is closed there, so every `https://ironfituae.com/...` link
in the app's emails is dead until this site is hosted somewhere with TLS.
Google Play will not accept the listing without a live privacy policy URL.

## Build

```bash
cd ironfit-site/tool
dart pub get
dart run build.dart
```

Output is `ironfit-site/docs/` (GitHub Pages only publishes the repo root or `/docs`). Re-run after any change to the legal
markdown; bump the version and effective date in the markdown, not here.

## Host (pick one, all free, all give HTTPS)

**GitHub Pages** — the simplest.
1. Create a repo `ironfit-site`, push this folder.
2. Settings → Pages → Source: Deploy from branch, folder `/docs`
   (or `CNAME` and `.nojekyll` are already in `docs/`).
3. Settings → Pages → Custom domain: `ironfituae.com`, tick Enforce HTTPS.

**Cloudflare Pages** or **Netlify** — drag the `docs/` folder onto their
dashboard, then add the custom domain.

## DNS (at AEserver)

Replace the parking records with the host's. For GitHub Pages:

| Type | Name | Value |
|---|---|---|
| A | @ | 185.199.108.153 |
| A | @ | 185.199.109.153 |
| A | @ | 185.199.110.153 |
| A | @ | 185.199.111.153 |
| CNAME | www | `<your-github-user>.github.io` |

Cloudflare/Netlify give you their own values on the custom-domain screen.
Allow up to a day for DNS; HTTPS is issued automatically once it resolves.

## After it is live

Check every link the app sends: `/terms/`, `/privacy/`, `/waiver/`,
`/delete-account/`, `/open`. The `SITE` constant in the edge functions is
`https://ironfituae.com`; nothing there needs to change.
