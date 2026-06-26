import 'package:equatable/equatable.dart';

class LootItem extends Equatable {
  final String name;
  final String? icon;
  final int? quantity;
  const LootItem({required this.name, this.icon, this.quantity});

  factory LootItem.fromJson(Map<String, dynamic> json) => LootItem(
        name: json['name'] as String,
        icon: json['icon'] as String?,
        quantity: json['quantity'] as int?,
      );

  @override
  List<Object?> get props => [name, icon, quantity];
}
