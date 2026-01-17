## 4️⃣ priority order

### 🚀 Phase 1 (Launch)

1. ~~Reopen last screen~~
2. ~~Folder system (flat)~~
3. Widget: latest note
4. Export (Markdown + PDF)
5. AI auto layout (basic)

---

### 🚧 Phase 2

6. Widget checkbox toggle
7. Custom color themes
8. Table (simple)

---

### 🧠 Phase 3

9. Google Drive sync
10. Custom fonts
11. Advanced AI assistant



### 📝 Performance Improve
The frame drops you are experiencing are almost certainly caused by the **`BackdropFilter`** inside your `bottomNavigationBar`.

While `BackdropFilter` creates a beautiful frosted-glass effect, it is one of the most expensive operations in Flutter. When you click a button that triggers an animation (like a Dialog appearing or a Screen transition), the GPU has to re-calculate that blur for every single frame of the animation.

Here is how to fix the performance issues:

### 1. The "BackdropFilter" Trap

You wrapped your blur in a `RepaintBoundary`. Usually, this is good, but `BackdropFilter` is an exception. A `BackdropFilter` must look at what is **behind** it to calculate the blur.

* When you open a Dialog or navigate, the background changes or moves.
* The `RepaintBoundary` is forced to invalidate and repaint the blur 60 times per second.
* **The Fix:** Remove the blur during transitions or replace it with a solid/semi-transparent color.

**Optimization:** Use a simple semi-transparent color instead of `BackdropFilter` for the bottom bar. It looks nearly identical but uses 90% less GPU.

```dart
// Change this:
color: Colors.black.withValues(alpha: 0.2), 
// To a slightly more opaque color and remove the BackdropFilter
color: isDark ? const Color(0xEE1C1C1E) : const Color(0xEEFFFFFF), 

```

---

### 2. Move `ref.watch` into smaller Widgets

In your current code, `foldersAsync` and `allNotesAsync` are watched at the very top of the `build` method.

* If **anything** in your notes or folders changes, the **entire** screen (including the AppBar, the Search bar, and the Bottom Bar) rebuilds.
* When you click "Create Note," if your provider updates even slightly, the whole heavy UI tree is reconstructed.

**The Fix:** Use the `Consumer` widget to "localize" your rebuilds.

```dart
// Inside your SliverList, instead of using variables from the top:
delegate: SliverChildBuilderDelegate((context, index) {
  return Consumer(
    builder: (context, ref, child) {
      final folder = filteredFolders[index];
      // Only this small tile rebuilds if notes update
      final notes = ref.watch(notesListProvider).valueOrNull ?? [];
      final noteCount = notes.where((n) => n.folderId == folder.id).length;
      
      return _buildFolderTile(...);
    },
  );
}, childCount: filteredFolders.length),

```

---

### 3. Dialogs and Keyboard "Resizing"

When you click "New Folder," the keyboard slides up. By default, `Scaffold` tries to resize the entire body to make room for the keyboard.

* Resizing a `CustomScrollView` + `BackdropFilter` while an animation is happening is a recipe for frame drops.

**The Fix:** Disable resizing for this specific screen.

```dart
return Scaffold(
  resizeToAvoidBottomInset: false, // Prevents the UI from jumping when keyboard appears
  extendBody: true,
  // ... rest of your code

```

---

### 4. Improve the `RepaintBoundary` Placement

Currently, your `RepaintBoundary` is inside the `bottomNavigationBar`. If you insist on keeping the blur, move the `RepaintBoundary` to wrap the **content** that is scrolling behind the bar, not the bar itself. This tells Flutter that the list and the bottom bar are on different layers.

---

### Summary of Performance Fixes (Do these in order):

1. **Remove `BackdropFilter`:** Test if the lag goes away. If it does, consider if the blur is worth the performance hit.
2. **Add `const`:** Ensure your `HomeScreen()` and `NoteEditorScreen()` constructors are called with `const` where possible.
3. **Optimize the List:** Your `_buildFolderTile` is being built inside a `SliverList`. Ensure the logic inside `_buildFolderTile` is as light as possible. Move the `noteCount` calculation into the Provider (using a `Family` provider) so it doesn't run during every scroll frame.

### Recommended Change for the Bottom Bar:

```dart
bottomNavigationBar: Container( // Removed RepaintBoundary, ClipRect, and Blur
  padding: EdgeInsets.only(
    bottom: MediaQuery.of(context).padding.bottom,
    top: 10, left: 20, right: 20,
  ),
  decoration: BoxDecoration(
    // Use an opaque color to skip GPU blending
    color: theme.navigationBarTheme.backgroundColor ?? 
           (isDark ? Colors.black : Colors.white),
    border: Border(top: BorderSide(color: dividerColor, width: 0.5)),
  ),
  child: Row(...)
),

```

**Would you like me to show you how to create a "Filtered Notes Provider" so you don't have to run `.where()` logic inside your UI build method?**