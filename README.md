# Taskflow — Flutter Provider State Management

A modern, classy, and executive **Task Management Application** built with Flutter and the **Provider package**. 

Designed with clean architecture principles, this project demonstrates reactive state management, complete separation of concerns, and zero reliance on `setState()` for application business logic.

---

## 📸 Key Highlights & Features

- **⚡ Reactive State Architecture**: Built using `ChangeNotifier`, `ChangeNotifierProvider`, `Consumer`, `context.watch()`, and `context.read()`.
- **📊 Smart Progress Tracker**: Live completion rate bar, percentage counter, and dynamic motivational status messages.
- **🏷️ Priority Management**: Categorize tasks into **High**, **Medium**, and **Low** priorities with custom badges.
- **🎯 Dynamic Filter Tabs**: Seamlessly switch between **All**, **Pending**, and **Completed** tasks with live count badges.
- **✨ Micro-Interactions**:
  - Circular animated check transitions.
  - Swipe-to-delete (`Dismissible`) with instant **Undo SnackBar** restoration.
  - Form validation with customized modal dialog.
  - Contextual empty states when no tasks match the selected filter.
- **🎨 Modern Design System**: Styled using Material 3, **Plus Jakarta Sans** typography, soft slate background palettes, and subtle ambient shadows.

---

## 🏛️ Architecture & Project Structure

The project strictly adheres to clean separation of concerns:

```text
lib/
│
├── main.dart                       # Entry point & ChangeNotifierProvider dependency injection
│
├── models/
│   └── task.dart                   # Pure data entities (Task & TaskPriority)
│
├── providers/
│   └── task_provider.dart          # Business logic, state manipulation & computed statistics
│
├── screens/
│   └── task_home_screen.dart       # Main presentation view (subscribes via context.watch)
│
└── widgets/
    ├── add_task_dialog.dart        # Task creation modal with priority selectors
    ├── task_card.dart              # Individual task card with checkbox & swipe-to-delete
    └── task_statistics.dart        # Metric cards & progress tracker (subscribes via Consumer)
```

### Layer Responsibilities

| Layer | Files | Responsibility |
| :--- | :--- | :--- |
| **Model** | `lib/models/task.dart` | Immutable data structure representing task data and priority definitions. Has zero Flutter UI dependencies. |
| **Provider** | `lib/providers/task_provider.dart` | Extends `ChangeNotifier`. Manages the list of tasks, computed statistics, filtering, and notifies listeners on change. |
| **Screens** | `lib/screens/task_home_screen.dart` | Orchestrates the layout and listens reactively to provider changes using `context.watch<TaskProvider>()`. |
| **Widgets** | `lib/widgets/*` | Focused, reusable presentation components utilizing `Consumer` for fine-grained rebuilds and `context.read()` for event callbacks. |

---

## 🧠 Provider State Management Breakdown

### 1. `ChangeNotifier`
Extends Flutter foundation's observable subject. It encapsulates private state (`_tasks`) and provides safe public mutations:
```dart
class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];
  
  void addTask(String title, String description, {TaskPriority priority = TaskPriority.medium}) {
    _tasks.insert(0, newTask);
    notifyListeners(); // Broadcasts updates to all listening widgets
  }
}
```

### 2. `ChangeNotifierProvider`
Mounted at the root in `main.dart`. It creates and injects a single shared instance of `TaskProvider` down the element tree:
```dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: const MyApp(),
    ),
  );
}
```

### 3. `context.watch()` vs `Consumer`
Used for **reactive subscriptions** where the widget must rebuild when state changes:
- **`context.watch<TaskProvider>()`** is used in `TaskHomeScreen` to reactively re-render the task list when items are added, toggled, or deleted.
- **`Consumer<TaskProvider>`** is used in `TaskStatistics` to limit rebuilds exclusively to the progress tracker and metric cards.

### 4. `context.read()`
Used in **action callbacks** (`onPressed`, `onChanged`, `onDismissed`) where we trigger a method without subscribing the calling widget to rebuilds:
```dart
// Checkbox toggle
context.read<TaskProvider>().toggleTask(task.id);

// Deleting a task
context.read<TaskProvider>().deleteTask(task.id);

// Creating a task
context.read<TaskProvider>().addTask(title, description, priority: priority);
```

### 5. Calculated Getters (No Redundant State)
Statistics are calculated dynamically on-the-fly:
```dart
int get totalTasks => _tasks.length;
int get completedTasks => _tasks.where((task) => task.isCompleted).length;
int get pendingTasks => _tasks.where((task) => !task.isCompleted).length;
double get completionRate => _tasks.isEmpty ? 0.0 : (completedTasks / totalTasks);
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version `^3.12.0` or higher)
- Dart SDK (version `^3.12.0` or higher)

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/taskflow.git
   cd taskflow
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify code quality**:
   ```bash
   flutter analyze
   flutter test
   ```

4. **Launch the application**:
   ```bash
   flutter run
   ```

---

## 🎓 Viva & Technical Defense Q&A

**Q1: Why is `setState()` not used for managing task state?**  
`setState()` is strictly scoped to the local `State` object of a single widget. Because tasks are created in a modal dialog, listed in a scroll view, and summarized in statistics cards, using `setState()` would require messy and brittle callback passing ("prop drilling"). `Provider` centralizes state in a single business layer accessible anywhere in the tree.

**Q2: What is the difference between `context.watch()` and `context.read()`?**  
- `context.watch<T>()` subscribes the widget to changes. When `notifyListeners()` is called, the widget's `build()` method executes again.  
- `context.read<T>()` retrieves the provider instance once without subscribing. It is ideal for event handlers (`onPressed`, `onChanged`) to avoid unnecessary rebuilds.

**Q3: What does `notifyListeners()` do behind the scenes?**  
It iterates over all registered listener callbacks (from widgets subscribed via `Consumer` or `context.watch`) and requests Flutter to mark those element subtrees as dirty, scheduling a new frame to repaint them with fresh data.

**Q4: How does `Consumer` optimize performance?**  
`Consumer` rebuilds only the subtree defined in its `builder` closure rather than rebuilding the parent widget, minimizing CPU and rendering overhead.

---

## 📄 License
This project is open-source and available under the [MIT License](LICENSE).
