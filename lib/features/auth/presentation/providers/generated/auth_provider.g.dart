// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Auth)
final authProvider = AuthProvider._();

final class AuthProvider extends $AsyncNotifierProvider<Auth, AuthStates> {
  AuthProvider._()
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

String _$authHash() => r'bdb2501a1a48b55236e50407222e3b4f68aa5cde';

abstract class _$Auth extends $AsyncNotifier<AuthStates> {
  FutureOr<AuthStates> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthStates>, AuthStates>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthStates>, AuthStates>,
              AsyncValue<AuthStates>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
