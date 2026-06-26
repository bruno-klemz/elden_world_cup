import 'package:flutter/material.dart';
import '../../../../album/domain/entity/loot_item.dart';
import '../../../../theme/app_theme.dart';

class LootSection extends StatelessWidget {
  const LootSection({super.key, required this.loot});
  final List<LootItem> loot;

  static String _fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');

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
                Stack(
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
                    if (item.quantity != null && item.quantity! > 1)
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('×${_fmt(item.quantity!)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                  ],
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
