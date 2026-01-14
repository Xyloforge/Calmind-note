import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_service.dart';
import '../../domain/models/note_model.dart';

class NotesRepository {
  final DatabaseService _databaseService;

  NotesRepository(this._databaseService);

  Future<List<Note>> getNotes() async {
    final db = await _databaseService.database;
    final maps = await db.query('notes', orderBy: 'updated_at DESC');

    return maps.map((map) => Note.fromJson(map)).toList();
  }

  Future<Note?> getNote(String id) async {
    final db = await _databaseService.database;
    final maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return Note.fromJson(maps.first);
  }

  Future<void> saveNote(Note note) async {
    final db = await _databaseService.database;
    await db.insert(
      'notes',
      note.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteNote(String id) async {
    final db = await _databaseService.database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
