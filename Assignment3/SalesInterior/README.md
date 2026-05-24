# Sales Interior – iOS App

**Student Name:** Shaan Ul Islam  
**Student ID:** 733837

---

## Overview

Sales Interior is a native iOS application built using **Swift** and **UIKit** (Storyboard approach) for managing client house projects. It allows a salesperson to record window and floor measurements for each room of a client's property, attach reference photos, link products from a catalog, and generate shareable cost quotes. All data is persisted and synchronised in real time using **Firebase Firestore**.

This iOS implementation mirrors the Assignment 2 Android workflow, redesigned for native iOS using Storyboard with `UITableViewController`-based navigation.

---

## Development Environment

- **IDE:** Xcode 26.5
- **Language:** Swift 6.3.2
- **Minimum iOS Version:** iOS 15
- **Target Device:** iPhone 17 Pro Simulator (ios 26.5)
- **Orientation:** Portrait only
- **Photo Picker:** Photo Gallery only (Camera mode unavailable in Simulator)

---

## App Structure & View Controllers

The application is organised around a small group of view controllers that work together in a top-down navigation flow rooted in a `UINavigationController`. Each screen leads naturally to the next.

| # | View Controller | Purpose |
|---|---|---|
| 1 | `HouseListViewController` (Dashboard) | Root screen — lists all client houses |
| 2 | `AddHouseViewController` | Modal form for creating a new house |
| 3 | `HouseDetailViewController` | Lists rooms inside a house, lets user add a room |
| 4 | `RoomDetailViewController` | Adds window/floor measurements + room photo |
| 5 | `QuoteViewController` | Generates the cost summary, with a Share action |

### How the View Controllers interrelate

**`HouseListViewController`** is the root screen embedded in a `UINavigationController`. It uses a `UITableViewController` style and attaches a Firestore snapshot listener (`addSnapshotListener`) to the `houses` collection, so the list updates in real time. The `+` bar button opens `AddHouseViewController` modally inside a fresh `UINavigationController` so the modal has its own nav bar with a Cancel/Save button pair.

**`AddHouseViewController`** is a form-based view controller that uses a vertical UIStackView in a UIScrollView. All five input fields (client name, project code, street, city, postcode) are validated by `ValidationManager` before the new house is written to Firestore. The screen dismisses itself on success and the dashboard's listener picks up the new house automatically.

**`HouseDetailViewController`** receives the selected `House` from the dashboard via `prepare(for:sender:)`. It listens to the `rooms` subcollection at `houses/{houseId}/rooms` and shows the list. Tapping a row segues to `RoomDetailViewController`. A toolbar `View Quote` button segues to `QuoteViewController`.

**`RoomDetailViewController`** is the most feature-rich screen. It contains:
- A header label for the room name
- Two side-by-side text fields for window Width and Height inside a horizontal `UIStackView`
- A button to add the window measurement (with product picker)
- A text field for floor area + button to add the floor measurement
- A `Select Photo` button + `UIImageView` for the room photo (loaded via `ImageManager` which wraps `UIImagePickerController`)
- A `UITableView` listing all measurements added so far, with swipe-to-delete

After picking a product via a `UIAlertController.Style.actionSheet`, the measurement is written to the room document inside its `measurements` array using a Firestore transaction. Selected photos are compressed (max 800px / JPEG quality 0.1–0.7), base64-encoded, and stored as an `imageData` field on the room document so that they survive app restarts without needing Firebase Storage.

**`QuoteViewController`** loops over every room and measurement, computes `Σ (area × productPrice)`, formats a plain-text summary, and shows it in a non-editable `UITextView`. The Share button presents a `UIActivityViewController` so the quote can be sent via email, Messages, AirDrop, Notes, etc.

### Supporting Components


`FirebaseManager`: Singleton wrapping all Firestore CRUD (houses, rooms, measurements, products, room images)
`ValidationManager`: Centralised form-validation rules used by every form
`ImageManager` (with `ImageManagerDelegate`): Wraps `UIImagePickerController` and forwards selected images back to the host view controller
`House`, `Room`, `Measurement`, `Product`: `Codable` model structs decorated with `@DocumentID` for Firestore round-trip

