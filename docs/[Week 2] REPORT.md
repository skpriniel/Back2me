# Weekly Increment Report

## Week of: September 23-27, 2026

## What changed this week
- Continued developing the Back2me project based on the finalized proposal and mockup.
- Updated and organized the project documentation, including the Overview, Setup and Installation, How to Run It, Features and Usage, and Project Structure sections.
- Documented the purpose and usage of the Login, Home, Item Details, Lending Records/History, and Add Lending Record screens.
- Documented the primary user flow from logging in, creating a lending record, monitoring an item, and marking it as returned.
- Added the current screenshots of the application to the documentation.
- Documented the known issues and next steps for the project.
- Clarified the remaining MVP tasks, including CRUD operations, data relationships, status management, and Hive/Hive CE integration.
- Identified features such as push notifications, item photos, filtering, and direct borrower contact as stretch goals so the core MVP can remain the priority.

## Why

These changes were made to keep the documentation consistent with the current state of Back2me and to clearly define what still needs to be implemented. Organizing the documentation also helped identify which features are part of the core MVP and which can be added later if there is enough time.

## What broke or what I got stuck on

One challenge was keeping the documentation aligned with the actual design and planned functionality of the app. Some features are still being developed, so I had to make sure that the documentation did not describe them as fully implemented when they are still in progress.

I also need to properly connect the Item, Borrower, and LendingRecord data so that changes in lending status are reflected correctly. Testing the Available → Borrowed → Returned workflow and making sure the data persists after restarting the application are also still part of the remaining implementation work.

## What is left

- Complete the Item, Borrower, LendingRecord, and UserProfile models.
- Complete the Hive/Hive CE local database integration.
- Implement CRUD operations for the core entities.
- Connect items and borrowers correctly within lending records.
- Implement and test the Available → Borrowed → Returned status workflow.
- Complete the main Flutter screens and connect them to the data.
- Test data persistence after restarting the application.
- Test the web version and check browser compatibility.
- Complete the remaining screenshots and documentation.
- Fix bugs and improve the overall consistency of the app.
- Consider stretch goals such as push notifications, filtering, item photos, and profile features after the core MVP is completed.
