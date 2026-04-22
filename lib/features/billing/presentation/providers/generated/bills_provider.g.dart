// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../bills_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Bills)
final billsProvider = BillsProvider._();

final class BillsProvider extends $AsyncNotifierProvider<Bills, BillsStates> {
  BillsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billsHash();

  @$internal
  @override
  Bills create() => Bills();
}

String _$billsHash() => r'f672db95fca4dce6394d3b3b2a1831c3af8f7e2e';

abstract class _$Bills extends $AsyncNotifier<BillsStates> {
  FutureOr<BillsStates> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<BillsStates>, BillsStates>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BillsStates>, BillsStates>,
              AsyncValue<BillsStates>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
