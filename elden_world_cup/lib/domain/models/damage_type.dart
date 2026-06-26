import 'package:flutter/material.dart';

enum DamageType {
  holy('Sagrado', '✨', Color(0xFF3A3420)),
  poison('Tóxico', '☠️', Color(0xFF26331F)),
  scarletRot('Podridão Escarlate', '🌸', Color(0xFF3A221F)),
  fire('Fogo', '🔥', Color(0xFF3A2418)),
  bleed('Hemorragia', '🩸', Color(0xFF3A1A1A)),
  frost('Congelamento', '❄️', Color(0xFF1F2C3A)),
  lightning('Raio', '⚡', Color(0xFF33301A)),
  magic('Mágico', '🔮', Color(0xFF231F3A)),
  physical('Físico', '🗡️', Color(0xFF2A2420));

  const DamageType(this.label, this.emoji, this.color);
  final String label;
  final String emoji;
  final Color color;

  static DamageType fromKey(String key) {
    switch (key) {
      case 'holy':
        return DamageType.holy;
      case 'poison':
        return DamageType.poison;
      case 'scarlet_rot':
        return DamageType.scarletRot;
      case 'fire':
        return DamageType.fire;
      case 'bleed':
        return DamageType.bleed;
      case 'frost':
        return DamageType.frost;
      case 'lightning':
        return DamageType.lightning;
      case 'magic':
        return DamageType.magic;
      case 'physical':
        return DamageType.physical;
      default:
        throw ArgumentError('Unknown damage type: $key');
    }
  }
}
