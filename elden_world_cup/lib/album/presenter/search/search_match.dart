/// Case- and diacritic-insensitive substring match for search.
bool searchMatches(String text, String query) {
  final q = _normalize(query);
  if (q.isEmpty) return true;
  return _normalize(text).contains(q);
}

String _normalize(String s) {
  var r = s.toLowerCase().trim();
  const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const to = 'aaaaaeeeeiiiiooooouuuucn';
  final buffer = StringBuffer();
  for (final ch in r.split('')) {
    final i = from.indexOf(ch);
    buffer.write(i >= 0 ? to[i] : ch);
  }
  return buffer.toString();
}
