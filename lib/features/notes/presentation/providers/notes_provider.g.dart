// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notesRepositoryHash() => r'e1ece462a6fa414e2f92beba929402367479f356';

/// See also [notesRepository].
@ProviderFor(notesRepository)
final notesRepositoryProvider = AutoDisposeProvider<NotesRepository>.internal(
  notesRepository,
  name: r'notesRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notesRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotesRepositoryRef = AutoDisposeProviderRef<NotesRepository>;
String _$filteredNotesHash() => r'bbbc91bf8a21d796da8368dd3d348b44fb0ca874';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [filteredNotes].
@ProviderFor(filteredNotes)
const filteredNotesProvider = FilteredNotesFamily();

/// See also [filteredNotes].
class FilteredNotesFamily extends Family<List<Note>> {
  /// See also [filteredNotes].
  const FilteredNotesFamily();

  /// See also [filteredNotes].
  FilteredNotesProvider call(String? folderId) {
    return FilteredNotesProvider(folderId);
  }

  @override
  FilteredNotesProvider getProviderOverride(
    covariant FilteredNotesProvider provider,
  ) {
    return call(provider.folderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'filteredNotesProvider';
}

/// See also [filteredNotes].
class FilteredNotesProvider extends AutoDisposeProvider<List<Note>> {
  /// See also [filteredNotes].
  FilteredNotesProvider(String? folderId)
    : this._internal(
        (ref) => filteredNotes(ref as FilteredNotesRef, folderId),
        from: filteredNotesProvider,
        name: r'filteredNotesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$filteredNotesHash,
        dependencies: FilteredNotesFamily._dependencies,
        allTransitiveDependencies:
            FilteredNotesFamily._allTransitiveDependencies,
        folderId: folderId,
      );

  FilteredNotesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.folderId,
  }) : super.internal();

  final String? folderId;

  @override
  Override overrideWith(List<Note> Function(FilteredNotesRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: FilteredNotesProvider._internal(
        (ref) => create(ref as FilteredNotesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        folderId: folderId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<Note>> createElement() {
    return _FilteredNotesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredNotesProvider && other.folderId == folderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, folderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FilteredNotesRef on AutoDisposeProviderRef<List<Note>> {
  /// The parameter `folderId` of this provider.
  String? get folderId;
}

class _FilteredNotesProviderElement
    extends AutoDisposeProviderElement<List<Note>>
    with FilteredNotesRef {
  _FilteredNotesProviderElement(super.provider);

  @override
  String? get folderId => (origin as FilteredNotesProvider).folderId;
}

String _$notesListHash() => r'0a118b72869e64c77e6cda4190bbf17fb4652dc6';

/// See also [NotesList].
@ProviderFor(NotesList)
final notesListProvider =
    AutoDisposeAsyncNotifierProvider<NotesList, List<Note>>.internal(
      NotesList.new,
      name: r'notesListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notesListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotesList = AutoDisposeAsyncNotifier<List<Note>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
