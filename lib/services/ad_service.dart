import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // App ID: ca-app-pub-3408903389045590~8291321195

  // Production Ad IDs
  static const String _bannerAdId = 'ca-app-pub-3408903389045590/6978239523';
  static const String _interstitialAdId = 'ca-app-pub-3408903389045590/4160504492';
  static const String _appOpenAdId = 'ca-app-pub-3408903389045590/5514002665';
  static const String _nativeAdvancedAdId = 'ca-app-pub-3408903389045590/2464279442';
  static const String _rewardedAdId = 'ca-app-pub-3408903389045590/1606547247';

  static BannerAd? _bannerAd;
  static InterstitialAd? _interstitialAd;
  static AppOpenAd? _appOpenAd;
  static NativeAd? _nativeAd;
  static RewardedAd? _rewardedAd;
  static bool _isShowingAd = false;

  // App-open ad cooldown (show only once every 4 hours)
  static DateTime? _lastAppOpenAdTime;
  static const Duration _appOpenAdCooldown = Duration(hours: 4);

  static Future<void> initialize() async {
    print('AdService: Initializing Mobile Ads...');
    try {
      final InitializationStatus status = await MobileAds.instance.initialize();
      print('AdService: Mobile Ads initialized successfully');
      print('AdService: Adapter statuses: ${status.adapterStatuses}');
    } catch (e) {
      print('AdService: Failed to initialize Mobile Ads: $e');
    }
  }

  // Banner Ad Methods
  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: _bannerAdId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('AdService: Banner ad loaded successfully');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('AdService: Banner ad failed to load: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('AdService: Banner ad opened'),
        onAdClosed: (Ad ad) => print('AdService: Banner ad closed'),
      ),
    );
  }

  // Interstitial Ad Methods
  static void loadInterstitialAd() {
    print('AdService: Loading interstitial ad with ID: $_interstitialAdId');
    InterstitialAd.load(
      adUnitId: _interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('AdService: Interstitial ad loaded successfully');
          _interstitialAd = ad;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('AdService: Interstitial ad failed to load: $error');
          print(
            'AdService: Error code: ${error.code}, Message: ${error.message}',
          );
          _interstitialAd = null;
        },
      ),
    );
  }

  static void showInterstitialAd({VoidCallback? onAdClosed}) {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      onAdClosed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        _isShowingAd = true;
        print('Interstitial ad showed full screen content.');
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        _isShowingAd = false;
        print('Interstitial ad dismissed full screen content.');
        ad.dispose();
        _interstitialAd = null;
        onAdClosed?.call();
        loadInterstitialAd(); // Load next ad
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        _isShowingAd = false;
        print('Interstitial ad failed to show full screen content: $error');
        ad.dispose();
        _interstitialAd = null;
        onAdClosed?.call();
      },
    );

    _interstitialAd!.show();
  }

  // App Open Ad Methods
  static void loadAppOpenAd() {
    print('AdService: Loading app open ad with ID: $_appOpenAdId');
    AppOpenAd.load(
      adUnitId: _appOpenAdId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          print('AdService: App open ad loaded successfully');
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('AdService: App open ad failed to load: $error');
          print(
            'AdService: Error code: ${error.code}, Message: ${error.message}',
          );
          _appOpenAd = null;
        },
      ),
    );
  }

  static void showAppOpenAd({VoidCallback? onAdClosed}) {
    // Check cooldown - only show app-open ad once every 4 hours
    if (_lastAppOpenAdTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAppOpenAdTime!);
      if (timeSinceLastAd < _appOpenAdCooldown) {
        print('App open ad on cooldown. Time remaining: ${_appOpenAdCooldown - timeSinceLastAd}');
        onAdClosed?.call();
        return;
      }
    }

    if (_appOpenAd == null) {
      print('Warning: attempt to show app open ad before loaded.');
      onAdClosed?.call();
      return;
    }

    if (_isShowingAd) {
      print('App open ad is already being shown.');
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (AppOpenAd ad) {
        _isShowingAd = true;
        _lastAppOpenAdTime = DateTime.now(); // Update last shown time
        print('App open ad showed full screen content.');
      },
      onAdDismissedFullScreenContent: (AppOpenAd ad) {
        _isShowingAd = false;
        print('App open ad dismissed full screen content.');
        ad.dispose();
        _appOpenAd = null;
        onAdClosed?.call();
        loadAppOpenAd(); // Load next ad
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
        _isShowingAd = false;
        print('App open ad failed to show full screen content: $error');
        ad.dispose();
        _appOpenAd = null;
        onAdClosed?.call();
      },
    );

    _appOpenAd!.show();
  }

  // Native Advanced Ad Methods
  static void loadNativeAd({required Function(NativeAd) onAdLoaded}) {
    print('AdService: Loading native ad with ID: $_nativeAdvancedAdId');
    NativeAd(
      adUnitId: _nativeAdvancedAdId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          print('AdService: Native ad loaded successfully');
          _nativeAd = ad as NativeAd;
          onAdLoaded(_nativeAd!);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('AdService: Native ad failed to load: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('AdService: Native ad opened'),
        onAdClosed: (Ad ad) => print('AdService: Native ad closed'),
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: const Color(0xFFFAF7F2),
        cornerRadius: 12.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: const Color(0xFF8D4E27),
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF3C2415),
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF8D6E47),
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
      ),
    ).load();
  }

  // Rewarded Ad Methods
  static void loadRewardedAd() {
    print('AdService: Loading rewarded ad with ID: $_rewardedAdId');
    RewardedAd.load(
      adUnitId: _rewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print('AdService: Rewarded ad loaded successfully');
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('AdService: Rewarded ad failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  static void showRewardedAd({
    required OnUserEarnedRewardCallback onUserEarnedReward,
    VoidCallback? onAdClosed,
  }) {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded ad before loaded.');
      onAdClosed?.call();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        _isShowingAd = true;
        print('Rewarded ad showed full screen content.');
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        _isShowingAd = false;
        print('Rewarded ad dismissed full screen content.');
        ad.dispose();
        _rewardedAd = null;
        onAdClosed?.call();
        loadRewardedAd(); // Load next ad
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        _isShowingAd = false;
        print('Rewarded ad failed to show full screen content: $error');
        ad.dispose();
        _rewardedAd = null;
        onAdClosed?.call();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: onUserEarnedReward);
  }

  static void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _appOpenAd?.dispose();
    _nativeAd?.dispose();
    _rewardedAd?.dispose();
  }

  // Utility methods
  static bool get isRewardedAdReady => _rewardedAd != null;
  static bool get isInterstitialAdReady => _interstitialAd != null;

  static bool get isShowingAd => _isShowingAd;
}
