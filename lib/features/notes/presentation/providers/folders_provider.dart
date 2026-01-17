import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_service.dart';
import '../../data/repositories/folders_repository.dart';
import '../../domain/models/folder_model.dart';
import 'notes_provider.dart';

part 'folders_provider.g.dart';

@riverpod
FoldersRepository foldersRepository(FoldersRepositoryRef ref) =>
    FoldersRepository(DatabaseService());

@riverpod
class FoldersList extends _$FoldersList {
  @override
  Future<List<Folder>> build() async {
    return ref.watch(foldersRepositoryProvider).getFolders();
  }

  Future<void> createFolder(String name) async {
    final id = const Uuid().v4();
    final newFolder = Folder(id: id, name: name, createdAt: DateTime.now());

    state = await AsyncValue.guard(() async {
      await ref.read(foldersRepositoryProvider).createFolder(newFolder);
      final previousState = await future;
      return [newFolder, ...previousState];
    });
  }

  Future<void> deleteFolder(String id) async {
    state = await AsyncValue.guard(() async {
      await ref.read(foldersRepositoryProvider).deleteFolder(id);
      // Invalidate notes provider because deleting a folder affects notes' folderId
      ref.invalidate(notesListProvider);

      final previousState = await future;
      return previousState.where((f) => f.id != id).toList();
    });
  }

  Future<void> renameFolder(String id, String newName) async {
    state = await AsyncValue.guard(() async {
      await ref.read(foldersRepositoryProvider).renameFolder(id, newName);
      final previousState = await future;
      return [
        for (final f in previousState)
          if (f.id == id) f.copyWith(name: newName) else f,
      ];
    });
  }
}
