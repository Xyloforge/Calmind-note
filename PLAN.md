# Calmind - Product Specification

> A fast, calm note + schedule app that feels like Apple Notes, but thinks for you.

---

## Executive Summary

**Product Name:** Calmind (working title)

**Core Philosophy:** Speed over features. Calm over complexity. Thinking happens automatically.

**Target Launch:** Mobile-first (iOS + Android), with potential desktop expansion.

**Differentiator:** Copy-paste that never breaks + notes and schedule as one unified system.

---

## 1. Problem Statement

### What's Wrong with Current Solutions

| App | Problem |
|-----|---------|
| Notion | Too complex, slow, overwhelming for simple notes |
| Apple Notes | No scheduling, limited organization, Apple-only |
| Google Keep | Messy at scale, weak copy-paste formatting |
| Todoist | Task-focused, not note-focused |
| Calendar apps | No connection to notes/context |

### The Gap We Fill

Users want to:
- Write quick notes without thinking about structure
- Schedule events with context (linked notes)
- Copy content to chat apps without formatting disasters
- Open the app and continue exactly where they left off

No app does all four well.

---

## 2. Target User Personas

### Primary: "The Busy Student" - Sarah, 22

- Takes lecture notes on phone
- Copies bullet points to WhatsApp study groups
- Needs reminders for assignments
- Hates learning new apps
- **Pain point:** "Why does my formatting break when I paste?"

### Secondary: "The Light Professional" - David, 35

- Uses notes for meeting agendas
- Wants quick schedule overview
- Switches between phone and tablet
- **Pain point:** "I just want to write, not configure databases"

### Anti-persona (NOT our user)

- Power users who want Notion-level customization
- Users who need collaborative editing
- Users who want detailed project management

---

## 3. Core Features (MVP - Phase 1)

### 3.1 Note Editor

#### User Experience
```
[Open app] → [Last note appears] → [Cursor ready] → [Start typing]
```

Total time from tap to typing: < 1 second

---

## 3.1.1 UI Layout (Apple Notes Style)

### Complete Screen Layout

```
┌─────────────────────────────────────────────────────────────┐
│ ◀ Notes              TOP NAVIGATION BAR          ↶  ↷  ⋯  │
│ (Back)                                     (Undo)(Redo)(More)│
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Meeting Notes                                             │
│   ─────────────────                                         │
│                                                             │
│   Discussion Topics                                         │
│   • Budget review                                           │
│   • Timeline planning                                       │
│                                                             │
│   Action Items                                              │
│   ☐ Send follow-up email                                    │
│   ☐ Book conference room                                    │
│   ☑ Prepare slides                                          │
│                                                             │
│                       NOTE CONTENT AREA                     │
│                     (Scrollable canvas)                     │
│                                                             │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│  Aa    ☑     📎    🎤    ✏️       FORMATTING TOOLBAR        │
│(Format)(Check)(Attach)(Audio)(Draw)  (Above keyboard)       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                    SYSTEM KEYBOARD                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

### TOP NAVIGATION BAR (Always Visible)

The top bar contains navigation and undo/redo controls. This is **always visible** even when scrolling.

```
┌─────────────────────────────────────────────────────────────┐
│  ◀ Notes                                    ↶    ↷    ⋯    │
│  [Back Button]                           [Undo][Redo][More] │
└─────────────────────────────────────────────────────────────┘
```

| Position | Element | Icon | Action |
|----------|---------|------|--------|
| Left | Back button | `◀` or `< Notes` | Return to note list |
| Right-1 | **Undo** | `↶` (curved arrow left) | Undo last action |
| Right-2 | **Redo** | `↷` (curved arrow right) | Redo undone action |
| Right-3 | More menu | `⋯` (three dots) | Share, Pin, Lock, Delete, etc. |

#### Undo/Redo Implementation Notes

```typescript
interface UndoRedoState {
  undoStack: NoteState[];  // History of states
  redoStack: NoteState[];  // Undone states
  maxHistorySize: 50;      // Limit memory usage
}

