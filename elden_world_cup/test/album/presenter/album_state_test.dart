import 'package:elden_world_cup/album/domain/entity/album_data.dart';
import 'package:elden_world_cup/album/domain/entity/boss.dart';
import 'package:elden_world_cup/album/domain/entity/map_coord.dart';
import 'package:elden_world_cup/album/domain/entity/region.dart';
import 'package:elden_world_cup/album/presenter/album/bloc/album_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

Boss _boss(String id, String name, {int mainOrder = 0}) => Boss(
      id: id,
      name: name,
      region: 'limgrave',
      art: 'a.webp',
      locationName: 'loc',
      mapCoord: const MapCoord(0.1, 0.2),
      lore: 'l',
      mainOrder: mainOrder,
    );

void main() {
  group('AlbumState.otherBossesIn', () {
    test('orders non-main bosses alphabetically (case-insensitive)', () {
      final state = AlbumState(
        status: AlbumStatus.loaded,
        data: AlbumData(
          regions: const [Region(id: 'limgrave', name: 'Limgrave', order: 1)],
          bosses: [
            _boss('z', 'Zamor'),
            _boss('a', 'beastman'), // lowercase to prove case-insensitivity
            _boss('m', 'Margit', mainOrder: 1), // main boss, excluded
            _boss('c', 'Crucible Knight'),
          ],
        ),
      );

      final names =
          state.otherBossesIn('limgrave').map((b) => b.name).toList();

      expect(names, ['beastman', 'Crucible Knight', 'Zamor']);
    });
  });
}
