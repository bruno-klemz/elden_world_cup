class LootItem {
  final String name;
  final String? icon;
  const LootItem({required this.name, this.icon});

  factory LootItem.fromJson(Map<String, dynamic> json) =>
      LootItem(name: json['name'] as String, icon: json['icon'] as String?);
}
