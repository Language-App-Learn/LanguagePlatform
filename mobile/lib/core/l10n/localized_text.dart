import 'package:flutter/foundation.dart';

/// Birden çok dilde yazılmış İÇERİK metni (kurs adı, çeviri, açıklama...).
///
/// Arayüz metinleri için bunun yerine ARB/`context.l10n` kullanılır.
/// Backend sözleşmesi netleşince bu tip DTO'daki karşılığına
/// (ör. `{ "tr": "...", "en": "..." }` ya da çeviri tablosu) eşlenecek.
@immutable
class LocalizedText {
  const LocalizedText(this._values) : _plain = null;

  /// Dile bağlı olmayan metin (özel isimler, sayılar, teknik değerler).
  const LocalizedText.plain(String text) : _values = const {}, _plain = text;

  final Map<String, String> _values;
  final String? _plain;

  /// [code] diline göre çözer; yoksa İngilizce, o da yoksa ilk değer.
  String resolve(String? code) {
    final plain = _plain;
    if (plain != null) return plain;
    return _values[code] ??
        _values['en'] ??
        (_values.values.isEmpty ? '' : _values.values.first);
  }

  /// Herhangi bir dildeki metin [query]'yi (büyük/küçük harf duyarsız)
  /// içeriyor mu? Arama için kullanılır.
  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    final plain = _plain;
    if (plain != null) return plain.toLowerCase().contains(needle);
    return _values.values.any((v) => v.toLowerCase().contains(needle));
  }

  @override
  bool operator ==(Object other) =>
      other is LocalizedText &&
      other._plain == _plain &&
      mapEquals(other._values, _values);

  @override
  int get hashCode =>
      Object.hash(_plain, Object.hashAllUnordered(_values.keys));
}
