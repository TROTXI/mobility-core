/// Public, sign-in-free pages: the privacy notice and the deletion request.
/// These are information/request links, never authenticated API endpoints.
///
/// The site is a build input (`PUBLIC_SITE_URL`), like the API address, so a
/// production build points at the production pages without a code change.
/// Apps call [ensureConfigured] at startup and refuse to run without it.
class TrotxiPublicInformation {
  TrotxiPublicInformation._();
  static const site = String.fromEnvironment('PUBLIC_SITE_URL');

  static Uri get privacy => _page('privacy');
  static Uri get deletion => _page('delete-account');

  static Uri _page(String path) =>
      Uri.parse(site.endsWith('/') ? site : '$site/').resolve(path);

  /// Throws unless the build supplied an absolute HTTPS site address
  /// (plain HTTP only for a local site while developing).
  static void ensureConfigured({bool release = false}) {
    final uri = Uri.tryParse(site);
    final local = const {'localhost', '127.0.0.1', '10.0.2.2'}.contains(
      uri?.host,
    );
    if (uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty ||
        !(uri.scheme == 'https' ||
            (!release && local && uri.scheme == 'http'))) {
      throw ArgumentError('Invalid PUBLIC_SITE_URL build definition');
    }
  }
}
