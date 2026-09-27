/// Public, sign-in-free pilot pages, hosted alongside the existing Ops site.
/// Move both apps together when a stable production website is commissioned.
/// These are information/request links, never authenticated API endpoints.
class TrotxiPublicInformation {
  TrotxiPublicInformation._();
  static final privacy = Uri.parse(
    'https://trotxi-ops-staging.onrender.com/privacy.html',
  );
  static final deletion = Uri.parse(
    'https://trotxi-ops-staging.onrender.com/delete-account.html',
  );
}
