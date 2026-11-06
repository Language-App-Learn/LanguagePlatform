# ADR 0004 — ASP.NET Core Identity

Parola hash'i, kullanıcı/rol store'ları ve güvenlik damgası için ASP.NET Core Identity kullanılır; özel hash veya sahte login yoktur. Domain profile/preferences/consent/session metadata'sı kullanıcı UUID'sini referanslar. Refresh credential yalnızca hash olarak tutulur; rotation/reuse detection akışı sonraki Identity görevindedir.

Bu temelde authentication middleware ve backend permission policy'leri hazırlanır; login/social login/reset endpoint'leri açılmaz. Mobil için kısa ömürlü access token, dönen refresh token ve cihaz secure storage; admin için BFF üzerinden HttpOnly/Secure cookie, CSRF ve MFA planlanır. Role check permission kontrolünün yerine geçmez.

SuperAdmin yalnızca explicit bootstrap komutuyla, secret store'dan sağlanan güçlü parola ve email ile oluşturulur. Varsayılan parola veya otomatik production kullanıcı oluşturma yoktur.
