import 'package:flutter/material.dart';
import '../../../domain/models/damage_type.dart';
import '../../theme/app_theme.dart';

class CombatSection extends StatelessWidget {
  const CombatSection({super.key, required this.strongVs, required this.weakTo});
  final List<DamageType> strongVs;
  final List<DamageType> weakTo;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _col('Mais forte VS', strongVs, AppColors.strong)),
        const SizedBox(width: 10),
        Expanded(child: _col('Mais fraco para', weakTo, AppColors.weak)),
      ],
    );
  }

  Widget _col(String title, List<DamageType> types, Color titleColor) =>
      Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1209),
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(),
                style: TextStyle(
                    color: titleColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .6)),
            const SizedBox(height: 9),
            for (final t in types)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.5),
                child: Row(children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: t.color,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(t.emoji, style: const TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(t.label,
                        style: const TextStyle(
                            color: AppColors.textBody,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
          ],
        ),
      );
}
