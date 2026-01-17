import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_service.dart';
import '../../domain/models/folder_model.dart';

class FoldersRepository {
  final DatabaseService _databaseService;

  FoldersRepository(this._databaseService);

  Future<List<Folder>> getFolders() async {
    final db = await _databaseService.database;
    final maps = await db.query('folders', orderBy: 'created_at DESC');

    return maps.map((map) => Folder.fromJson(map)).toList();
  }

  Future<void> createFolder(Folder folder) async {
    final db = await _databaseService.database;
    await db.insert(
      'folders',
      folder.toJson(),
      conflictAlgorithm: ConflictAlgorithm.fail, // Fail if name not unique
    );
  }

  Future<void> deleteFolder(String id) async {
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      // 1. Unlink notes from this folder (move to "All Notes")
      await txn.update(
        'notes',
        {'folder_id': null},
        where: 'folder_id = ?',
        whereArgs: [id],
      );

      // 2. Delete the folder
      await txn.delete('folders', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> renameFolder(String id, String newName) async {
    final db = await _databaseService.database;
    await db.update(
      'folders',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
