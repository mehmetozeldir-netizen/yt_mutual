class YouTubeHelper {
  /// Yalnızca geçerli YouTube alan adlarından video kimliğini alır.
  static String? extractVideoId(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || uri.scheme != 'https' && uri.scheme != 'http') {
      return null;
    }
    final host = uri.host.toLowerCase();
    const hosts = {'youtube.com', 'www.youtube.com', 'm.youtube.com', 'youtu.be', 'www.youtu.be'};
    if (!hosts.contains(host)) return null;

    String? id;
    if (host.contains('youtu.be')) {
      id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    } else if (uri.path == '/watch') {
      id = uri.queryParameters['v'];
    } else if (uri.pathSegments.length >= 2 &&
        (uri.pathSegments.first == 'embed' || uri.pathSegments.first == 'shorts' ||
         uri.pathSegments.first == 'live')) {
      id = uri.pathSegments[1];
    }
    if (id == null || !RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(id)) return null;
    return id;
  }
}