// Undo button: disabled when undoStack is empty
// Redo button: disabled when redoStack is empty
// Visual: Grayed out (opacity 0.3) when disabled
```

**Critical UX Rules:**
- Undo/Redo buttons are **always in the top navigation bar**
- They should be visible without scrolling or opening menus
- Visual feedback: Icons turn gray when no action available
- Support keyboard shortcuts: `Cmd+Z` (undo), `Cmd+Shift+Z` (redo)
- Support gesture: Three-finger swipe left (undo), right (redo)

---

### FORMATTING TOOLBAR (Above Keyboard)

When editing, a toolbar appears directly above the keyboard. This mirrors Apple Notes iOS 18 layout.

```
┌─────────────────────────────────────────────────────────────┐
│   Aa      ☑        📎       🎤       ✏️                     │
│ [Format][Checklist][Attach][Audio][Markup]                  │
└─────────────────────────────────────────────────────────────┘
```

| # | Icon | Name | Function |
|---|------|------|----------|
| 1 | `Aa` | Format | Opens text formatting panel |
| 2 | `☑` | Checklist | Insert checkbox at cursor |
| 3 | `📎` | Attach | Add photos, files, scan document |
| 4 | `🎤` | Audio | Record voice memo (Phase 2) |
| 5 | `✏️` | Markup/Draw | Open drawing tools (Phase 2) |

---

### FORMAT PANEL (Aa Button Expanded)

When user taps `Aa`, the keyboard is replaced by a formatting panel:

```
┌─────────────────────────────────────────────────────────────┐
│                    TEXT STYLES (Row 1)                      │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌──────────┐  │
│  │ Title  │ │Heading │ │Subhead │ │ Body   │ │Monospace │  │
│  └────────┘ └────────┘ └────────┘ └────────┘ └──────────┘  │
├─────────────────────────────────────────────────────────────┤
│                TEXT FORMATTING (Row 2)                      │
│     ┌───┐    ┌───┐    ┌───┐    ┌───┐    ┌────────┐        │
│     │ B │    │ I │    │ U │    │ S │    │  🎨   │         │
│     └───┘    └───┘    └───┘    └───┘    │(color)│         │
│    (Bold)  (Italic)(Under) (Strike)     └────────┘        │
├─────────────────────────────────────────────────────────────┤
│                    LISTS (Row 3)                            │
│   ┌──────┐   ┌──────┐   ┌──────┐       ┌───┐   ┌───┐      │
│   │  -   │   │ 1.   │   │  •   │       │ ← │   │ → │      │
│   │Dash  │   │Number│   │Bullet│       │Out│   │In │      │
│   └──────┘   └──────┘   └──────┘       └───┘   └───┘      │
│   (Dashed)  (Numbered) (Bulleted)    (Outdent)(Indent)    │
└─────────────────────────────────────────────────────────────┘
```

#### Text Styles (Row 1)

| Style | Font Size | Weight | Use Case |
|-------|-----------|--------|----------|
| Title | 28pt | Bold | Note title, first line |
| Heading | 22pt | Bold | Section headers |
| Subheading | 18pt | Semibold | Subsection headers |
| Body | 17pt | Regular | Normal text |
| Monospace | 15pt | Regular (SF Mono) | Code snippets |

#### Text Formatting (Row 2)

| Button | Shortcut | Effect |
|--------|----------|--------|
| **B** | Cmd+B | Bold selected text |
| *I* | Cmd+I | Italicize selected text |
| <u>U</u> | Cmd+U | Underline selected text |
| ~~S~~ | - | Strikethrough selected text |
| 🎨 | - | Open color picker for text/highlight |

#### Lists (Row 3)

| Button | Markdown Shortcut | Result |
|--------|-------------------|--------|
| Dash `-` | Type `- ` | Dashed list item |
| Number `1.` | Type `1. ` | Numbered list |
| Bullet `•` | Type `* ` | Bulleted list |
| Outdent `←` | Shift+Tab | Decrease indent |
| Indent `→` | Tab | Increase indent |

---

### MORE MENU (⋯ Three Dots)

When user taps the three-dot menu in top navigation:

```
┌─────────────────────────────────┐
│ Pin Note              📌        │
├─────────────────────────────────┤
│ Lock Note             🔒        │
├─────────────────────────────────┤
│ Find in Note          🔍        │
├─────────────────────────────────┤
│ Move Note             📁        │
├─────────────────────────────────┤
│ Share...              ↗️        │
├─────────────────────────────────┤
│ Add to Schedule       📅        │  ← OUR CUSTOM FEATURE
├─────────────────────────────────┤
│ Lines & Grids         ⊞         │
├─────────────────────────────────┤
│ Delete                🗑️        │
└─────────────────────────────────┘
```

---

### COLOR PICKER (iOS 18 Style)

When user taps the color button in format panel:

```
┌─────────────────────────────────────────────────────────────┐
│ Text Color                      Highlight Color             │
├─────────────────────────────────────────────────────────────┤
│  ⚫  🔴  🟠  🟡  🟢  🔵  🟣                                 │
│ (Black)(Red)(Orange)(Yellow)(Green)(Blue)(Purple)          │
└─────────────────────────────────────────────────────────────┘
```

**MVP Colors (5 highlight colors like Apple Notes):**
- Yellow (default)
- Green
- Blue
- Pink
- Purple

---

### VISUAL SPECIFICATIONS

#### Colors (Light Mode)
```css
--background: #FFFFFF;
--text-primary: #000000;
--text-secondary: #8E8E93;
--separator: #C6C6C8;
--accent: #007AFF;        /* iOS blue */
--toolbar-bg: #F2F2F7;
--button-disabled: rgba(0, 0, 0, 0.3);
```

#### Colors (Dark Mode)
```css
--background: #000000;
--text-primary: #FFFFFF;
--text-secondary: #8E8E93;
--separator: #38383A;
--accent: #0A84FF;        /* iOS blue (dark) */
--toolbar-bg: #1C1C1E;
--button-disabled: rgba(255, 255, 255, 0.3);
```

#### Typography (iOS System Fonts)
```css
/* iOS */
font-family: -apple-system, SF Pro Text, SF Pro Display;

