import 'package:shared_preferences/shared_preferences.dart';
import '../domain/progress.dart';

class ProgressStore {
  static const _kDefeated = 'defeated';
  static const _kRevealed = 'revealedMap';

  Future<Progress> load() async {
    final prefs = await SharedPreferences.getInstance();
    return Progress(
      defeated: (prefs.getStringList(_kDefeated) ?? const []).toSet(),
      revealedMap: (prefs.getStringList(_kRevealed) ?? const []).toSet(),
    );
  }

  Future<void> save(Progress p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kDefeated, p.defeated.toList());
    await prefs.setStringList(_kRevealed, p.revealedMap.toList());
  }
}
