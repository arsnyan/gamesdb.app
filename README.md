# Games DB: An iOS Client for the IGDB API

| Демонстрация русской локализации | Demo |
| :---------: | :---------: |
![App GIF](https://github.com/arsnyan/gamesdb.app/blob/main/Demonstation.gif) | ![App GIF in English](https://github.com/arsnyan/gamesdb.app/blob/main/Demonstration_ENG.gif) |

Games DB is an iOS application designed to explore and display comprehensive game data fetched from the public [IGDB API](https://api.igdb.com/). Built primarily for educational purposes, it serves as a practical demonstration of modern iOS development patterns and reactive programming principles.

## 🌟 Key Features

*   **Browse Game Data:** Navigate through a vast collection of game titles with detailed information.
*   **Detailed Game Profiles:** View information for each game, including descriptions, release dates, genres, platforms, and cover art.
*   **Responsive UI:** Adapts to various iOS device sizes and orientations, uses UICollectionViewDiffableDataSource.

## 🧑‍💻 Technologies & Stack

This project was developed with a focus on clean architecture and reactive programming, utilizing the following key technologies:

*   **MVVM Architecture:** Employed for a clear separation of concerns, improving testability (conceptually, not implemented) and maintainability of the codebase
*   **RxSwift & RxCocoa:** Leveraged for handling asynchronous operations and binding UI elements to reactive sequences for a responsive user experience
*   **RxDataSources:** Integrated to simplify the management and binding of collection view data to reactive sources
*   **SnapKit:** Used for programmatic, constraint-based layout, avoiding verbose NSLayoutConstraints approach
*   **Minimum iOS Version:** Targeting iOS 15+
*   **External API Integration:** Interacts with the IGDB API for fetching game data

## 🎓 What I Learned & Implemented

This project was a significant learning experience, allowing me to dive deep into some advanced iOS development concepts:

*   **Reactive Programming with RxSwift & RxCocoa:**
    *   Gained a solid understanding of `Observables`, `Subjects` (`PublishRelay`, `BehaviorRelay`), and key `Operators` (`map`, `filter`, `bind`) for transforming and managing data streams
    *   Proficiently used `RxCocoa` to bind UI elements (e.g., `UICollectionView.rx.items`) to reactive sequences, simplifying event handling and state management
*   **Building Dynamic UIs with Compositional Layouts:**
    *   Implemented `UICollectionViewCompositionalLayout` to create flexible and adaptive UI structure on the main screen with different sections.
*   **Fast Layout with SnapKit:**
    *   Developed UI layouts entirely programmatically using `SnapKit`
*   **MVVM Architecture in Practice:**
    *   Solidified understanding of the MVVM pattern, specifically how to integrate it with RxSwift to create a clean, modular, and maintainable codebase where ViewModels expose `Observables` that Views subscribe to
*   **API Integration & Query Building:**
    *   Successfully integrated with a third-party REST API (IGDB), handling asynchronous network requests, parsing complex JSON responses into custom data models
    *   Gained experience in constructing complex string-based queries tailored to the IGDB API's specific filtering and sorting requirements
*   **Accessibility & Dynamic Type Consideration:**
    *   Explored and applied principles of iOS accessibility, particularly by supporting `Dynamic Type` for scalable text, allowing users to customize font sizes for better readability
    *   Utilized the `Accessibility Inspector` during development to identify and address potential accessibility barriers, aiming for a more inclusive user experience
	*	Learned about localization using String catalogs

## 👷 How to Build & Run

To get a local copy of this project up and running, follow these steps:

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/arsnyan/gamesdb.app.git
    cd GamesDB
    ```
2.  **Obtain IGDB API Credentials:**
    *   Visit [igdb.com](https://www.igdb.com/api) to sign up for an account and register your application to obtain a **Client ID** and **Client Secret**.
    *   Alternatively, you can request temporary credentials from me (see "Contact" section).
3.  **Create `Secrets.plist`:**
    *   Within the main project group in Xcode (or inside `Supporting Files` group), ensuring it's not committed to Git), create a new `Property List` file named `Secrets.plist`.
    *   Add two new entries (rows) to this file:
        *   **Key:** `Client ID`, **Type:** `String`, **Value:** `YOUR_IGDB_CLIENT_ID`
        *   **Key:** `Client Secret`, **Type:** `String`, **Value:** `YOUR_IGDB_CLIENT_SECRET`
    *   **Important:** Make sure `Secrets.plist` is added to your `.gitignore` file to prevent sensitive API keys from being committed to public repositories. Add the following line to your `.gitignore`:
        ```
        <direction_to_secrets.plist>/Secrets.plist
        ```
4.  **Open and Run:**
    *   Open `GamesDB.xcworkspace` (not `.xcodeproj`) in Xcode (due to Swift version in the project, you may need Xcode 26 beta to open the project).
    *   Select your target device or simulator.
    *   Build and run the application (`⌘R`).

Note that the project may show all strings in caps on run. This is intented behavior to find unlocalized strings. To turn it off: go to `Product` -> `Scheme` -> `Edit Scheme` -> `Run` (in sidebar) -> `Options` -> untick `Show non-localized strings`.

## 📸 Screenshots

*(Replace this section with actual screenshots of your app. Aim for 2-4 good quality images that showcase key features like the main listing, a detailed view, and perhaps the search screen.)*

| Home Screen | Detail View |
| :---------: | :---------: |
| ![Home Screen](https://github.com/arsnyan/gamesdb.app/blob/main/MainScreen.png) | ![Detail View](https://github.com/arsnyan/gamesdb.app/blob/main/Details.png) |

---

## 👨‍💻 Author

*   **Arsen** - [Link to my LinkedIn Profile](https://www.linkedin.com/in/arsnyan/) | [E-mail](mailto:arsnyan.dev@gmail.com) | [Telegram](https://www.t.me/arsnyan)

---

## 📄 License

This project is not licensed. Feel free to do anything you want with it. Btw yes I used AI to make this gorgeous looking readme.

---
