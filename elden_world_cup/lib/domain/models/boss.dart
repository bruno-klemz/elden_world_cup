import 'damage_type.dart';
import 'loot_item.dart';
import 'map_coord.dart';

class Boss {
  final String id;
  final String name;
  final String? subtitle;
  final String region;
  final String art;
  final String locationName;
  final MapCoord mapCoord;
  final List<DamageType> strongVs;
  final List<DamageType> weakTo;
  final List<LootItem> loot;
  final String lore;

  const Boss({
    required this.id,
    required this.name,
    this.subtitle,
    required this.region,
    required this.art,
    required this.locationName,
    required this.mapCoord,
    this.strongVs = const [],
    this.weakTo = const [],
    this.loot = const [],
    required this.lore,
  });

  factory Boss.fromJson(Map<String, dynamic> json) {
    List<DamageType> dmg(String key) => ((json[key] as List?) ?? const [])
        .map((e) => DamageType.fromKey(e as String))
        .toList();
    return Boss(
      id: json['id'] as String,
      name: json['name'] as String,
      subtitle: json['subtitle'] as String?,
      region: json['region'] as String,
      art: json['art'] as String,
      locationName: json['locationName'] as String,
      mapCoord: MapCoord.fromJson(json['mapCoord'] as Map<String, dynamic>),
      strongVs: dmg('strongVs'),
      weakTo: dmg('weakTo'),
      loot: ((json['loot'] as List?) ?? const [])
          .map((e) => LootItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      lore: json['lore'] as String,
    );
  }
}
