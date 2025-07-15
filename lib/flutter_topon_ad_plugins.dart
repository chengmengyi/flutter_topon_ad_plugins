import 'package:anythink_sdk/at_init.dart';
import 'package:anythink_sdk/at_interstitial.dart';
import 'package:anythink_sdk/at_interstitial_response.dart';
import 'package:anythink_sdk/at_listener.dart';
import 'package:anythink_sdk/at_rewarded.dart';
import 'package:anythink_sdk/at_rewarded_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_topon_ad_plugins/callback/topon_ad_callback.dart';
import 'package:flutter_topon_ad_plugins/callback/topon_load_ad_result_callback.dart';
import 'package:flutter_topon_ad_plugins/data/ad_info_data.dart';
import 'package:flutter_topon_ad_plugins/data/ad_revenue_bean.dart';
import 'package:flutter_topon_ad_plugins/data/config_ad_data.dart';
import 'package:flutter_topon_ad_plugins/data/load_result_data.dart';
import 'package:flutter_topon_ad_plugins/enum/ad_type.dart';
import 'package:flutter_topon_ad_plugins/hep/ad_num_hep.dart';
import 'package:flutter_topon_ad_plugins/hep/hep.dart';
import 'package:flutter_topon_ad_plugins/load/load_topon_ad.dart';

class FlutterToponAdPlugins {
  static final FlutterToponAdPlugins _plugins=FlutterToponAdPlugins();
  static FlutterToponAdPlugins get instance => _plugins;

  LoadToponAd? _oneLoadAd;
  LoadToponAd? _twoLoadAd;
  var _adShowing=false;
  ToponAdCallback? _toponAdCallback;

  initTopon({
    required String topOnAppId,
    required String topOnAppKey,
    required ConfigAdData data,
    required ToponLoadAdResultCallback toponLoadAdResultCallback,
})async{
    ATInitManger.setLogEnabled(logEnabled: kDebugMode);
    await ATInitManger.initAnyThinkSDK(appidStr: topOnAppId, appidkeyStr: topOnAppKey);
    _setTopListener();
    _oneLoadAd=LoadToponAd(oneAd: true,toponLoadAdResultCallback: toponLoadAdResultCallback);
    _twoLoadAd=LoadToponAd(oneAd: false,toponLoadAdResultCallback: toponLoadAdResultCallback);
    updateAdData(data);
  }

  _setTopListener(){
    ATListenerManager.interstitialEventHandler.listen((event) {
      var adUnitId = event.placementID;
      switch (event.interstatus) {
      //广告加载失败
        case InterstitialStatus.interstitialAdFailToLoadAD:
          _oneLoadAd?.loadAdFail(adUnitId);
          _twoLoadAd?.loadAdFail(adUnitId);
          break;
      //广告加载成功
        case InterstitialStatus.interstitialAdDidFinishLoading:
          _oneLoadAd?.loadAdSuccess(_createAdRevenueBean(adUnitId,event.extraMap));
          _twoLoadAd?.loadAdSuccess(_createAdRevenueBean(adUnitId,event.extraMap));
          break;
      //广告展示成功
        case InterstitialStatus.interstitialDidShowSucceed:
          _adShowing=true;
          _deleteAdCache(adUnitId);
          AdNumHep.instance.updateShowNum();
          _toponAdCallback?.showSuccess.call(_createAdRevenueBean(adUnitId,event.extraMap),_getAdInfoBeanById(adUnitId));
          break;
      //广告展示失败
        case InterstitialStatus.interstitialFailedToShow:
          _adShowing=false;
          _deleteAdCache(adUnitId);
          loadAd(_getAdInfoBeanById(adUnitId));
          _toponAdCallback?.showFail.call(_createAdRevenueBean(adUnitId,event.extraMap));
          break;
      //广告被点击
        case InterstitialStatus.interstitialAdDidClick:
          AdNumHep.instance.updateClickNum();
          break;
      //广告被关闭
        case InterstitialStatus.interstitialAdDidClose:
          _adShowing=false;
          loadAd(_getAdInfoBeanById(adUnitId));
          _toponAdCallback?.closeAd.call();
          break;
        default:

          break;
      }
    });
    ATListenerManager.rewardedVideoEventHandler.listen((event) {
      var adUnitId = event.placementID;
      switch (event.rewardStatus) {
      //广告加载失败
        case RewardedStatus.rewardedVideoDidFailToLoad:
          _oneLoadAd?.loadAdFail(adUnitId);
          _twoLoadAd?.loadAdFail(adUnitId);
          break;
      //广告加载成功
        case RewardedStatus.rewardedVideoDidFinishLoading:
          _oneLoadAd?.loadAdSuccess(_createAdRevenueBean(adUnitId,event.extraMap));
          _twoLoadAd?.loadAdSuccess(_createAdRevenueBean(adUnitId,event.extraMap));
          break;
      //广告展示成功
        case RewardedStatus.rewardedVideoDidStartPlaying:
          _adShowing=true;
          _deleteAdCache(adUnitId);
          AdNumHep.instance.updateShowNum();
          _toponAdCallback?.showSuccess.call(_createAdRevenueBean(adUnitId,event.extraMap),_getAdInfoBeanById(adUnitId));
          break;
      //广告展示失败
        case RewardedStatus.rewardedVideoDidFailToPlay:
          _adShowing=false;
          _deleteAdCache(adUnitId);
          loadAd(_getAdInfoBeanById(adUnitId));
          _toponAdCallback?.showFail.call(_createAdRevenueBean(adUnitId,event.extraMap));
          break;
      //广告被点击
        case RewardedStatus.rewardedVideoDidClick:
          AdNumHep.instance.updateClickNum();
          break;
      //广告被关闭
        case RewardedStatus.rewardedVideoDidClose:
          _adShowing=false;
          loadAd(_getAdInfoBeanById(adUnitId));
          _toponAdCallback?.closeAd.call();
          break;
        default:

          break;
      }
    });
  }


