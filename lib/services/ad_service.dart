import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static BannerAd? _bannerAd;
  static bool _bannerLoaded = false;

  // TODO: Replace with your real Ad Unit IDs from AdMob console
  static String get _bannerAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID
    }
    // Production IDs — replace these
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  }

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  static BannerAd loadBanner({required void Function() onLoaded}) {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) { _bannerLoaded = true; onLoaded(); },
        onAdFailedToLoad: (ad, err) { ad.dispose(); },
      ),
    )..load();
    return _bannerAd!;
  }

  static void dispose() { _bannerAd?.dispose(); }
}
