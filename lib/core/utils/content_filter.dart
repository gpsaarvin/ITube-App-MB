class ContentFilter {
  static final List<String> _blockedKeywords = [
    'explicit',
    'porn',
    'violence',
    'drugs',
    'gambling',
    'weapon',
    'hate',
    'terror',
    'self-harm',
    'suicide',
    'adult',
    'nsfw',
  ];

  bool isBlocked(String query) {
    final normalized = query.toLowerCase();
    for (final keyword in _blockedKeywords) {
      if (normalized.contains(keyword)) {
        return true;
      }
    }
    return false;
  }
}