/* Android */
font-family: Roboto, system-ui;

/* Font sizes */
--title-size: 28px;
--heading-size: 22px;
--subheading-size: 18px;
--body-size: 17px;
--caption-size: 13px;
```

#### Spacing
```css
--content-padding: 16px;
--line-height: 1.5;
--paragraph-spacing: 12px;
--toolbar-height: 44px;
--nav-bar-height: 44px;
```

---

### ICON SPECIFICATIONS

Use SF Symbols (iOS) or Material Icons (Android) for consistency:

| Function | SF Symbol | Material Icon | Unicode Fallback |
|----------|-----------|---------------|------------------|
| Back | `chevron.left` | `arrow_back` | `◀` |
| Undo | `arrow.uturn.backward` | `undo` | `↶` |
| Redo | `arrow.uturn.forward` | `redo` | `↷` |
| More | `ellipsis` | `more_horiz` | `⋯` |
| Checklist | `checklist` | `checklist` | `☑` |
| Attach | `paperclip` | `attach_file` | `📎` |
| Format | - | - | `Aa` (text) |
| Bold | `bold` | `format_bold` | `B` |
| Italic | `italic` | `format_italic` | `I` |

---

#### Supported Elements

| Element | User Action | Internal Storage |
|---------|-------------|------------------|
| Title | First line, large text | `{ type: "title", content: "..." }` |
| Paragraph | Normal typing | `{ type: "paragraph", content: "..." }` |
| Bullet list | Type "- " or tap button | `{ type: "bullet", items: [...] }` |
| Numbered list | Type "1. " or tap button | `{ type: "numbered", items: [...] }` |
| Checkbox | Type "[] " or tap button | `{ type: "checkbox", checked: false, content: "..." }` |
| Heading | Tap Aa → Heading | `{ type: "heading", level: 2, content: "..." }` |
| Subheading | Tap Aa → Subheading | `{ type: "subheading", content: "..." }` |

#### What We DON'T Support (MVP)

- Tables (Phase 2)
- Images (Phase 2)
- Audio recording (Phase 2)
- Drawing/Markup (Phase 2)
- Code blocks
- Embeds
- Databases
- Multi-column layouts

#### Visual Design Principles

```
┌─────────────────────────────────┐
│ ◀ Notes              ↶  ↷  ⋯  │  ← Top nav with undo/redo
├─────────────────────────────────┤
│                                 │
│  Meeting Notes                  │  ← Large, bold title (28pt)
│                                 │
│  Discussion Topics              │  ← Heading (22pt)
│  • Discuss budget               │  ← Generous line height
│  • Review timeline              │
│                                 │  ← Ample white space
│  Action Items                   │  ← Heading (22pt)
│  ☐ Send follow-up email         │  ← Clear checkbox
│  ☑ Book meeting room            │
│                                 │
├─────────────────────────────────┤
│  Aa   ☑   📎   🎤   ✏️         │  ← Format toolbar
└─────────────────────────────────┘
```

**Design Rules:**
- Font: System default (SF Pro / Roboto)
- Background: Pure white (#FFFFFF) or soft dark (#000000)
- Text: High contrast (#000000 / #FFFFFF)
- No colored backgrounds on notes
- No card borders or shadows
- Toolbar icons: 24x24pt touch targets (minimum 44x44pt hit area)

---

## 3.1.2 Component Implementation (Flutter)

This section provides exact component specifications for AI-assisted development.

### TopNavigationBar Component

```dart
class TopNavigationBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onMore;
  final bool canUndo;
  final bool canRedo;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button (left)
          IconButton(
            icon: Icon(CupertinoIcons.back),
            onPressed: onBack,
          ),
          Text(title, style: TextStyle(color: Colors.blue)),
          
          Spacer(),
          
          // Undo button (right)
          IconButton(
            icon: Icon(CupertinoIcons.arrow_turn_up_left),
            onPressed: canUndo ? onUndo : null,
            color: canUndo ? null : Colors.grey.withOpacity(0.3),
          ),
          
          // Redo button (right)
          IconButton(
            icon: Icon(CupertinoIcons.arrow_turn_up_right),
            onPressed: canRedo ? onRedo : null,
            color: canRedo ? null : Colors.grey.withOpacity(0.3),
          ),
          
          // More menu (right)
          IconButton(
            icon: Icon(CupertinoIcons.ellipsis),
            onPressed: onMore,
          ),
        ],
      ),
    );
  }
}
```

### FormattingToolbar Component

```dart
class FormattingToolbar extends StatelessWidget {
  final VoidCallback onFormatTap;      // Aa button
  final VoidCallback onChecklistTap;   // Checklist button
  final VoidCallback onAttachTap;      // Attach button
  final VoidCallback? onAudioTap;      // Audio (optional, Phase 2)
  final VoidCallback? onDrawTap;       // Draw (optional, Phase 2)

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: Color(0xFFF2F2F7), // iOS toolbar gray
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Format button (Aa)
          _ToolbarButton(
            label: 'Aa',
            isText: true,
            onTap: onFormatTap,
          ),
          
