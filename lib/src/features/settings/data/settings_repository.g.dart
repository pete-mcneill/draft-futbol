// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appSettingsRepositoryHash() =>
    r'096d9bd98235b3d454b63f90725ac2d410500f41';

/// API for reading, watching and writing local cart data (guest user)
///
/// Copied from [AppSettingsRepository].
@ProviderFor(AppSettingsRepository)
final appSettingsRepositoryProvider =
    NotifierProvider<AppSettingsRepository, AppSettings>.internal(
  AppSettingsRepository.new,
  name: r'appSettingsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appSettingsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppSettingsRepository = Notifier<AppSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
