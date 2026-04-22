// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../patient_appointments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PatientAppointments)
final patientAppointmentsProvider = PatientAppointmentsProvider._();

final class PatientAppointmentsProvider
    extends
        $AsyncNotifierProvider<PatientAppointments, PatientAppointmentsStates> {
  PatientAppointmentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'patientAppointmentsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$patientAppointmentsHash();

  @$internal
  @override
  PatientAppointments create() => PatientAppointments();
}

String _$patientAppointmentsHash() =>
    r'5f3202ed0574fa0d2b2823089715ea9b74f7461d';

abstract class _$PatientAppointments
    extends $AsyncNotifier<PatientAppointmentsStates> {
  FutureOr<PatientAppointmentsStates> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PatientAppointmentsStates>,
              PatientAppointmentsStates
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PatientAppointmentsStates>,
                PatientAppointmentsStates
              >,
              AsyncValue<PatientAppointmentsStates>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
