// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../booking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Booking)
final bookingProvider = BookingProvider._();

final class BookingProvider
    extends $AsyncNotifierProvider<Booking, BookingStates> {
  BookingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingHash();

  @$internal
  @override
  Booking create() => Booking();
}

String _$bookingHash() => r'0fe5bf092a5c0820ad9432b04041729512b18564';

abstract class _$Booking extends $AsyncNotifier<BookingStates> {
  FutureOr<BookingStates> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<BookingStates>, BookingStates>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BookingStates>, BookingStates>,
              AsyncValue<BookingStates>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