          // Checklist button
          _ToolbarButton(
            icon: CupertinoIcons.checkmark_square,
            onTap: onChecklistTap,
          ),
          
          // Attach button
          _ToolbarButton(
            icon: CupertinoIcons.paperclip,
            onTap: onAttachTap,
          ),
          
          // Audio button (disabled in MVP)
          _ToolbarButton(
            icon: CupertinoIcons.mic,
            onTap: onAudioTap,
            enabled: onAudioTap != null,
          ),
          
          // Draw button (disabled in MVP)
          _ToolbarButton(
            icon: CupertinoIcons.pencil_outline,
            onTap: onDrawTap,
            enabled: onDrawTap != null,
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final bool isText;
  final VoidCallback? onTap;
  final bool enabled;

  const _ToolbarButton({
    this.icon,
    this.label,
    this.isText = false,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        child: isText
            ? Text(
                label ?? '',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: enabled ? Colors.black : Colors.grey,
                ),
              )
            : Icon(
                icon,
                size: 24,
                color: enabled ? Colors.black : Colors.grey.withOpacity(0.4),
              ),
      ),
    );
  }
}
```

### FormatPanel Component (Aa Menu Expanded)

```dart
class FormatPanel extends StatelessWidget {
  final TextStyle? currentStyle;
  final VoidCallback onTitle;
  final VoidCallback onHeading;
  final VoidCallback onSubheading;
  final VoidCallback onBody;
  final VoidCallback onMonospace;
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onUnderline;
  final VoidCallback onStrikethrough;
  final VoidCallback onDashedList;
  final VoidCallback onNumberedList;
  final VoidCallback onBulletList;
  final VoidCallback onIndent;
  final VoidCallback onOutdent;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF2F2F7),
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Text Styles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StyleButton(label: 'Title', onTap: onTitle, fontSize: 20),
              _StyleButton(label: 'Heading', onTap: onHeading, fontSize: 17),
              _StyleButton(label: 'Subhead', onTap: onSubheading, fontSize: 15),
              _StyleButton(label: 'Body', onTap: onBody, fontSize: 14),
              _StyleButton(label: 'Mono', onTap: onMonospace, fontSize: 13, isMono: true),
            ],
          ),
          
          SizedBox(height: 12),
          Divider(height: 1),
          SizedBox(height: 12),
          
          // Row 2: Text Formatting
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FormatButton(label: 'B', onTap: onBold, isBold: true),
              _FormatButton(label: 'I', onTap: onItalic, isItalic: true),
              _FormatButton(label: 'U', onTap: onUnderline, isUnderline: true),
              _FormatButton(label: 'S', onTap: onStrikethrough, isStrike: true),
            ],
          ),
          
          SizedBox(height: 12),
          Divider(height: 1),
          SizedBox(height: 12),
          
          // Row 3: Lists
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ListButton(icon: CupertinoIcons.minus, onTap: onDashedList),
              _ListButton(label: '1.', onTap: onNumberedList),
              _ListButton(icon: CupertinoIcons.circle_fill, onTap: onBulletList, iconSize: 8),
              SizedBox(width: 20),
              _ListButton(icon: CupertinoIcons.arrow_left_to_line, onTap: onOutdent),
              _ListButton(icon: CupertinoIcons.arrow_right_to_line, onTap: onIndent),
            ],
          ),
        ],
      ),
    );
  }
}
```

### UndoRedoManager Class

```dart
class UndoRedoManager<T> {
  final List<T> _undoStack = [];
  final List<T> _redoStack = [];
  final int maxSize;
  
  UndoRedoManager({this.maxSize = 50});
  
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  
  void pushState(T state) {
    _undoStack.add(state);
    _redoStack.clear(); // Clear redo stack on new action
    
    // Limit stack size
    if (_undoStack.length > maxSize) {
      _undoStack.removeAt(0);
    }
  }
  
