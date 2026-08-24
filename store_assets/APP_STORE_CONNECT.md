# GreaseTrail — App Store Connect listing

Everything below is ready to copy-paste into App Store Connect. Items marked
**⚠️ YOU NEED TO FILL IN** are things only you can provide (accounts, legal
name, URLs, pricing) — I can't invent those safely.

---

## App Information

**Name** (30 char max)
```
GreaseTrail
```

**Subtitle** (30 char max)
```
Vehicle Maintenance Tracker
```

**Bundle ID**
```
com.lemairtech.greasetrail
```

**SKU** (any unique string you pick, e.g. `greasetrail-ios-001`)
```
⚠️ YOU NEED TO FILL IN
```

**Primary category:** Utilities
**Secondary category:** Lifestyle

**Copyright**
```
© 2026 ⚠️ YOUR NAME OR COMPANY NAME
```

---

## Pricing & Availability

```
⚠️ YOU NEED TO FILL IN — price tier (e.g. Free, or a paid tier) and which
countries/regions to release in.
```

---

## Promotional text (170 char max — can be changed anytime without a new review)

```
Keep every oil change, tire check, and service reminder in one place. Track any number of vehicles, each with its own maintenance history and due-date alerts.
```
(That's 168 characters — trim if needed.)

---

## Description (4000 char max)

```
GreaseTrail is a simple, offline-first maintenance log for anything with an
engine or a chain — motorcycles, cars, bicycles, scooters, and mopeds.

TRACK EVERY VEHICLE
Add as many vehicles as you like. Each one gets its own odometer, photo
gallery, and maintenance checklist tailored to its type.

NEVER MISS A SERVICE
Set reminder intervals by distance or time for any maintenance category —
oil changes, tire pressure, chain tension, brake pads, coolant, and more.
GreaseTrail tells you what's overdue and what's coming up, right on your
Garage screen.

LOG WHAT YOU DID
Record a maintenance entry with the details that matter — odometer reading,
measurements, notes, and photos. Bundle related tasks into a single Service
visit (e.g. "Minor service") so one log entry covers everything you did.

REUSABLE CONFIGS
Build a maintenance checklist once and save it as a Config, then apply it to
every new vehicle of that type. Import or export configs as files to share
them or back them up.

YOUR OWN COLORS
Pick an accent color for the app, or give each vehicle its own — so when you
scroll through your combined maintenance log, you can tell your vehicles
apart at a glance.

YOUR DATA STAYS YOURS
GreaseTrail works entirely offline. Everything is stored on your device —
no account, no sign-up, no ads, no tracking. Export a full backup (JSON),
a spreadsheet-ready log (CSV), or a shareable PDF report whenever you want.

Whether you're keeping a single daily driver running smoothly or managing a
garage full of bikes, cars, and everything in between, GreaseTrail keeps the
maintenance history organized so you always know what's due.
```

---

## Keywords (100 char max, comma-separated)

```
maintenance,vehicle,motorcycle,car log,service,mileage,oil change,garage,tracker,reminder
```
(90 characters)

---

## Support URL *(required)*

```
⚠️ YOU NEED TO FILL IN — e.g. a GitHub repo issues page, a simple page on
your own site, or even a mailto: page. Apple requires a real reachable URL.
```

## Marketing URL *(optional)*

```
⚠️ optional — a landing page for the app, if you have one.
```

## Privacy Policy URL *(required — mandatory even for offline apps)*

```
⚠️ YOU NEED TO FILL IN — you need to host the text below somewhere public
(a GitHub Pages page, a Notion page shared publicly, a simple static page,
etc.) and put that URL here.
```

A ready-to-host draft is below — see **Privacy Policy (draft text)**.

---

## App Privacy questionnaire (App Store Connect → App Privacy)

Since GreaseTrail stores everything locally and makes no network requests,
you should be able to answer:

- **Data collection:** "No, we do not collect data from this app."
- The camera/photo library permissions are used only to attach photos
  locally to your own records — nothing is uploaded anywhere.

---

## Age Rating questionnaire

There's no objectionable content (violence, mature themes, gambling, etc.),
so every question should get the "None" / lowest answer, resulting in an
**Age 4+** rating.

---

## Version Release Notes ("What's New in This Version")

For a first submission, App Store Connect doesn't require this field. If it
asks anyway:
```
Initial release.
```

---

## Privacy Policy (draft text)

Host this somewhere public and put the URL above.

```
Privacy Policy — GreaseTrail

Last updated: [date]

GreaseTrail does not collect, transmit, or share any personal data. All
vehicle, maintenance, and photo data you enter is stored locally on your
device only, using standard iOS local storage. Nothing is sent to us or to
any third party — GreaseTrail has no servers and makes no network requests.

Camera and Photo Library access, when granted, is used solely to let you
attach photos to your own vehicle and maintenance records on your device.
These photos never leave your device unless you explicitly export or share
them yourself (e.g. via the app's PDF/CSV/JSON export or the system share
sheet).

If you delete the app, all of its locally stored data is removed with it.

Questions about this policy can be sent to: [your contact email]
```

---

## Screenshots

Captured from the actual running app (Flutter iOS simulators), using the
built-in demo vehicle ("Dad's Oldtimer" — no real brand names, to keep
marketing screenshots generic).

### iPhone 6.9" (required — e.g. iPhone 17 Pro Max), 1320×2868
`store_assets/screenshots/iphone_6_9/`
1. `01_garage.png` — Garage overview with odometer + Needs Attention
2. `02_log.png` — Combined maintenance log across vehicles
3. `03_vehicle_detail.png` — Vehicle detail: odometer, photos, service, categories
4. `04_setup.png` — Setup: vehicles, configs, export
5. `05_add_vehicle.png` — Add Vehicle wizard (type step)

### iPad 13" (required since the app supports iPad), 2064×2752
`store_assets/screenshots/ipad_13/`
1. `01_garage.png` — Garage overview
2. `02_vehicle_detail.png` — Vehicle detail with full category list
3. `03_setup.png` — Setup, including the new accent color picker

Apple auto-scales the 6.9" iPhone set down for smaller iPhone displays, so
no other iPhone sizes are required. If you want more screenshots (Apple
allows up to 10 per size), let me know and I can capture more.

---

## Notes / things I couldn't do for you

- I can't create your App Store Connect app record, App ID, or provisioning
  — that needs your Apple Developer account.
- I can't pick your price, SKU, or company/legal name.
- I can't host the privacy policy page — you'll need to publish the draft
  above somewhere (GitHub Pages is free and works well for this).
- The app currently opts out of iPad Split View / Slide Over
  (`UIRequiresFullScreen`), since the UI isn't built for those layouts. If
  you'd rather I build proper tablet/multitasking support, that's a larger
  follow-up task.
