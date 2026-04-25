# Sales Interior – Android App

**Student Name:** Shaan Ul Islam
**Student ID:** 733837

---

## Overview

Sales Interior is a native Android application built for managing client house projects. It allows users to record room measurements (windows and floors) and generate cost estimates for interior work. The app stores and retrieves data in real time using Firebase Firestore.

---

## Device / Emulator

This app was developed and tested on a **Google Pixel 6A emulator** running Android.

The app is fixed to **portrait orientation** throughout.

---

## App Structure & Activities

The app follows a linear workflow where each screen leads naturally to the next:

**HouseListActivity** is the starting screen. It shows all saved client house projects and updates in real time from Firestore. From here, users can open an existing project or add a new one.

**AddHouseActivity** opens when the user wants to create a new project. It contains a form for entering client and property details. All fields are validated before saving, so incomplete entries are not accepted.

**HouseDetailActivity** displays the details of a selected house and lists all the rooms associated with it. Users can navigate into any room from this screen.

**RoomDetailActivity** is where measurements are entered. Users input window dimensions (width and height) and floor area. The fields only accept valid decimal numbers, and any invalid input triggers an error message.

**ProductListActivity and ProductDetailActivity** together form a catalog of available interior products, such as flooring materials and window types. Users can browse products and link them to specific measurements in a room.

**QuoteActivity** pulls together all the room data and calculates the total project cost. It also includes a Share button that lets the user export the quote through email or a messaging app.

---

## Architecture & Technical Details

- **Language:** Kotlin
- **Architecture:** Activities, Adapters, and Data Classes
- **Database:** Firebase Firestore with a hierarchical schema: Houses → Rooms → Measurements
- **UI:** ConstraintLayout for consistent layout across screen sizes
- **Data handling:** Firestore Transactions and `FieldValue.arrayUnion()` for safe array updates; `toDoubleOrNull()` and `trim()` for input validation

---

## References

### YouTube Tutorials

These videos helped me learn the core concepts used in this project:

- **RecyclerView in Android Studio (Kotlin)** – Coding With Mitch  
  https://www.youtube.com/watch?v=Jo6Mtq7zkkg  
  Used to understand how to set up RecyclerView and write Adapter classes for listing house and room data.

- **Firebase Firestore – Full Android Tutorial**  
  https://www.youtube.com/watch?v=KSG2METyPMs  
  Helped with understanding Firestore CRUD operations, real-time listeners, and sub-collection structure.

- **Firebase Firestore | Android Studio Setup and How to Add Data**  
  https://www.youtube.com/watch?v=A8M8MZb7CJc  
  Useful for the initial Firestore setup and understanding how data is written and read in Android.

---

### Stack Overflow

- **How do I get extra data from intent on Android?**  
  https://stackoverflow.com/q/4233873  
  Referenced when figuring out how to pass a Firestore document ID from `HouseListActivity` to `HouseDetailActivity` using `putExtra` and `getStringExtra`.

- **Sharing text content using Intent.ACTION_SEND**  
  https://stackoverflow.com/questions/9948373/android-share-plain-text-using-intent-to-all-messaging-apps

  Used when implementing the Share button in `QuoteActivity` to send the quote summary as plain text via email or messaging apps.

---

### Official Documentation

- **Firebase Firestore – Get Real-Time Updates (Android)**  
  https://firebase.google.com/docs/firestore/query-data/listen  
  Referenced for `addSnapshotListener` usage and understanding how to keep the house list updated in real time.

- **Firebase Firestore – Add Data (Kotlin)**  
  https://firebase.google.com/docs/firestore/manage-data/add-data  
  Used for understanding Firestore transactions and `FieldValue.arrayUnion()` when updating measurement arrays.

- **Android Developers – ConstraintLayout**  
  https://developer.android.com/develop/ui/views/layout/constraint-layout  
  Referenced for layout structure and positioning UI elements across different screen sizes.

- **Kotlin Standard Library – toDoubleOrNull()**  
  https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.text/to-double-or-null.html  
  Used when implementing decimal input validation in `RoomDetailActivity`.

---

## Use of Generative AI

Generative AI (ChatGPT) was used at certain points during this project, mostly when I was stuck on a specific error or unsure about the correct syntax for something. It was not used to design the app, plan the activity structure, or write full sections of code. The overall approach came from working through the tutorials and documentation listed above.

Below are examples of the kinds of questions I asked. This is not an exhaustive list, there were other small queries along the way, but these represent the nature of the help I received:

1. "How do I pass a Firestore Document ID from one Activity to another using Intents in Kotlin?"
2. "What is the correct way to validate that a decimal input field is not empty, zero, or negative in Android?"
3. "How do I format a Double as a price string with exactly two decimal places in Kotlin?"
4. "My RecyclerView is not updating when Firestore data changes, why could that be?"
5. "What is the difference between `set()` and `update()` in Firestore, and when should I use each one?"
6. "I am getting a NullPointerException when trying to read an intent extra in my second activity, what am I doing wrong?"
7. "How do I use `FieldValue.arrayUnion()` to add a value to an existing Firestore array without overwriting the whole array?"

In most cases, the AI helped me understand what was going wrong or pointed me toward the right function to use. I then went to the official documentation or tried it myself to confirm it worked in my specific situation. I would describe the role of AI in this project as similar to asking a peer a quick question, useful for unblocking, but not a substitute for understanding the material.