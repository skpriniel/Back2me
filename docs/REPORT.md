# Weekly Increment Report

## Week of: September 21-27, 2026

## What changed this week
- Finalized the Back2me app proposal and revised the MVP features.
- Decided to use Hive CE for local data storage.
- Created and tested a Hive prototype in Flutter that can save and retrieve item records.
- Confirmed that stored data remains available after restarting the application.
- Finalized the main Back2me mockup screens: Login, Home, Item Details, Lending Records/History, and Add Lending Record.
- Updated the mockup to include lending-specific components such as status badges, return reminders, borrower contact actions, and due-date quick-select options.
- Started preparing the project documentation and README.

## Why

These changes were made to finalize the app structure before starting the main implementation. Testing Hive early also helped confirm that Back2me can store its lending data locally without needing a server or API for the MVP.

## What broke or what I got stuck on

One challenge was making sure the updated mockup, proposal, and planned features were consistent with each other. I also needed to decide how the different data models would be connected, especially the Item, Borrower, and LendingRecord data. The main implementation of these models and their CRUD functions is still in progress.

## What is left

- Implement the Item, Borrower, LendingRecord, and UserProfile models.
- Complete the Hive storage implementation.
- Build the main Back2me screens in Flutter.
- Implement CRUD functions for items and lending records.
- Connect lending records to the correct items and borrowers.
- Implement the Available → Borrowed → Returned status flow.
- Test the application and fix bugs.
- Complete the remaining documentation.
- Implement push notifications only if the MVP is completed early.
