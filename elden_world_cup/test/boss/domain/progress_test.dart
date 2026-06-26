import 'package:flutter_test/flutter_test.dart';
import 'package:elden_world_cup/boss/domain/entity/progress.dart';

void main() {
  test('toggleDefeated adds then removes immutably', () {
    const p0 = Progress();
    final p1 = p0.toggleDefeated('malenia');
    expect(p0.isDefeated('malenia'), isFalse); // original untouched
    expect(p1.isDefeated('malenia'), isTrue);
    final p2 = p1.toggleDefeated('malenia');
    expect(p2.isDefeated('malenia'), isFalse);
  });

  test('defeated boss is implicitly map-revealed', () {
    final p = const Progress().toggleDefeated('malenia');
    expect(p.isMapRevealed('malenia'), isTrue);
  });

  test('revealMap / hideMap toggle reveal for pending boss', () {
    final p = const Progress().revealMap('godrick');
    expect(p.isMapRevealed('godrick'), isTrue);
    expect(p.hideMap('godrick').isMapRevealed('godrick'), isFalse);
  });

  test('defeatedCountIn counts only matching defeated ids', () {
    final p = const Progress().toggleDefeated('a').toggleDefeated('c');
    expect(p.defeatedCountIn(['a', 'b', 'c']), 2);
  });
}
