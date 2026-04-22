// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../admin_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Admin)
final adminProvider = AdminProvider._();

final class AdminProvider extends $AsyncNotifierProvider<Admin, AdminStates> {
  AdminProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminHash();

  @$internal
  @override
  Admin create() => Admin();
}

String _$adminHash() => r'b3896f58ef74d7edb719de0d6bc8972bae686d40';

abstract class _$Admin extends $AsyncNotifier<AdminStates> {
  FutureOr<AdminStates> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AdminStates>, AdminStates>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AdminStates>, AdminStates>,
              AsyncValue<AdminStates>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
