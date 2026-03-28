// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Settings)
const settingsProvider = SettingsProvider._();

final class SettingsProvider
    extends $AsyncNotifierProvider<Settings, SettingsStates> {
  const SettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsHash();

  @$internal
  @override
  Settings create() => Settings();
}

String _$settingsHash() => r'415f4a72e686bdf7adc72844c654fd9d90910522';

abstract class _$Settings extends $AsyncNotifier<SettingsStates> {
  FutureOr<SettingsStates> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<SettingsStates>, SettingsStates>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SettingsStates>, SettingsStates>,
              AsyncValue<SettingsStates>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
