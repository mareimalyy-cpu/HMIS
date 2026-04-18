// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../booking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Booking)
const bookingProvider = BookingProvider._();

final class BookingProvider
    extends $AsyncNotifierProvider<Booking, BookingStates> {
  const BookingProvider._()
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

String _$bookingHash() => r'fef4e371c4a0a7836f39a1baf645cebd7bdaba16';

abstract class _$Booking extends $AsyncNotifier<BookingStates> {
  FutureOr<BookingStates> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<BookingStates>, BookingStates>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BookingStates>, BookingStates>,
              AsyncValue<BookingStates>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
