import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Ad Unit IDs
  static const String _appOpenAdUnitId = 'ca-app-pub-3408903389045590/5514002665';
  static const String _bannerAdUnitId = 'ca-app-pub-3408903389045590/6978239523';
  static const String _interstitialAdUnitId = 'ca-app-pub-3408903389045590/4160504492';
  static const String _nativeAdUnitId = 'ca-app-pub-3408903389045590/2464279442';
  static const String _rewardedAdUnitId = 'ca-app-pub-3408903389045590/1606547247';

  // Interstitial ad tracking
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  int _interstitialAdCounter = 0;

  // Rewarded ad tracking
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;
  int _storiesOpenedCounter = 0; // Track how many stories have been opened

  // App Open Ad
  AppOpenAd? _appOpenAd;
  bool _isAppOpenAdReady = false;

  /// Initialize the AdMob SDK
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// Create a Banner Ad
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner ad loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    );
  }

  /// Load Interstitial Ad
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // Load next ad
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  /// Show Interstitial Ad (frequent - every 2 actions)
  void showInterstitialAd() {
    _interstitialAdCounter++;

    // Show ad every 2 actions for more frequent ads
    if (_interstitialAdCounter >= 2) {
      if (_isInterstitialAdReady && _interstitialAd != null) {
        _interstitialAd!.show();
        _interstitialAdCounter = 0;
      } else {
        loadInterstitialAd();
      }
    }
  }

  /// Load Rewarded Ad
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd(); // Load next ad
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  /// Track story opens and show rewarded ad after 3 stories
  void trackStoryOpen() {
    _storiesOpenedCounter++;

    // Show rewarded ad after every 3 stories opened
    if (_storiesOpenedCounter >= 3) {
      _storiesOpenedCounter = 0;
      showRewardedAd();
    }
  }

  /// Show Rewarded Ad automatically (no dialog)
  void showRewardedAd({VoidCallback? onAdWatched}) {
    if (_isRewardedAdReady && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onAdWatched?.call();
        },
      );
    } else {
      // If ad not ready, just call the callback
      onAdWatched?.call();
      loadRewardedAd();
    }
  }

  /// Load App Open Ad
  void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: _appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isAppOpenAdReady = false;
              loadAppOpenAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isAppOpenAdReady = false;
              loadAppOpenAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('App open ad failed to load: $error');
          _isAppOpenAdReady = false;
        },
      ),
    );
  }

  /// Show App Open Ad
  void showAppOpenAd() {
    if (_isAppOpenAdReady && _appOpenAd != null) {
      _appOpenAd!.show();
    }
  }

  /// Dispose all ads
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
  }
}