  showAd({
    required AdType adType,
    required ToponAdCallback toponAdCallback,
  })async{
    if(_adShowing){
      "flutter ios ad --->ad showing".log();
      toponAdCallback.showFail.call(null);
      return;
    }
    _toponAdCallback=toponAdCallback;
    var resultData = getCacheResultData(adType);
    if(null!=resultData){
      "flutter ios ad --->start show ad --->type:$adType--->${resultData.adBean.toString()}".log();
      var newAdType = resultData.adBean.adType;
      if(newAdType==AdType.reward){
        if(await ATRewardedManager.rewardedVideoReady(placementID: resultData.adBean.adId)==true){
          ATRewardedManager.showRewardedVideo(placementID: resultData.adBean.adId);
        }else{
          "flutter ios ad --->$newAdType not Ready".log();
          _deleteAdCache(resultData.adBean.adId);
          _toponAdCallback?.showFail.call(null);
          loadAd(resultData.adBean);
        }
      }else if(newAdType==AdType.interstitial){
        if(await ATInterstitialManager.hasInterstitialAdReady(placementID: resultData.adBean.adId)==true){
          ATInterstitialManager.showInterstitialAd(placementID: resultData.adBean.adId);
        }else{
          "flutter ios ad --->$newAdType not Ready".log();
          _deleteAdCache(resultData.adBean.adId);
          _toponAdCallback?.showFail.call(null);
          loadAd(resultData.adBean);
        }
      }
    }else{
      loadAdWhenNoCache(adType);
      _toponAdCallback?.showFail.call(null);
    }
  }

  loadAd(AdInfoData? infoData){
    if(null==infoData){
      return;
    }
    _oneLoadAd?.loadAdByType(infoData.adType);
    _twoLoadAd?.loadAdByType(infoData.adType);
  }

  loadAdWhenNoCache(AdType adType){
    _oneLoadAd?.loadAdByType(adType);
    _twoLoadAd?.loadAdByType(adType);
  }

  _deleteAdCache(String id){
    _oneLoadAd?.deleteCache(id);
    _twoLoadAd?.deleteCache(id);
  }

  AdInfoData? _getAdInfoBeanById(String id){
    var adBean = _oneLoadAd?.getAdInfoBeanById(id);
    adBean ??= _twoLoadAd?.getAdInfoBeanById(id);
    return adBean;
  }

  LoadResultData? getCacheResultData(AdType adType){
    var oneResult = _oneLoadAd?.getCacheAd(adType);
    if(null!=oneResult){
      return oneResult;
    }
    var twoResult = _twoLoadAd?.getCacheAd(adType);
    if(null!=twoResult){
      return twoResult;
    }
    return null;
  }


  AdRevenueBean? _createAdRevenueBean(String adUnitId, Map extraMap,){
    try{
      return AdRevenueBean(
        revenue: extraMap["publisher_revenue"],
        adUnitId: adUnitId,
        networkName: extraMap["network_name"],
        revenuePrecision: extraMap["precision"],
      );
    }catch(e){
      return null;
    }
  }


  updateAdData(ConfigAdData data){
    _oneLoadAd?.updateAdList(data.oneRewardList, data.oneInterList);
    _twoLoadAd?.updateAdList(data.twoRewardList, data.twoInterList);
  }

  bool adShowing()=>_adShowing;
}
