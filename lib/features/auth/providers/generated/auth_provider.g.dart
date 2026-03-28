// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Auth)
const authProvider = AuthProvider._();

final class AuthProvider extends $AsyncNotifierProvider<Auth, AuthStates> {
  const AuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authHash();

  @$internal
  @override
  Auth create() => Auth();
}

String _$authHash() => r'7883a92bbad4491711bc60b1d0348e405b2d72c7';

abstract class _$Auth extends $AsyncNotifier<AuthStates> {
  FutureOr<AuthStates> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<AuthStates>, AuthStates>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthStates>, AuthStates>,
              AsyncValue<AuthStates>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
