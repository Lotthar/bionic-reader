# Bionic Reader Flutter App

Bionic Reader is a modern Flutter application designed to enhance the reading experience by converting PDF documents into a "Bionic Reading" format. This method emphasizes the first few letters of each word, allowing the reader's brain to complete the rest and potentially increase reading speed.

The app is built with a focus on clean architecture, background processing, and a high-quality, reactive user experience.

---

## Features

- **PDF to Bionic Reading:** Converts text from PDF files into a bionic reading format with bolded initial letters.
- **Persistent Book Library:** Add PDF files to a persistent library that stores your books on the device. All book metadata is saved locally using an SQLite database.
- **Background Processing:** All heavy-duty tasks—such as PDF parsing, text extraction, pagination, and cover image generation—are performed in the background using isolates, ensuring the UI remains smooth and responsive at all times.
- **Automatic Cover Extraction:** The first page of each PDF is automatically rendered and saved as a cover image, which is displayed in the library.
- **Reading Progress:** The app remembers the last page you were reading for each book, allowing you to jump right back in where you left off.
- **Reactive UI:** The library screen automatically updates in real-time to reflect the status of book conversions (Queued, Converting, Completed, Failed).
- **Customizable Theme:** The app features a fully customizable theme with support for light/dark mode and a user-selectable seed color for the color scheme. All theme settings are persisted across app launches.
- **Dynamic Layout:** The pagination logic adapts to the screen size of the device, providing a better reading experience on both phones and tablets.

---

## Architecture Overview

The application is built following clean architecture principles, separating the project into three distinct layers:

- **Data Layer:** Manages data sources.
  - **`services/database`**: A generic `DatabaseProvider` manages the SQLite connection, while a `BookDatabaseService` handles all CRUD operations for the book library.
  - **`services/book_cache_service.dart`**: Caches the paginated text content of books to the file system.
  - **`services/cover_image_service.dart`**: Handles saving and loading cover images from the file system.
  - **`models`**: Contains the data models for the application (e.g., `Book`, `ConversionStatus`).

- **Business Logic Layer:** Contains the state management and core business rules.
  - **`bloc`**: Uses `flutter_bloc` (specifically `Cubit`) to manage the state of the UI, reacting to changes from the data layer.
  - **`services/background_conversion_service.dart`**: A critical service that manages a queue and spawns isolates to handle all background processing for new books.
  - **`notifiers/theme_notifier.dart`**: Uses the `ChangeNotifier` and `Provider` packages to manage the app's theme state.

- **UI Layer:** Responsible for presenting the data to the user.
  - **`screens`**: Contains the main screens of the application (`LibraryScreen`, `ReadingScreen`, `SettingsScreen`).
  - **`widgets`**: Contains reusable widgets used across multiple screens.
  - **`theme`**: Defines the global theme, including custom styles using `ThemeData` extensions for a consistent look and feel.

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- An editor like VS Code or Android Studio

### Installation

1.  **Clone the repository:**
    ```sh
    git clone <your-repository-url>
    cd bionic_reader
    ```

2.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

3.  **Run the application:**
    ```sh
    flutter run
    ```

---

## Project Structure

```
lib/
├── bloc/               # BLoC/Cubit state management
├── models/             # Data models (e.g., Book)
├── notifiers/          # ChangeNotifier for theme state
├── screens/            # UI screens (Library, Reading, Settings)
├── services/           # Business logic and data services
│   ├── database/       # Database provider and schema
│   └── ...
├── theme/              # Global theme and custom style extensions
├── utils/              # Utility classes and helpers
└── widgets/            # Reusable UI components
```

---

*This README was generated based on the current state of the project.*
