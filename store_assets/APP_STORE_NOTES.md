# GreaseTrail — App Review Information Notes

Response to Apple App Review Guideline 2.1 (Information Needed - New App Submission).
Paste into App Store Connect → App Review Information → Notes for future submissions.

---

**1. Screen recording:** Captured on a physical device, starting from app launch
and covering the typical user flow: Garage overview → adding a vehicle → logging
a service entry → viewing due/overdue status → Setup screen (configs, export).
No account, login, purchase, or UGC-sharing flow exists, so none of those appear.
The only permission prompts are Camera and Photo Library, shown when attaching a
photo to a log entry — one of those is included in the recording.

**2. Devices/OS tested:**
Tested on a physical iPhone 17 Pro running iOS 27 beta 6.

**3. App description & target audience:**
GreaseTrail is an offline vehicle maintenance tracker for owners of cars,
motorcycles, bicycles, scooters, and mopeds. It solves the problem of forgotten
or disorganized maintenance history by letting users log service events (oil
changes, tire checks, brake pads, etc.) per vehicle, set distance/time-based
reminder intervals per maintenance category, and see at a glance what's due or
overdue. Target audience: any vehicle owner — from a single daily driver to
someone managing a multi-vehicle garage — who wants a simple, private, ad-free
logbook without a subscription or cloud account.

**4. Setup / accessing main features:**
No login or account is required — GreaseTrail has no authentication system. On
first launch, the user is guided through an Add Vehicle wizard (select vehicle
type → name → optional photo) and can immediately start logging maintenance.
No sample files or credentials are needed to access any feature.

**5. External services used:**
None. GreaseTrail makes no network requests and uses no third-party SDKs,
analytics, ad networks, authentication providers, or payment processors. All
data is stored locally on-device via `shared_preferences` and the app's
documents directory. Export features (PDF/CSV/JSON) write files locally and
hand off to the system share sheet — no server-side component.

**6. Regional differences:**
The app functions identically in all regions/languages — there is no
region-locked content, pricing variation, or feature gating by locale.

**7. Regulated industry / protected material:**
Not applicable — GreaseTrail does not operate in a regulated industry and
includes no licensed or protected third-party material.

---

## Open item

- Item 2 currently lists only a beta OS (iOS 27 beta 6). Apple's review team
  tests on the current public iOS release, not a beta — consider also testing
  on the latest shipping iOS before resubmitting, and updating this note if
  that testing turns up anything.
