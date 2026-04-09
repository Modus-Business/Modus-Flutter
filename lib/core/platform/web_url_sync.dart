import 'web_url_sync_stub.dart'
    if (dart.library.html) 'web_url_sync_web.dart'
    as sync;

class WebUrlSync {
  const WebUrlSync._();

  static void replace(String location) {
    sync.replaceUrl(location);
  }
}