  T? undo(T currentState) {
    if (!canUndo) return null;
    
    _redoStack.add(currentState);
    return _undoStack.removeLast();
  }
  
  T? redo(T currentState) {
    if (!canRedo) return null;
    
    _undoStack.add(currentState);
    return _redoStack.removeLast();
  }
  
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }
}
```

---

### 3.2 Copy-Paste System (Killer Feature)

#### The Problem We Solve

When users copy from most note apps and paste to:
- Telegram → Bullets become weird characters
- WhatsApp → Line breaks disappear
- Email → Formatting is inconsistent

#### Our Solution: Multi-Format Export

When user copies, we generate THREE formats simultaneously:

```
┌─────────────────────────────────────────────────────┐
│ User taps "Copy"                                    │
│         │                                           │
│         ▼                                           │
│ ┌─────────────────────────────────────────────────┐ │
│ │ Clipboard contains:                             │ │
│ │                                                 │ │
│ │ 1. HTML (rich apps: Email, Docs)               │ │
│ │    <ul><li>Item one</li></ul>                  │ │
│ │                                                 │ │
│ │ 2. Plain text (chat apps)                      │ │
│ │    • Item one                                   │ │
│ │    ☐ Unchecked task                            │ │
│ │    ☑ Checked task                              │ │
│ │                                                 │ │
│ │ 3. Markdown (dev tools)                        │ │
│ │    - Item one                                   │ │
│ └─────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

#### Conversion Rules

| Internal Type | Plain Text | HTML |
|---------------|------------|------|
| Bullet | `• Item` | `<li>Item</li>` |
| Numbered | `1. Item` | `<ol><li>Item</li></ol>` |
| Checkbox (unchecked) | `☐ Item` | `☐ Item` |
| Checkbox (checked) | `☑ Item` | `☑ Item` |
| Heading | `## Heading` (with newlines) | `<h2>Heading</h2>` |

#### Technical Implementation

```typescript
interface ClipboardPayload {
  html: string;
  plainText: string;
  markdown: string;
  internalJson: NoteBlock[]; // For paste within app
}

function copyToClipboard(blocks: NoteBlock[]): void {
  const payload: ClipboardPayload = {
    html: blocksToHtml(blocks),
    plainText: blocksToPlainText(blocks),
    markdown: blocksToMarkdown(blocks),
    internalJson: blocks
  };
  
  // Platform-specific clipboard API
  Clipboard.setData(payload);
}
```

---

### 3.3 State Persistence & Quick Access

#### App Launch Behavior

