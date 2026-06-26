class Region {
  final String id;
  final String name;
  final int order;
  const Region({required this.id, required this.name, required this.order});

  factory Region.fromJson(Map<String, dynamic> json) => Region(
        id: json['id'] as String,
        name: json['name'] as String,
        order: json['order'] as int,
      );
}
