import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entity/progress.dart';
import '../../domain/repository/progress_repository.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  static const _kDefeated = 'defeated';
  static const _kRevealed = 'revealedMap';

  @override
  Future<Progress> load() async {
    final prefs = await SharedPreferences.getInstance();
    return Progress(
      defeated: (prefs.getStringList(_kDefeated) ?? const []).toSet(),
      revealedMap: (prefs.getStringList(_kRevealed) ?? const []).toSet(),
    );
  }

  @override
  Future<void> save(Progress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kDefeated, progress.defeated.toList());
    await prefs.setStringList(_kRevealed, progress.revealedMap.toList());
  }
}
