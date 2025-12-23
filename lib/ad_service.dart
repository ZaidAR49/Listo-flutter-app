import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal() {
    try {
      _bannerAdUnitId = Platform.isAndroid
          ? (dotenv.env['ANDROID_BANNER_AD_UNIT_ID'] ?? 'ca-app-pub-3940256099942544/6300978111')
          : (dotenv.env['IOS_BANNER_AD_UNIT_ID'] ?? 'ca-app-pub-3940256099942544/2934735716');
    } catch (_) {
      debugPrint('AdService: dotenv not initialized, using test IDs.');
      _bannerAdUnitId = Platform.isAndroid 
          ? 'ca-app-pub-3940256099942544/6300978111' 
          : 'ca-app-pub-3940256099942544/2934735716';
    }
  }

  late String _bannerAdUnitId;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  BannerAd? createBannerAd({
    required Function() onAdLoaded,
    required Function() onRetryWithTestId,
  }) {
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('✅ Ad loaded.');
          onAdLoaded();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('❌ Ad failed to load: $error');
          ad.dispose();

          final String testId = Platform.isAndroid 
              ? 'ca-app-pub-3940256099942544/6300978111' 
              : 'ca-app-pub-3940256099942544/2934735716';

          if (_bannerAdUnitId != testId) {
             debugPrint('⚠️ Account issue or config error. Retrying with Test Ad Unit ID...');
             _bannerAdUnitId = testId;
             onRetryWithTestId();
          }
        },
        onAdOpened: (Ad ad) => debugPrint('Ad opened.'),
        onAdClosed: (Ad ad) => debugPrint('Ad closed.'),
      ),
    );
  }
}
