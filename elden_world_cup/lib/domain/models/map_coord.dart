class MapCoord {
  final double x;
  final double y;
  const MapCoord(this.x, this.y);

  factory MapCoord.fromJson(Map<String, dynamic> json) =>
      MapCoord((json['x'] as num).toDouble(), (json['y'] as num).toDouble());
}
