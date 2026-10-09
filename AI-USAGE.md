# AI usage
> **Note:** I started this AI usage log later than intended. I reconstructed the earlier entries on 2026-10-04 using my actual Git commit history together with my AI chat history. The date shown on each entry is the date of the commit where that work was added to the project, not the date when I wrote this document. Each entry describes work that I actually performed and is linked to the corresponding Flutter/Dart code commit. On 2026-10-09, I split the original application implementation into feature-sized commits so each code change has its own link; those links reflect this history cleanup, not separate AI sessions.

**Approximate contribution split:** AI tools produced or helped draft about 80% of the implementation. I contributed the other 20% through the project idea and requirements, supplying the design references, reviewing and correcting generated code, making UI and behavior changes, and deciding what to keep. This is my estimate of the overall work, not a measurement from Git.


## 1. How I used AI

### 2026-09-24 - Built the initial Back2me application

- **Tool:** Codex
- **What I asked for:** I gave the AI my Back2me proposal, design system, and application mockups in PDF form. I asked it to create the initial Flutter version of the application with the five main screens: Login, Home, Item Details, History, and Add/Edit Lending Record. I also asked it to follow the mockups while improving spacing and sizing using the design system I provided.
- **What it gave back:** It generated the initial `lib/` structure, including the main screens, reusable widgets, Hive data models and adapters, local storage, navigation, application state, theme files, sample data, and date utilities.
- **Commit:** https://github.com/skpriniel/Back2me/commit/644de7bd96a2a9b229c248543bcd1fadc8836ea4

### 2026-09-26 - Reviewed Hive storage and application state

- **Tool:** Copilot
- **What I asked for:** I asked for help organizing the application so items, borrowers, lending records, and the user profile could be stored locally and remain synchronized with the interface.
- **What it gave back:** It created a `StorageService` using Hive and an `AppState` class using `ChangeNotifier`. The state logic handled loading stored data, adding and editing items, finding or creating borrowers, creating lending records, marking records as returned, and saving changes back to Hive.
- **Commit:** https://github.com/skpriniel/Back2me/commit/031268298082c63deaadc97ca5312f1418a6e08b

### 2026-09-28 - Improved lending form validation

- **Tool:** Copilot
- **What I asked for:** I asked for the Add/Edit Lending Record screen to validate lending information before saving and to work for both creating a new record and editing an existing active record.
- **What it gave back:** It created form validation for borrower information, contact information, item selection, borrow and return dates, notes, and edit mode.
- **Commit:** https://github.com/skpriniel/Back2me/commit/eaf072f8125b28c0cb9f884fc10b628d28606a4c

### 2026-09-30 - Fixed Home and History filter controls

- **Tool:** Codex
- **What I asked for:** The `Available` filter on the Home screen was dropping onto a second line instead of staying beside the other filter options. I asked the AI to keep all three filters on one row and apply the same fix to the History screen for consistency.
- **What it gave back:** It changed the filter controls into equal-width elements and used `FittedBox` so the label content could scale down when necessary instead of wrapping onto another line.
- **Commit:** https://github.com/skpriniel/Back2me/commit/f55f5f086d0e3f89ac662e5317e6c5865b450a13

### 2026-10-02 - Reviewed responsive layout and Flutter web presentation

- **Tool:** Copilot
- **What I asked for:** I asked for Back2me to remain mobile-first while still displaying properly when opened through Flutter web on a larger browser window.
- **What it gave back:** It added a maximum-width wrapper around the main application and integrated `DevicePreview` to make it easier to check different screen sizes during development.
- **Commit:** https://github.com/skpriniel/Back2me/commit/40ea21636933447dfe484d304c26d2ff6a436c19

### 2026-10-03 - Improved item return and deletion safeguards

- **Tool:** Codex
- **What I asked for:** I asked for the Item Details screen and application state to handle item returns and deletion more safely. I wanted the app to prevent users from deleting an item while it still had an active lending record and to properly update the item when it was marked as returned.
- **What it gave back:** It added checks for active lending records before deletion, a confirmation dialog before removing an item, and logic for marking a lending record as returned while changing the related item's status back to available.
- **Commit:** https://github.com/skpriniel/Back2me/commit/920c286115d1a7bfdaf7c5f7e5b8888481a81639

## 2. Where the AI got it wrong

### Case 1 - Leftover invalid code in the lending record screen

- **What it gave me:** During an earlier version of the Add/Edit Lending Record screen, the AI left behind an unused method:
- **What was wrong with it:** AppState_ was not a real type in the project. The method was leftover from an earlier implementation approach and was no longer being used. Keeping the method would have caused a compilation problem.
- **What I did instead:** I removed the invalid method and checked the surrounding code for other leftover references or unused code from the earlier approach.
- **Commit:** https://github.com/skpriniel/Back2me/commit/031268298082c63deaadc97ca5312f1418a6e08b

### Case 2 - Filter controls did not fit smaller screens correctly

- **What it gave me:** The first generated Home screen used filter controls that could not always fit beside one another. The Available filter could move onto a second row.
- **What was wrong with it:** The layout did not handle limited mobile width properly. This made the filter section inconsistent and did not match the intended single-row design.
- **What I did instead:** I changed the filter controls so they share the available horizontal space equally and allowed their content to scale down instead of wrapping. I also applied the same layout to the History screen so both filtering interfaces behave consistently.
- **Commit:** https://github.com/skpriniel/Back2me/commit/f55f5f086d0e3f89ac662e5317e6c5865b450a13

### Case 3 - Device Preview was left enabled for the final application

- **What it gave me:** The generated application started inside DevicePreview with `enabled: true`.
- **What was wrong with it:** Device Preview is useful while developing and checking different screen sizes, but leaving it enabled in the final deployed application is unnecessary and can affect how the finished application is presented.
- **What I did instead:** I used Device Preview while checking the responsive layout, then disabled it for the final application so the deployed version opens directly as the normal Back2me interface.
- **Commit:** https://github.com/skpriniel/Back2me/commit/40ea21636933447dfe484d304c26d2ff6a436c19

## 3. Who wrote what

At least a fifth of this project is code you wrote yourself. Name it, and explain
it in your own words.

> Group projects: give each member their own heading below, and use your GitHub
> handle as the heading. You are graded on your own section.

### Written by me

- **Files:** `lib/screens/home_screen.dart`, `lib/screens/lending_records_screen.dart`, and the project documentation under `docs/`
- **Commit:** https://github.com/skpriniel/Back2me/commit/f55f5f086d0e3f89ac662e5317e6c5865b450a13
- **What it does and why it is built this way:** I refined the Home and History layouts so the filter controls fit together consistently, and I reviewed the screens as part of making the app usable on different screen sizes. I also supplied the project proposal, design direction, and mockup references, then wrote and revised the supporting project reports and documentation. The UI changes keep the screens aligned with the design while making the controls easier to use.

### The AI-written part I understand best

- **File:** `lib/widgets/item_card.dart`
- **Commit:** https://github.com/skpriniel/Back2me/commit/aacdaf5b6007dc7535b6a07e4272eb2263003f3e
- **What it does and why we kept it:** This widget presents an item's name, category, condition, and availability in the Home screen. I kept the reusable card because it gives every item a consistent presentation and keeps layout details out of the screen logic.
