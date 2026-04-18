// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../patient_home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PatientHome)
const patientHomeProvider = PatientHomeProvider._();

final class PatientHomeProvider
    extends $AsyncNotifierProvider<PatientHome, PatientHomeStates> {
  const PatientHomeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'patientHomeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$patientHomeHash();

  @$internal
  @override
  PatientHome create() => PatientHome();
}

String _$patientHomeHash() => r'c506d4df1c1e4b37fbf79cf0df0bcaea79ec8ef5';

abstract class _$PatientHome extends $AsyncNotifier<PatientHomeStates> {
  FutureOr<PatientHomeStates> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<PatientHomeStates>, PatientHomeStates>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PatientHomeStates>, PatientHomeStates>,
              AsyncValue<PatientHomeStates>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