```
┌─────────────────────────────────────────────────────┐
│ User opens app                                      │
│         │                                           │
│         ▼                                           │
│ ┌─────────────────────────────────────────────────┐ │
│ │ Check: lastOpenedNote exists?                   │ │
│ │         │                                       │ │
│ │    YES  │  NO                                   │ │
│ │    ▼    ▼                                       │ │
│ │ [Open last note]  [Show note list]             │ │
│ │ [Restore cursor]  [Focus search]               │ │
│ │ [Restore scroll]                               │ │
│ └─────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

#### State We Persist

```typescript
interface AppState {
  lastOpenedNoteId: string | null;
  cursorPosition: number;
  scrollPosition: number;
  lastOpenedFolder: string;
  editorState: 'editing' | 'viewing';
}
```

#### No Splash Screen Policy

- Cold start → Direct to content
- Loading indicator only if > 200ms delay
- Skeleton UI for note content while loading

---

### 3.4 Folder & Search

#### Folder Structure

Simple two-level hierarchy:

```
📁 Folders
├── 📁 Work
│   ├── 📝 Meeting notes
│   └── 📝 Project ideas
├── 📁 Personal
│   └── 📝 Shopping list
└── 📝 Unfiled notes (root level)
```

- No nested folders (MVP)
- No tags (MVP)
- Drag-drop to organize

#### Search Implementation

```typescript
interface SearchConfig {
  searchFields: ['title', 'content'];
  minQueryLength: 2;
  debounceMs: 150;
  maxResults: 50;
  highlightMatches: true;
}
```

Search is:
- Instant (< 100ms for 1000 notes)
- Local-first (no network needed)
- Searches title AND content
- Shows match preview in results

---

### 3.5 Schedule System (Lightweight)

#### Event Model

```typescript
interface ScheduleEvent {
  id: string;
  title: string;
  date: string; // ISO date: "2025-01-15"
  time?: string; // Optional: "14:30"
  duration?: number; // Minutes, optional
  linkedNoteId?: string; // Connection to notes
  reminder?: {
    enabled: boolean;
    minutesBefore: number; // 0, 5, 15, 30, 60, 1440
  };
}
```

#### Calendar Views

**Month View:**
```
┌─────────────────────────────────────┐
│        January 2025                 │
├───┬───┬───┬───┬───┬───┬───┤
│ S │ M │ T │ W │ T │ F │ S │
├───┼───┼───┼───┼───┼───┼───┤
│   │   │   │ 1 │ 2 │ 3 │ 4 │
│ 5 │ 6 │ 7 │ 8•│ 9 │10 │11 │  ← Dot = has events
│12 │13 │14 │15 │16 │17 │18 │
└───┴───┴───┴───┴───┴───┴───┘
```

**Day View:**
```
┌─────────────────────────────────────┐
│ Wednesday, Jan 8                    │
├─────────────────────────────────────┤
│ 9:00 AM   Team standup              │
│           📝 Meeting notes →        │  ← Linked note
│                                     │
│ 2:00 PM   Client call               │
│           No linked note            │
└─────────────────────────────────────┘
```

#### Note ↔ Schedule Integration

- From note: "Add to schedule" button creates event linked to note
- From schedule: Tap note icon opens linked note
- Bi-directional: Changes sync both ways

---

### 3.6 Widgets

#### Notes Widget (Home Screen)

**Small (2x2):**
```
┌─────────────────┐
│ Shopping List   │
│ • Milk          │
│ • Eggs          │
│ [+ New]         │
└─────────────────┘
```

**Medium (4x2):**
```
┌─────────────────────────────────────┐
│ 📝 Shopping List                    │
│ ☐ Milk                              │
│ ☐ Eggs              [Open] [+ New]  │
│ ☑ Bread                             │
└─────────────────────────────────────┘
```

Features:
- Shows pinned note OR last edited note
- Tap checkbox → Toggle without opening app
- Tap note → Opens directly to that note

#### Schedule Widget

**Small (2x2):**
```
┌─────────────────┐
│ TODAY           │
│ 2:00 PM         │
│ Client call     │
│ in 2 hours      │
└─────────────────┘
```

**Medium (4x2):**
```
┌─────────────────────────────────────┐
│ TODAY - Jan 8                       │
│ 9:00 AM  Team standup      ✓ Done  │
│ 2:00 PM  Client call       in 2h   │
│ 5:00 PM  Gym                       │
└─────────────────────────────────────┘
```

---

## 4. AI Features (Phase 2)

### 4.1 Auto-Relayout ("Clean" Button)

#### User Flow

```
┌─────────────────────────────────────────────────────┐
│ Before (user's messy input):                        │
│                                                     │
│ "meeting tomorrow need to discuss budget           │
│ also timeline is important                         │
│ tasks: send email, book room, prepare slides"      │
│                                                     │
│                    [✨ Clean]                       │
│                        │                           │
│                        ▼                           │
│ After (AI structured):                             │
│                                                     │
│ Meeting Tomorrow                                    │
│                                                     │
│ Discussion Topics                                  │
│ • Budget review                                    │
│ • Timeline planning                                │
│                                                     │
│ Tasks                                              │
│ ☐ Send email                                       │
│ ☐ Book room                                        │
│ ☐ Prepare slides                                   │
└─────────────────────────────────────────────────────┘
```

#### AI Prompt Template

```
You are a note formatting assistant. Transform the user's messy text into a clean, structured note.

Rules:
1. Detect and create a title if none exists
2. Group related items under headings
3. Convert action items to checkboxes (☐)
4. Convert lists to bullet points
5. Preserve ALL original information
6. Do not add information the user didn't write
7. Keep it concise

Input: {user_text}

Output the structured note in this JSON format:
{
  "blocks": [
    { "type": "title", "content": "..." },
    { "type": "heading", "level": 2, "content": "..." },
    { "type": "bullet", "items": ["...", "..."] },
    { "type": "checkbox", "checked": false, "content": "..." }
  ]
}
```

#### Important Constraints

- Always show preview before applying
- "Undo" available for 30 seconds after
- Never runs automatically
- Works offline (on-device model preferred)

---

### 4.2 AI Schedule Assist

#### Natural Language → Event

```
┌─────────────────────────────────────────────────────┐
│ User types in quick-add:                           │
│                                                     │
│ "lunch with sarah next tuesday at noon"            │
│                                                     │
│         │                                           │
│         ▼                                           │
│ ┌─────────────────────────────────────────────────┐ │
│ │ AI suggests:                                    │ │
│ │                                                 │ │
│ │ Title: Lunch with Sarah                        │ │
│ │ Date: Tuesday, Jan 14, 2025                    │ │
│ │ Time: 12:00 PM                                 │ │
│ │                                                 │ │
│ │ [Create Event]  [Edit]  [Cancel]              │ │
│ └─────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

#### Parsing Rules

| Input Pattern | Extracted |
|---------------|-----------|
| "tomorrow" | Next day |
| "next tuesday" | Coming Tuesday |
| "at 2pm" / "at 14:00" | Time |
| "for 2 hours" | Duration |
| "remind me" | Enable reminder |

#### Human-in-Control Principle

- AI SUGGESTS, never auto-creates
- User must tap "Create" to confirm
- Easy to edit before creating
- Clear indication this is AI-generated

---

## 5. Technical Architecture

### 5.1 Recommended Stack

#### Mobile Framework

**Primary:** Flutter

Reasons:
- Single codebase for iOS + Android
- Excellent widget support (native)
- Fast rendering performance
- Strong offline-first libraries

**Alternative:** React Native + Native Modules

- More JS developer-friendly
- Requires native code for widgets
- Slightly more complex setup

#### Data Layer

```
┌─────────────────────────────────────────────────────┐
│                    App Layer                        │
│                        │                            │
│                        ▼                            │
│              ┌─────────────────┐                   │
│              │ Repository Layer│                   │
│              │ (Business Logic)│                   │
│              └────────┬────────┘                   │
│                       │                            │
│         ┌─────────────┼─────────────┐             │
│         ▼             ▼             ▼             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │ SQLite   │  │ Sync     │  │ Search   │        │
│  │ (Local)  │  │ Engine   │  │ Index    │        │
│  └──────────┘  └──────────┘  └──────────┘        │
└─────────────────────────────────────────────────────┘
```

#### Database Schema (SQLite)

```sql
-- Notes table
CREATE TABLE notes (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  content_json TEXT NOT NULL, -- Stored as JSON
  folder_id TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  is_pinned INTEGER DEFAULT 0,
  FOREIGN KEY (folder_id) REFERENCES folders(id)
);

-- Folders table
CREATE TABLE folders (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  sort_order INTEGER NOT NULL,
  created_at INTEGER NOT NULL
);

-- Events table
CREATE TABLE events (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  date TEXT NOT NULL, -- ISO date
  time TEXT, -- HH:MM or null
  duration_minutes INTEGER,
  linked_note_id TEXT,
  reminder_minutes INTEGER,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (linked_note_id) REFERENCES notes(id)
);

-- App state
CREATE TABLE app_state (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

-- Full-text search
CREATE VIRTUAL TABLE notes_fts USING fts5(
  title,
  content_text,
  content='notes',
  content_rowid='rowid'
);
```

### 5.2 Document Model

```typescript
// Core note structure
interface Note {
  id: string;
  title: string;
  blocks: NoteBlock[];
  folderId: string | null;
  createdAt: number;
  updatedAt: number;
  isPinned: boolean;
}

// Block types
type NoteBlock = 
  | TitleBlock
  | ParagraphBlock
  | HeadingBlock
  | BulletListBlock
  | NumberedListBlock
  | CheckboxBlock;

interface TitleBlock {
  type: 'title';
  content: string;
}

interface ParagraphBlock {
  type: 'paragraph';
  content: string;
}

interface HeadingBlock {
  type: 'heading';
  level: 2 | 3;
  content: string;
}

interface BulletListBlock {
  type: 'bullet';
  items: string[];
}

interface NumberedListBlock {
  type: 'numbered';
  items: string[];
}

interface CheckboxBlock {
  type: 'checkbox';
  checked: boolean;
  content: string;
}
```

### 5.3 Sync Architecture (Phase 3)

```
┌─────────────────────────────────────────────────────┐
│ Local-First Sync Strategy                          │
│                                                     │
│ Device A                    Cloud                   │
│ ┌─────────┐                ┌─────────┐             │
│ │ SQLite  │──── Push ────▶│ Server  │             │
│ │         │◀─── Pull ─────│         │             │
│ └─────────┘                └─────────┘             │
│                                 │                   │
│                                 ▼                   │
│ Device B                  ┌─────────┐             │
│ ┌─────────┐◀─── Pull ─────│ Server  │             │
│ │ SQLite  │──── Push ────▶│         │             │
│ └─────────┘                └─────────┘             │
│                                                     │
│ Conflict Resolution: Last-write-wins with          │
│ timestamp + device ID                              │
└─────────────────────────────────────────────────────┘
```

---

## 6. UX Guidelines

### 6.1 Core Principles

| # | Principle | Implementation |
|---|-----------|----------------|
| 1 | Zero setup | No onboarding, no account required to start |
| 2 | One tap to write | App opens to last note, cursor ready |
| 3 | No configuration | Settings exist but are hidden, smart defaults |
| 4 | AI on demand | Never automatic, always user-triggered |
| 5 | No surprises | Actions are predictable, undo always available |

### 6.2 Interaction Patterns

#### Creating a Note

```
[Tap + button] → [New note created] → [Cursor in title] → [Start typing]
```
Time: < 500ms

#### Adding to Schedule

```
[In note, tap 📅] → [Date picker] → [Confirm] → [Event created + linked]
```

#### Quick Capture (Widget)

```
[Tap widget +] → [Overlay editor] → [Type] → [Auto-save on dismiss]
```

### 6.3 Error Handling

- No error modals for recoverable errors
- Toast notifications for confirmations
- Auto-save every 2 seconds (no "save" button)
- Offline: Full functionality, sync indicator

---

## 7. Development Roadmap

### Phase 1: MVP (8-12 weeks)

**Week 1-2: Foundation**
- [ ] Project setup (Flutter/RN)
- [ ] SQLite database setup
- [ ] Basic navigation structure
- [ ] Document model implementation

**Week 3-4: Note Editor**
- [ ] Rich text editor core
- [ ] Block types (title, paragraph, bullet, checkbox)
- [ ] Auto-save functionality
- [ ] Cursor and selection handling

**Week 5-6: Copy-Paste System**
- [ ] Multi-format clipboard
- [ ] Plain text conversion
- [ ] HTML conversion
- [ ] Testing across apps (WhatsApp, Telegram, Email)

**Week 7-8: Organization**
- [ ] Folder CRUD
- [ ] Note list views
- [ ] Search implementation (FTS5)
- [ ] State persistence

**Week 9-10: Schedule**
- [ ] Event CRUD
- [ ] Calendar views (month, day)
- [ ] Note linking
- [ ] Reminders (local notifications)

**Week 11-12: Widgets & Polish**
- [ ] Notes widget
- [ ] Schedule widget
- [ ] Performance optimization
- [ ] Bug fixes, edge cases

### Phase 2: AI Features (4-6 weeks)

- [ ] AI relayout feature
- [ ] Natural language event parsing
- [ ] On-device model evaluation
- [ ] API fallback for complex queries

### Phase 3: Cloud Sync (4-6 weeks)

- [ ] User authentication
- [ ] Sync engine
- [ ] Conflict resolution
- [ ] Cross-device testing

### Phase 4: Advanced Features (Ongoing)

- [ ] Pattern detection
- [ ] Gentle coaching prompts
- [ ] Goal tracking
- [ ] Export/import

---

## 8. Success Metrics

### Core Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| App launch to typing | < 1 second | Performance logging |
| Copy-paste success | > 95% format preserved | User testing |
| Daily active usage | > 3 sessions/day | Analytics |
| Retention (7-day) | > 40% | Analytics |
| Crash rate | < 0.1% | Crash reporting |

### User Satisfaction

- Copy-paste "just works" in chat apps
- "Feels faster than Apple Notes"
- "Finally, notes and schedule in one place"

---

## 9. Appendix

### A. Competitive Analysis Summary

| Feature | Our App | Apple Notes | Notion | Google Keep |
|---------|---------|-------------|--------|-------------|
| Copy-paste quality | ⭐⭐⭐ | ⭐⭐ | ⭐ | ⭐ |
| Speed | ⭐⭐⭐ | ⭐⭐⭐ | ⭐ | ⭐⭐ |
| Schedule integration | ⭐⭐⭐ | ❌ | ⭐⭐ | ⭐ |
| Simplicity | ⭐⭐⭐ | ⭐⭐⭐ | ⭐ | ⭐⭐ |
| Cross-platform | ⭐⭐⭐ | ❌ | ⭐⭐⭐ | ⭐⭐⭐ |
| AI assistance | ⭐⭐ | ❌ | ⭐⭐ | ❌ |

### B. Glossary

- **Block**: A single unit of content (paragraph, bullet list, checkbox, etc.)
- **Note**: A collection of blocks with metadata
- **Event**: A scheduled item with optional note link
- **Widget**: Home screen component for quick access
- **FTS**: Full-text search

### C. File Structure (Flutter)

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── routes.dart
├── features/
│   ├── notes/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── schedule/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── search/
├── core/
│   ├── database/
│   ├── clipboard/
│   └── theme/
└── widgets/ (home screen widgets)
```

---

## 10. Notes for AI Development Assistants

When helping build this app:

1. **Prioritize simplicity** - If a feature adds complexity without clear user value, question it
2. **Test copy-paste** - This is the killer feature; test across WhatsApp, Telegram, Email, Slack
3. **Performance matters** - App launch should feel instant; measure and optimize
4. **Local-first** - Everything should work offline; sync is optional
5. **No AI surprises** - AI features are always user-triggered, never automatic
6. **Mobile-first** - Design for thumb zones, consider one-handed use

When in doubt, ask: "Would this confuse a user who just wants to write a quick note?"

---

*Document Version: 1.0*
*Last Updated: January 2025*
*Status: Ready for Development*