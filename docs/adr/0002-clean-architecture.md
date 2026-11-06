# ADR 0002 — Dört katmanı koruma

Domain yalnızca .NET temel tiplerini kullanır. Application Domain'e, Infrastructure Application ve Domain'e, API Application ve Infrastructure'a referans verir. Identity framework tipleri Infrastructure'da kalır; Domain kullanıcıyı UUID ile referanslar. Genel repository/Unit of Work katmanı eklenmez. Modül bazlı küçük persistence portları ve EF DbContext kullanılır.
