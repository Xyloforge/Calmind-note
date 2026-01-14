import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_service.dart';
import '../../data/repositories/notes_repository.dart';
import '../../domain/models/note_model.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository(DatabaseService());
});

final notesListProvider =
    StateNotifierProvider<NotesListNotifier, AsyncValue<List<Note>>>((ref) {
      final repository = ref.read(notesRepositoryProvider);
      return NotesListNotifier(repository);
    });

class NotesListNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  final NotesRepository _repository;

  NotesListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    try {
      final notes = await _repository.getNotes();
      state = AsyncValue.data(notes);
    } catch (e, st) {
      debugPrint(e.toString());
      state = AsyncValue.error(e, st);
    }
  }

  Future<String> addNote(String title, String contentJson) async {
    final id = const Uuid().v4();
    final note = Note(
      id: id,
      title: title,
      contentJson: contentJson,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.saveNote(note);
    await loadNotes();
    return id;
  }

  Future<void> updateNote(Note note) async {
    final updatedNote = note.copyWith(updatedAt: DateTime.now());
    await _repository.saveNote(updatedNote);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _repository.deleteNote(id);
    await loadNotes();
  }
}
