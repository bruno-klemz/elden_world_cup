import 'package:flutter/material.dart';
import '../../../domain/models/loot_item.dart';
import '../../theme/app_theme.dart';

class LootSection extends StatelessWidget {
  const LootSection({super.key, required this.loot});
  final List<LootItem> loot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: loot.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final item = loot[i];
          return SizedBox(
            width: 74,
            child: Column(
              children: [
                Container(
                  width: 74,
                  height: 74,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: item.icon == null
                      ? const Text('💎', style: TextStyle(fontSize: 28))
                      : Image.asset('assets/${item.icon}',
                          width: 40,
                          height: 40,
                          errorBuilder: (context, error, stack) =>
                              const Text('💎', style: TextStyle(fontSize: 28))),
                ),
                const SizedBox(height: 5),
                Text(item.name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textBody, fontSize: 9, height: 1.2)),
              ],
            ),
          );
        },
      ),
    );
  }
}
