part of 'boss_details_bloc.dart';

class BossDetailsState extends Equatable {
  final Boss boss;
  final Progress progress;

  /// Transient flag: true on the frame the boss just transitioned to defeated,
  /// so the view can play the reveal animation. Reset on the next event.
  final bool justRevealed;

  const BossDetailsState({
    required this.boss,
    this.progress = const Progress(),
    this.justRevealed = false,
  });

  bool get isDefeated => progress.isDefeated(boss.id);
  bool get isMapRevealed => progress.isMapRevealed(boss.id);

  BossDetailsState copyWith({
    Progress? progress,
    bool? justRevealed,
  }) {
    return BossDetailsState(
      boss: boss,
      progress: progress ?? this.progress,
      justRevealed: justRevealed ?? this.justRevealed,
    );
  }

  @override
  List<Object?> get props => [boss, progress, justRevealed];
}
