import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/network/api_client.dart';
import 'package:language_platform/core/network/token_store.dart';
import 'package:language_platform/features/authentication/application/auth_providers.dart';
import 'package:language_platform/features/authentication/data/remote_auth_repository.dart';

import '../fakes/five_stage_fakes.dart';

/// Sign-out is kept account infrastructure (no screen links to it right now):
/// it must always end the local session, even when the server is unreachable.
void main() {
  Future<(ProviderContainer, WidgetRef, InMemoryTokenStore, HandlerApiClient)>
  setUp(WidgetTester tester, ApiResponse Function() reply) async {
    final tokens = InMemoryTokenStore();
    await tokens.save(const TokenPair(accessToken: 'a', refreshToken: 'r'));
    final api = HandlerApiClient((_) async => reply());
    late WidgetRef captured;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiBaseUriProvider.overrideWithValue(
            Uri.parse('http://localhost:5000'),
          ),
          tokenStoreProvider.overrideWithValue(tokens),
          authRepositoryProvider.overrideWithValue(
            RemoteAuthRepository(api, tokens),
          ),
          sessionProvider.overrideWith(
            () => SessionNotifier(SessionStatus.authenticated),
          ),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            captured = ref;
            return const SizedBox();
          },
        ),
      ),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Consumer)),
    );
    return (container, captured, tokens, api);
  }

  testWidgets('sign-out calls the server logout and clears the tokens', (
    tester,
  ) async {
    final (container, ref, tokens, api) = await setUp(
      tester,
      () => const ApiResponse(204),
    );
    await signOutOfAccount(ref);
    expect(tokens.read(), isNull);
    expect(container.read(sessionProvider), SessionStatus.signedOut);
    expect(api.requests.single.path, '/api/v1/auth/logout');
  });

  testWidgets('sign-out still ends the session when the server fails', (
    tester,
  ) async {
    final (container, ref, tokens, _) = await setUp(
      tester,
      () => const ApiResponse(503),
    );
    try {
      await signOutOfAccount(ref);
    } on Object {
      // The failure may surface, but the local session must be gone.
    }
    expect(tokens.read(), isNull);
    expect(container.read(sessionProvider), SessionStatus.signedOut);
  });
}
