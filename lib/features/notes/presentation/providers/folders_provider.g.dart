// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$foldersRepositoryHash() => r'264f4f1b025b306d986a5814854001583261ca96';

/// See also [foldersRepository].
@ProviderFor(foldersRepository)
final foldersRepositoryProvider =
    AutoDisposeProvider<FoldersRepository>.internal(
      foldersRepository,
      name: r'foldersRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$foldersRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FoldersRepositoryRef = AutoDisposeProviderRef<FoldersRepository>;
String _$foldersListHash() => r'a1ca252876bcde6bbcca4b99691f477dd8c2edd7';

/// See also [FoldersList].
@ProviderFor(FoldersList)
final foldersListProvider =
    AutoDisposeAsyncNotifierProvider<FoldersList, List<Folder>>.internal(
      FoldersList.new,
      name: r'foldersListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$foldersListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FoldersList = AutoDisposeAsyncNotifier<List<Folder>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
