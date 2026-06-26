import 'package:flutter_test/flutter_test.dart';
import 'package:elden_world_cup/data/boss_repository.dart';

void main() {
  test('load parses regions and bosses from injected JSON', () async {
    const json = '''
    {"regions":[{"id":"limgrave","name":"Limgrave","order":1}],
     "bosses":[{"id":"margit","name":"Margit","region":"limgrave",
       "art":"a.webp","locationName":"loc","mapCoord":{"x":0.1,"y":0.2},
       "lore":"l"}]}''';
    final repo = BossRepository.withLoader((_) async => json);

    final data = await repo.load();

    expect(data.regions.single.name, 'Limgrave');
    expect(data.bossesIn('limgrave').single.id, 'margit');
  });

  test('load sorts regions by order', () async {
    const json = '''
    {"regions":[
       {"id":"b","name":"B","order":2},
       {"id":"a","name":"A","order":1}],
     "bosses":[]}''';
    final repo = BossRepository.withLoader((_) async => json);

    final data = await repo.load();

    expect(data.regions.map((r) => r.id).toList(), ['a', 'b']);
  });
}
