import 'package:elden_world_cup/album/presenter/search/search_match.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('matches case-insensitively', () {
    expect(searchMatches('Limgrave', 'lim'), isTrue);
    expect(searchMatches('limgrave', 'LIM'), isTrue);
  });

  test('matches ignoring diacritics', () {
    expect(searchMatches('Planalto de Altus', 'altus'), isTrue);
    expect(searchMatches('Podridão', 'podridao'), isTrue);
    expect(searchMatches('Leyndell Cinérea', 'cinerea'), isTrue);
  });

  test('matches anywhere in the string', () {
    expect(searchMatches('Lobo Vermelho de Radagon', 'radagon'), isTrue);
  });

  test('empty query matches everything', () {
    expect(searchMatches('whatever', ''), isTrue);
    expect(searchMatches('whatever', '   '), isTrue);
  });

  test('non-match returns false', () {
    expect(searchMatches('Limgrave', 'caelid'), isFalse);
  });
}
