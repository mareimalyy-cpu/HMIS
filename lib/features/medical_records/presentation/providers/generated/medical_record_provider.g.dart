// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../medical_record_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MedicalRecord)
final medicalRecordProvider = MedicalRecordProvider._();

final class MedicalRecordProvider
    extends $AsyncNotifierProvider<MedicalRecord, MedicalRecordStates> {
  MedicalRecordProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'medicalRecordProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$medicalRecordHash();

  @$internal
  @override
  MedicalRecord create() => MedicalRecord();
}

String _$medicalRecordHash() => r'ece96cfd63a7f48f92d1c2f4b3286a3445216d97';

abstract class _$MedicalRecord extends $AsyncNotifier<MedicalRecordStates> {
  FutureOr<MedicalRecordStates> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<MedicalRecordStates>, MedicalRecordStates>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MedicalRecordStates>, MedicalRecordStates>,
              AsyncValue<MedicalRecordStates>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