---

## Architecture & Technical Details

- **Language:** Swift 6.3.2
- **UI Approach:** UIKit + Storyboard (single `Main.storyboard` with all scenes)
- **Persistence:** Firebase Firestore (Spark / free tier)
- **Database schema:** `houses/{houseId}` → `rooms/{roomId}` subcollection → `measurements` array embedded in each room document
- **Real-time sync:** Firestore `addSnapshotListener` on the dashboard, house detail, and room detail screens
- **Image persistence:** JPEG → base64 → string field on the room document. client-side compression keeps each image well under the 1 MiB Firestore document limit (the free Spark plan limit for a single document)
- **Sharing:** `UIActivityViewController` for the Share Quote feature
- **Input validation:** All numeric fields use `Double(_:)` initialiser with > 0 check; text fields trimmed and length-checked through `ValidationManager`

---

## References

### Official Documentation

**Firebase Firestore**
- [Get Realtime Updates (iOS)](https://firebase.google.com/docs/firestore/query-data/listen) — Real-time listeners used for syncing houses, rooms, and measurements across the app.
- [Add Data (iOS)](https://firebase.google.com/docs/firestore/manage-data/add-data) — Methods for creating and updating documents with Codable structs.
- [Transactions and Batched Writes](https://firebase.google.com/docs/firestore/manage-data/transactions) — Used when atomically updating room measurements arrays.
- [Use Custom Objects with Firestore](https://firebase.google.com/docs/firestore/manage-data/add-data#custom_objects) — Integration with `@DocumentID` and Swift `Codable`.
- [Add Firebase to Your Apple Project](https://firebase.google.com/docs/ios/setup) — Setup via Swift Package Manager and GoogleService-Info.plist configuration.
- [Get Started with Firestore](https://firebase.google.com/docs/firestore/quickstart) — Initial project setup and basic CRUD patterns.

**Apple UIKit & Storyboard**
- [UIImagePickerController](https://developer.apple.com/documentation/uikit/uiimagepickercontroller) — Photo Gallery picker wrapped in `ImageManager`.
- [UIActivityViewController](https://developer.apple.com/documentation/uikit/uiactivityviewcontroller) — Share Quote functionality via email, Messages, AirDrop, etc.
- [UIStoryboardSegue & prepare(for:sender:)](https://developer.apple.com/documentation/uikit/uistoryboardsegue) — Data passing between view controllers.
- [UITableViewController](https://developer.apple.com/documentation/uikit/uitableviewcontroller) — Dashboard, house list, and room list screens with swipe-to-delete.
- [Human Interface Guidelines – Layout](https://developer.apple.com/design/human-interface-guidelines/layout) — 44pt tap targets, standard margins, and spacing.

### Tutorials & Codelabs

- [Firebase iOS Codelab](https://codelabs.developers.google.com/codelabs/firebase-ios-swift/) — Quickstart for Firebase setup on iOS with Swift.
- [Firebase iOS SDK on GitHub](https://github.com/firebase/firebase-ios-sdk) — Open source SDK reference and installation guidance.

### YouTube Tutorials (Storyboard Approach)

- [iOS App Development with Xcode & Storyboard – Full Course](https://www.youtube.com/results?search_query=ios+app+development+xcode+storyboard+tutorial) — Comprehensive beginner-friendly tutorials on UIViewController, UITableView, and Storyboard wiring.
- [Swift UITableViewController Tutorial](https://www.youtube.com/results?search_query=swift+uitableviewcontroller+storyboard+tutorial) — Practical examples of table view setup, data sources, and delegates.
- [Firebase iOS Integration – Storyboard](https://www.youtube.com/results?search_query=firebase+ios+storyboard+tutorial) — Step-by-step Firebase Firestore setup with Storyboard-based projects.
- [UIStackView & Auto Layout in Storyboard](https://www.youtube.com/results?search_query=uistackview+auto+layout+storyboard+tutorial) — Building responsive layouts without code.
- [Passing Data Between View Controllers (Segues)](https://www.youtube.com/results?search_query=passing+data+between+view+controllers+segue+swift) — Using `prepare(for:sender:)` and segue identifiers.
- [UIImagePickerController & Photo Gallery](https://www.youtube.com/results?search_query=uiimagepickercontroller+swift+tutorial) — Image selection and handling in iOS.
- [UIActivityViewController – Share Functionality](https://www.youtube.com/results?search_query=uiactivityviewcontroller+share+swift+tutorial) — Implementing native share sheets.

### Stack Overflow & Community

- **Pass data between ViewControllers via segues** — Referenced for `prepare(for:sender:)` implementation in navigation flow.
  https://stackoverflow.com/questions/20017026
- **@DocumentID not being decoded** — Confirmed that `id` field must be included in `CodingKeys` when using the property wrapper.
  https://stackoverflow.com/q/63111463
- **UITableView row contents truncation** — Layout and content sizing guidance.
  https://stackoverflow.com/questions/20399998/ios-row-in-uitableview-contents-getting-truncated
- **UIStackView with multiple nested stacks** — Side-by-side input fields and complex layouts.
  https://stackoverflow.com/questions/47485200/xcode-storyboard-multiple-stack-views-with-a-mulitline-label
- **UIStackView, UIImageView, and content modes** — Image scaling and aspect ratio management.
  https://itnext.io/uistackview-uiimageview-distribution-axis-spacing-and-clips-to-bounds-and-content-mode-cc993298e0b1
- **Firebase iOS SDK issues** — Image encoding and Firestore document limits.
  https://github.com/firebase/firebase-ios-sdk/issues/9523

---

## Use of Generative AI

Generative AI (ChatGPT and Grok) was used **as a debugging and reference aid only** during this project. The overall structure follows the Assignment 1 prototype and Assignment 2 Android implementation, both designed independently.

**Some questions which was asked during the development of this project to Grok and ChatGPT:**

1. "My `@DocumentID` property is always `nil` after fetching, what am I missing?" This question pointed me to include `id` in `CodingKeys`.
2. "How do I attach a real-time listener in `viewDidLoad` and remove it in `deinit` without leaking?"
3. "How do I compress a `UIImage` to base64 while staying under Firestore's 1 MiB document limit?"
4. "Why is my `UITableViewCell` subtitle truncated?" 
5. "How do I put two `UITextField`s side-by-side in a `UIStackView` via Storyboard?" 
6. "How do I use `UIActivityViewController` to share plain text?"
7. "What's the difference between `setData(from:)` and `updateData(_:)`?" 

In all cases, the AI response was a starting point. I then:
- Read the official Apple/Firebase documentation
- Tested the approach in the simulator
- Committed only verified, working code

**Chat Transcripts:**
- [ChatGPT Conversation](https://chatgpt.com/share/6a112ba4-d548-83e8-9c87-a2cb5188fe81)
- [Grok Conversation](https://grok.com/share/c2hhcmQtMi1jb3B5_17030643-42de-4c38-a4e7-d3d2b15c3ab1)

---

## Setup Instructions for Marker

1. **Open Project**
   ```
   Open SalesInterior.xcodeproj in Xcode
   ```

2. **Resolve Dependencies**
   - Swift Package Manager will automatically fetch [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk).
   - Wait for dependency resolution to complete

3. **Verify Configuration Files**
   - Confirm `GoogleService-Info.plist` is present in the SalesInterior target root
   - File is included in this submission per assignment requirements

4. **Select Target Device**
   - Choose **iPhone 17 Pro Simulator** (or any iPhone running iOS 15+)

5. **Build & Run**
   - Press ⌘R to build and launch
   - Use the `+` button to add houses, rooms, measurements, and photos

6. **Test Workflow**
   - Add House → Add Room → Add Measurements → View Quote → Share

---

## Known Limitations & Notes

- Photo Gallery picker only (Camera not available in Simulator)
- Images compressed to 800×800px @ JPEG quality 0.1–0.7 to stay under Firestore limits
- Real-time updates rely on active Firestore listeners; offline changes sync when connection resumes

