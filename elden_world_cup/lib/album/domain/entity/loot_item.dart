import 'package:equatable/equatable.dart';

class LootItem extends Equatable {
  final String name;
  final String? icon;
  const LootItem({required this.name, this.icon});

  factory LootItem.fromJson(Map<String, dynamic> json) =>
      LootItem(name: json['name'] as String, icon: json['icon'] as String?);

  @override
  List<Object?> get props => [name, icon];
}
