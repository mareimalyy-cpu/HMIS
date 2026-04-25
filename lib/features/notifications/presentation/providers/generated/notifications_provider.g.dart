// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationsNotifier)
final notificationsProvider = NotificationsNotifierProvider._();

final class NotificationsNotifierProvider
    extends $AsyncNotifierProvider<NotificationsNotifier, NotificationsStates> {
  NotificationsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsNotifierHash();

  @$internal
  @override
  NotificationsNotifier create() => NotificationsNotifier();
}

String _$notificationsNotifierHash() =>
    r'ce2adac907c91a7faed451984efb5db97e8fd11b';

abstract class _$NotificationsNotifier
    extends $AsyncNotifier<NotificationsStates> {
  FutureOr<NotificationsStates> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<NotificationsStates>, NotificationsStates>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<NotificationsStates>, NotificationsStates>,
              AsyncValue<NotificationsStates>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
