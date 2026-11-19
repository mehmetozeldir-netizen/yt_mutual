class YouTubeHelper {
  /// YouTube bağlantısından 11 haneli video ID'sini ayıklar.
  static String? extractVideoId(String url) {
    if (url.trim().isEmpty) return null;

    final regExp = RegExp(
      r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*',
      caseSensitive: false,
    );

    final match = regExp.firstMatch(url.trim());
    if (match != null && match.group(7) != null && match.group(7)!.length == 11) {
      return match.group(7);
    }

    return null;
  }
}
