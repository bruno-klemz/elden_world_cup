import 'package:equatable/equatable.dart';

/// User display preferences. [blurPending] controls whether not-yet-defeated
/// boss art is blurred (default) or shown sharp for easier identification.
class Settings extends Equatable {
  final bool blurPending;

  const Settings({this.blurPending = true});

  Settings copyWith({bool? blurPending}) =>
      Settings(blurPending: blurPending ?? this.blurPending);

  @override
  List<Object?> get props => [blurPending];
}
