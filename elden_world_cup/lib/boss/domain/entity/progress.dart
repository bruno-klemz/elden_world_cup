import 'package:equatable/equatable.dart';

class Progress extends Equatable {
  final Set<String> defeated;
  final Set<String> revealedMap;

  const Progress({this.defeated = const {}, this.revealedMap = const {}});

  bool isDefeated(String id) => defeated.contains(id);

  bool isMapRevealed(String id) =>
      revealedMap.contains(id) || defeated.contains(id);

  Progress toggleDefeated(String id) {
    final next = Set<String>.from(defeated);
    next.contains(id) ? next.remove(id) : next.add(id);
    return Progress(defeated: next, revealedMap: revealedMap);
  }

  Progress revealMap(String id) =>
      Progress(defeated: defeated, revealedMap: {...revealedMap, id});

  Progress hideMap(String id) =>
      Progress(defeated: defeated, revealedMap: {...revealedMap}..remove(id));

  int defeatedCountIn(Iterable<String> bossIds) =>
      bossIds.where(defeated.contains).length;

  @override
  List<Object?> get props => [defeated, revealedMap];
}
