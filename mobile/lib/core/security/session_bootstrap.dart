import '../network/token_store.dart';
import '../storage/key_value_store.dart';

/// Marker kept in ordinary preferences (not secret) that says "this install
/// has run before".
const installMarkerKey = 'lp.install.v1';

/// Builds the token store at startup.
///
/// * No secret store in this build -> memory-only session.
/// * iOS Keychain entries SURVIVE an uninstall while app preferences do not.
///   If the install marker is missing, any stored session belongs to a
///   previous installation and is wiped instead of being silently restored.
/// * Otherwise the stored session is loaded (a corrupt entry means signed
///   out, see [SecureTokenStore.load]).
Future<TokenStore> loadTokenStore({
  required SecretStore? secrets,
  required KeyValueStore preferences,
}) async {
  if (secrets == null) return InMemoryTokenStore();
  final store = SecureTokenStore(secrets);
  if (preferences.read(installMarkerKey) == null) {
    await store.clear();
    try {
      await preferences.write(installMarkerKey, '1');
    } on Object {
      // Without the marker the next start wipes again: fails closed.
    }
    return store;
  }
  await store.load();
  return store;
}
