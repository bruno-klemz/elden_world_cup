/// A selection returned by the search screen: jump to a region, or to a boss
/// (which lives in a region and should be scrolled into view).
sealed class SearchResult {
  const SearchResult();
}

class RegionResult extends SearchResult {
  final String regionId;
  const RegionResult(this.regionId);
}

class BossResult extends SearchResult {
  final String bossId;
  final String regionId;
  const BossResult({required this.bossId, required this.regionId});
}
