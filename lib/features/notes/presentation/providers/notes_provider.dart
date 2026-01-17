import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_service.dart';
import '../../data/repositories/notes_repository.dart';
import '../../domain/models/note_model.dart';

part 'notes_provider.g.dart';

@riverpod
NotesRepository notesRepository(NotesRepositoryRef ref) =>
    NotesRepository(DatabaseService());

@riverpod
class NotesList extends _$NotesList {
  @override
  Future<List<Note>> build() async {
    return ref.watch(notesRepositoryProvider).getNotes();
  }

  // Helper to find a note in the current state
  Note? getNoteById(String id) {
    return state.valueOrNull?.firstWhere((n) => n.id == id);
  }

  Future<String> addNote(
    String title,
    String contentJson, {
    String? folderId,
  }) async {
    final id = const Uuid().v4();
    final newNote = Note(
      id: id,
      title: title,
      contentJson: contentJson,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      folderId: folderId,
    );

    state = await AsyncValue.guard(() async {
      await ref.read(notesRepositoryProvider).saveNote(newNote);
      final previousState = await future;
      return [...previousState, newNote];
    });
    return id;
  }

  Future<void> updateNote(Note note) async {
    state = await AsyncValue.guard(() async {
      final updatedNote = note.copyWith(updatedAt: DateTime.now());
      await ref.read(notesRepositoryProvider).saveNote(updatedNote);
      final previousState = await future;
      return [
        for (final n in previousState)
          if (n.id == note.id) updatedNote else n,
      ];
    });
  }

  Future<void> deleteNote(String id) async {
    state = await AsyncValue.guard(() async {
      await ref.read(notesRepositoryProvider).deleteNote(id);
      final previousState = await future;
      return previousState.where((n) => n.id != id).toList();
    });
  }

  Future<void> moveNote(String noteId, String? newFolderId) async {
    final note = getNoteById(noteId);
    if (note == null) return;

    final updatedNote = note.copyWith(folderId: newFolderId);
    await updateNote(updatedNote);
  }
}

@riverpod
List<Note> filteredNotes(FilteredNotesRef ref, String? folderId) {
  final notesAsync = ref.watch(notesListProvider);
  return notesAsync.when(
    data: (notes) {
      if (folderId == null) return notes;
      return notes.where((n) => n.folderId == folderId).toList();
    },
    error: (_, __) => [],
    loading: () => [],
  );
}
