import 'package:flutter_test/flutter_test.dart';
import 'package:elden_world_cup/domain/models/boss.dart';
import 'package:elden_world_cup/domain/models/damage_type.dart';

void main() {
  test('Boss.fromJson parses all fields including snake_case damage keys', () {
    final json = {
      'id': 'malenia',
      'name': 'Malenia',
      'subtitle': 'Boss opcional',
      'region': 'haligtree',
      'art': 'images/malenia.webp',
      'locationName': 'Elphael, Braço da Haligtree',
      'mapCoord': {'x': 0.62, 'y': 0.44},
      'strongVs': ['holy', 'poison', 'scarlet_rot'],
      'weakTo': ['fire', 'bleed', 'frost'],
      'loot': [
        {'name': 'Mão de Malenia', 'icon': 'images/loot/hand.webp'}
      ],
      'lore': 'Filha de Marika...'
    };

    final boss = Boss.fromJson(json);

    expect(boss.id, 'malenia');
    expect(boss.subtitle, 'Boss opcional');
    expect(boss.mapCoord.x, 0.62);
    expect(boss.strongVs, contains(DamageType.scarletRot));
    expect(boss.weakTo, contains(DamageType.fire));
    expect(boss.loot.single.name, 'Mão de Malenia');
  });

  test('Boss.fromJson tolerates missing optional fields', () {
    final boss = Boss.fromJson({
      'id': 'x', 'name': 'X', 'region': 'r', 'art': 'a.webp',
      'locationName': 'loc', 'mapCoord': {'x': 0.0, 'y': 0.0},
      'lore': '',
    });
    expect(boss.subtitle, isNull);
    expect(boss.strongVs, isEmpty);
    expect(boss.loot, isEmpty);
  });
}
