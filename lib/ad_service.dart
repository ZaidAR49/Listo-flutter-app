import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Test Ad Unit ID for Banner
  // Test Ad Unit ID for Banner
  String _bannerAdUnitId = Platform.isAndroid
      ? (dotenv.env['ANDROID_BANNER_AD_UNIT_ID'] ?? 'ca-app-pub-3940256099942544/6300978111')
      : (dotenv.env['IOS_BANNER_AD_UNIT_ID'] ?? 'ca-app-pub-3940256099942544/2934735716');

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
          print('✅ Ad loaded.');
          onAdLoaded();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('❌ Ad failed to load: $error');
          ad.dispose();

          final String testId = Platform.isAndroid 
              ? 'ca-app-pub-3940256099942544/6300978111' 
              : 'ca-app-pub-3940256099942544/2934735716';

          if (_bannerAdUnitId != testId) {
             print('⚠️ Account issue or config error. Retrying with Test Ad Unit ID...');
             _bannerAdUnitId = testId;
             onRetryWithTestId();
          }
        },
        onAdOpened: (Ad ad) => print('Ad opened.'),
        onAdClosed: (Ad ad) => print('Ad closed.'),
      ),
    );
  }
}
