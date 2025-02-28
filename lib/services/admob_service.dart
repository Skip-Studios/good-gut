import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobService {
  // Singleton pattern
  static final AdmobService _instance = AdmobService._internal();
  factory AdmobService() => _instance;
  AdmobService._internal();

  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/9214589741'
      : 'ca-app-pub-3940256099942544/2435281174';

  BannerAd? bannerAd;
  bool isLoaded = false;

  // Listener callbacks to notify when ad loads
  final List<Function(bool)> _listeners = [];

  void addListener(Function(bool) listener) {
    _listeners.add(listener);
  }

  void removeListener(Function(bool) listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener(isLoaded);
    }
  }

  /// Loads a banner ad.
  void loadAd(int width) async {
    if (bannerAd != null) return; // Prevent reloading

    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final adSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (adSize == null) return;

    bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: adSize,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          print('$ad loaded.');
          isLoaded = true;
          _notifyListeners();
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          print('BannerAd failed to load: $err');
          isLoaded = false;
          _notifyListeners();
          // Dispose the ad here to free resources.
          ad.dispose();
          bannerAd = null;
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {},
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {},
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) {},
      ),
    )..load();
  }

  void dispose() {
    bannerAd?.dispose();
    bannerAd = null;
    isLoaded = false;
    _listeners.clear();
  }
}
