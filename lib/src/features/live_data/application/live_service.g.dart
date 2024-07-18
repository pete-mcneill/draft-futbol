// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$loadDataOnStartHash() => r'dc61cbaf0cb4dbe59bfd847dc99bf85e5b8e036e';

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

/// See also [loadDataOnStart].
@ProviderFor(loadDataOnStart)
const loadDataOnStartProvider = LoadDataOnStartFamily();

/// See also [loadDataOnStart].
class LoadDataOnStartFamily extends Family<AsyncValue<dynamic>> {
  /// See also [loadDataOnStart].
  const LoadDataOnStartFamily();

  /// See also [loadDataOnStart].
  LoadDataOnStartProvider call(
    List<int> ids,
  ) {
    return LoadDataOnStartProvider(
      ids,
    );
  }

  @override
  LoadDataOnStartProvider getProviderOverride(
    covariant LoadDataOnStartProvider provider,
  ) {
    return call(
      provider.ids,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'loadDataOnStartProvider';
}

/// See also [loadDataOnStart].
class LoadDataOnStartProvider extends AutoDisposeFutureProvider<dynamic> {
  /// See also [loadDataOnStart].
  LoadDataOnStartProvider(
    List<int> ids,
  ) : this._internal(
          (ref) => loadDataOnStart(
            ref as LoadDataOnStartRef,
            ids,
          ),
          from: loadDataOnStartProvider,
          name: r'loadDataOnStartProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$loadDataOnStartHash,
          dependencies: LoadDataOnStartFamily._dependencies,
          allTransitiveDependencies:
              LoadDataOnStartFamily._allTransitiveDependencies,
          ids: ids,
        );

  LoadDataOnStartProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.ids,
  }) : super.internal();

  final List<int> ids;

  @override
  Override overrideWith(
    FutureOr<dynamic> Function(LoadDataOnStartRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LoadDataOnStartProvider._internal(
        (ref) => create(ref as LoadDataOnStartRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        ids: ids,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<dynamic> createElement() {
    return _LoadDataOnStartProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LoadDataOnStartProvider && other.ids == ids;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, ids.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin LoadDataOnStartRef on AutoDisposeFutureProviderRef<dynamic> {
  /// The parameter `ids` of this provider.
  List<int> get ids;
}

class _LoadDataOnStartProviderElement
    extends AutoDisposeFutureProviderElement<dynamic> with LoadDataOnStartRef {
  _LoadDataOnStartProviderElement(super.provider);

  @override
  List<int> get ids => (origin as LoadDataOnStartProvider).ids;
}

String _$liveServiceHash() => r'98d5b1495625f376e17b54d854a8fc44ae0c6136';

/// See also [liveService].
@ProviderFor(liveService)
final liveServiceProvider = Provider<LiveService>.internal(
  liveService,
  name: r'liveServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$liveServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LiveServiceRef = ProviderRef<LiveService>;
String _$gameweekInformationHash() =>
    r'cf423dd20aabf7554d51258166117c9a717c1265';

/// See also [gameweekInformation].
@ProviderFor(gameweekInformation)
final gameweekInformationProvider = Provider<Gameweek>.internal(
  gameweekInformation,
  name: r'gameweekInformationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gameweekInformationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GameweekInformationRef = ProviderRef<Gameweek>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
