// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../time_slot_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TimeSlot)
final timeSlotProvider = TimeSlotProvider._();

final class TimeSlotProvider
    extends $AsyncNotifierProvider<TimeSlot, TimeSlotStates> {
  TimeSlotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timeSlotProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timeSlotHash();

  @$internal
  @override
  TimeSlot create() => TimeSlot();
}

String _$timeSlotHash() => r'798087b0c51ec2373afc7f176af8602046467bdd';

abstract class _$TimeSlot extends $AsyncNotifier<TimeSlotStates> {
  FutureOr<TimeSlotStates> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TimeSlotStates>, TimeSlotStates>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TimeSlotStates>, TimeSlotStates>,
              AsyncValue<TimeSlotStates>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
