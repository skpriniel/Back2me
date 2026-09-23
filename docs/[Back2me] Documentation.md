**Back2me**

## 1. Overview

Back2me is a personal belongings lending tracker that helps users keep track of items they lend to other people. It records information about items, borrowers, lending dates, return dates, and item status so users can avoid forgetting who borrowed their belongings. It is designed for people who frequently lend personal items to friends, family, classmates, or coworkers.

The app uses local storage, so each user has their own items and lending records. The MVP does not require a server because one user's records should not appear on another person's device.

## 2. Setup and installation

**Requirements**
- Flutter SDK
- Dart SDK
- VS Code
- Google Chrome

**Flutter Version**: In progress

**Dart Version**: In progress

**In Steps**
1. Check your installed version: flutter --version
2. Clone the repository: git clone [repo link]
3. cd back2me
4. Run: flutter pub get

**Configuration**
No API keys or backend URL are required for the MVP. Back2me uses local storage with Hive/Hive CE instead of an external server.

## 3. How to run it
Run the application using: flutter run -d web-server


## 4. Features and usage

**Login Screen**
The Login Screen allows the user to sign in to their Back2me account. The user enters their email and password, with an option to show or hide the password. Users who do not have an account can proceed to the account creation screen, while the Forgot Password option provides access to the password reset flow.

**Home Screen**
The Home Screen provides an overview of the user's lending activity. It displays owned, borrowed, and returned item counts and allows users to search or filter their items. Users can select an item to view its details or use the + Add Lending button to create a new lending record. The Home Screen also provides a nudge option for items with approaching return dates.

**Item Details Screen**
The Item Details Screen displays the complete lending information for a selected item. The user can view the item's lending timeline and borrower information. Contact options are available through the call and message buttons. The user can also send a reminder to the borrower, mark the item as returned, or edit its details.

**Lending Records Screen**
The Lending Records / History Screen allows the user to review their lending activity. It displays information about the user's return rate and active lending records. The user can switch between All, Active, and Returned records and select a record to view its details.

**Add Lending Record Screen**
The Add Lending Record Screen allows the user to create a new lending record. The user selects an item, enters the borrower's name and contact number, and sets the borrow and due dates. The user can also enable SMS reminders. Quick-select options for 3 days, 1 week, or 2 weeks can automatically set the due date. If the item is not yet registered, the user can select + New Item to create it.

**Primary Flow**
The primary flow begins when the user signs in through the Login Screen. From the Home Screen, the user can search or filter their items and select an item to view its details. To lend an item, the user selects + Add Lending and fills in the required lending information. The new record can then be viewed and monitored through the Lending Records / History Screen. When the item is close to its due date, the user can send a nudge to the borrower. Once the item is returned, the user can mark it as returned through the Item Details Screen.

## 5. Project structure
lib/
- main.dart
- Screens/
  -login_screen.dart
  -home_screen.dart
  -item_details_screen.dart
  -lending_records_screen.dart
  -add_lending_record_screen.dart
-Models/
  -item.dart
  -lending_record.dart

**Important Files**
main.dart: Entry point of the Back2me Flutter application.
screens/: Contains the main screens of the application.
login_screen.dart: Handles the Login Screen and user sign-in interface.
home_screen.dart:	Displays the user's items and lending activity.
item_details_screen.dart:	Displays the details and current lending status of an item.
lending_records_screen.dart: Displays active and previous lending records.
add_lending_record_screen.dart:	Provides the form for creating or editing a lending record.
models/:	Contains the data models used by the application.
item.dart: Defines the information stored for each item.
lending_record.dart: Defines the information stored for each lending transaction.
 


## 6. Screenshots

At least one screenshot per screen the app has.

## 7. Known issues and next steps

**Known Issues**
-Push notifications are currently a stretch goal and are not required for the main MVP.
-Item photos, search, category filtering, and direct contact with borrowers are also planned as stretch goals.
-Incorrect connections between items, borrowers, and lending records could cause the wrong information to be displayed.
-Item status and lending status need to remain synchronized when an item is borrowed or returned. These are the main technical risks
identified in the revised proposal.

**Next Steps**
-Complete CRUD functionality for the main records.
-Connect items and borrowers correctly to lending records.
-Implement and test the Available → Borrowed → Returned status flow.
-Complete Hive/Hive CE storage.
-Test that saved records remain available after restarting the application.
-Test the application on the web version.
-Implement stretch goals after the main MVP features are complete.
-Add push notifications only if the MVP is completed early.

## How it is graded

See `rubrics.md` in this unit for the exact point breakdown. In short: your setup
and run steps must actually work (that is the largest share), your feature and
usage docs must match what the app really does, and screenshots plus clear
writing carry the rest.

## Security checklist (from week 2)

From week 2 your documentation also includes a completed `SECURITY-CHECKLIST.md`
in your workspace `project/` folder. Copy `security-checklist-template.md` from
this unit and fill it in.

Every row is answered Yes, No or N/A, with one line of evidence in your own
words. "N/A" is a correct answer when it is true, and it needs its reason
written next to it. Fill it in **before** you make your repository public, not
after, because that is the point of it. It is worth 3 of the 15 points in
week 2.

## AI usage

Your repository must also carry an `AI-USAGE.md` and a credit line in the
README. That file is graded separately, as your finals badge, and it is worth
100 points; see the `finals-badge` unit for what goes in it. For your weekly
Documentation Update all that is checked is that the file **exists and is
current**, so start it in week 1 and keep it up as you go.
