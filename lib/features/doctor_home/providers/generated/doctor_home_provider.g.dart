// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../doctor_home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DoctorHome)
final doctorHomeProvider = DoctorHomeProvider._();

final class DoctorHomeProvider
    extends $AsyncNotifierProvider<DoctorHome, DoctorHomeStates> {
  DoctorHomeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'doctorHomeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$doctorHomeHash();

  @$internal
  @override
  DoctorHome create() => DoctorHome();
}

String _$doctorHomeHash() => r'e4caf1d34b2996013e315ec703d301b2860b7ed8';

abstract class _$DoctorHome extends $AsyncNotifier<DoctorHomeStates> {
  FutureOr<DoctorHomeStates> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<DoctorHomeStates>, DoctorHomeStates>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DoctorHomeStates>, DoctorHomeStates>,
              AsyncValue<DoctorHomeStates>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
