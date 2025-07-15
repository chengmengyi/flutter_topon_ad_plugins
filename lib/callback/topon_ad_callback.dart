
import 'package:flutter_topon_ad_plugins/data/ad_info_data.dart';
import 'package:flutter_topon_ad_plugins/data/ad_revenue_bean.dart';

class ToponAdCallback{
  Function(AdRevenueBean? ad,AdInfoData? bean) showSuccess;
  Function(AdRevenueBean? ad) showFail;
  Function() closeAd;
  Function(AdRevenueBean? ad,AdInfoData? bean) onAdRevenuePaidCallback;

  ToponAdCallback({
    required this.showSuccess,
    required this.showFail,
    required this.closeAd,
    required this.onAdRevenuePaidCallback,
  });
}