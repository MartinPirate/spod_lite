# OAuth

Sign users in with their Google (and soon: GitHub, Apple) account. The flow uses the same `AppUser` identity as email-password, so one person can sign in with either and end up on the same record.

Today's provider list:

| Provider | Status |
|---|---|
| Google  | Shipping. OIDC via `openid email profile` scopes. |
| GitHub  | Not yet. |
| Apple   | Not yet. |

---

## Configure a provider

Every provider needs a `client_id` and `client_secret` from the provider's console. The server stores those in a per-provider row on the `oauth_provider_config` table.

### Get Google credentials

1. Open the [Google Cloud Console](https://console.cloud.google.com/apis/credentials).
2. Create an **OAuth 2.0 Client ID** of type **Web application**.
3. Under *Authorized redirect URIs*, add the exact URI your app will redirect to after consent. For local dev that's typically `http://localhost:3000/oauth/callback` or a custom-scheme app URI.
4. Copy the generated *Client ID* and *Client secret*.

### Save them via the admin endpoint

From the dashboard (or straight from the typed client if you haven't wired the dashboard UI yet):

```dart
await adminClient.oAuthConfig.save(
  'google',
  clientId,
  clientSecret,
  true, // enabled
);
```

- Passing an empty `clientSecret` on a later `save` call keeps the stored value — so the dashboard can toggle `enabled` or edit `clientId` without knowing the current secret.
- The `list()` call echoes rows with the secret redacted (literal `••••••••` means "a secret is stored"; empty string means "no secret").

---

## Sign in from an app

```dart
// Which providers are configured right now?
final providers = await spod.oauth.listProviders();
// e.g. ['google']

// Step 1: ask the server to build a consent URL.
final url = await spod.oauth.getAuthUrl(
  provider: 'google',
  redirectUri: 'http://localhost:3000/oauth/callback',
);

// Step 2: open `url` in a browser or web view. After consent the
// provider redirects back to redirectUri with `state` and `code`
// query parameters.

// Step 3: your redirect handler extracts state + code and calls:
final identity = await spod.oauth.completeAuth(
  provider: 'google',
  state: state,
  code: code,
);
// `spod.userAuth.currentUser` is now populated; the session token
// is already in the store.
```

The SDK stores the resulting `AppSession` token in the same `SpodLiteTokenStore` that `userAuth.signIn()` writes to. After `completeAuth` returns there's nothing else to wire — authenticated endpoint calls just work.

---

## Account linking

`completeAuth` finds-or-creates an `AppUser` in this order:

1. **Already linked.** If `(provider, provider_user_id)` is in `user_oauth_link`, sign that user in.
2. **Existing email.** If the provider returns a verified email and an `AppUser` with that email already exists, create a link to that user. If the existing user hadn't verified their email yet, flip `emailVerified = true` — the provider just asserted it.
3. **New account.** Otherwise create an `AppUser` with `password_hash = '!oauth'` (a non-bcrypt sentinel that fails every password check) and `email_verified = true`, then create the link.

We refuse to link anything with an unverified email from the provider — otherwise anyone who signs up at Google first with your address could hijack a password account that shares the address. If a provider doesn't mark the email as verified, the flow fails with `unauthorized`.

### Adding a password to an OAuth account

Users who signed up through Google can still use email-password later — the password-reset flow overwrites `password_hash` with a real bcrypt value. After that the account has both sign-in paths.

---

## What the flow actually does

```
client → server   oauth.getAuthUrl(provider, redirectUri)
server → client   consent URL (with state nonce)

(browser does the consent dance with the provider)

provider → client redirect to redirectUri?state=...&code=...

client → server   oauth.completeAuth(provider, state, code)
server → provider POST /token   { code, client_id, client_secret, redirect_uri }
provider → server access_token
server → provider GET /userinfo
provider → server { sub, email, email_verified }
server → (db)     find-or-create AppUser + UserOAuthLink
server → client   AppSession token
```

State is a cryptographically random 32-byte token, stored server-side with a 10-minute TTL and consumed on `completeAuth` (single-use). The state store is in-memory; for a multi-instance deploy swap `OAuthStateStore` for a Redis-backed implementation behind the same interface.

---

## Adding a new provider

Drop a class in `spod_lite_server/lib/src/oauth/providers/` extending `OAuthProvider`:

```dart
class GitHubOAuthProvider extends OAuthProvider {
  @override String get id => 'github';
  @override String get label => 'GitHub';

  @override
  Uri buildAuthUrl({required clientId, required redirectUri, required state}) {
    // ...
  }

  @override
  Future<OAuthIdentity> resolveIdentity({
    required session, required config, required code, required redirectUri,
  }) async {
    // ...
  }
}
```

Register it in `oauth_registry.dart`, rerun codegen, and the new provider appears in `listProviders()` the moment an admin saves a config for it. The public endpoint is provider-agnostic — nothing else changes.

---

## What's not covered (yet)

- **Refresh tokens.** We exchange the code once to fetch identity, then discard the access token. Users re-authenticate when their `AppSession` expires (30 days).
- **Profile sync.** We don't pull the user's name or avatar. Add those to `AppUser` if you need them; the provider already returns them in `userinfo`.
- **Provider-initiated unlink.** There's no endpoint to *remove* an `OAuthLink` yet. Delete the row directly in dev.
- **PKCE.** Not used — the server holds the client secret, so the S256 exchange isn't required. If we ship a mobile-only provider where the secret can't travel to the server, PKCE goes in then.
