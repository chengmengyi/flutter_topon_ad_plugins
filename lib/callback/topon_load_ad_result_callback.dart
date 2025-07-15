

import 'package:flutter_topon_ad_plugins/data/ad_info_data.dart';
import 'package:flutter_topon_ad_plugins/data/ad_revenue_bean.dart';

class ToponLoadAdResultCallback{
  Function(AdInfoData? bean) startLoadAdCallback;
  Function(AdRevenueBean? ad,AdInfoData? bean) loadAdSuccessCallback;
  Function(AdInfoData? bean) loadAdFailCallback;

  ToponLoadAdResultCallback({
    required this.startLoadAdCallback,
    required this.loadAdSuccessCallback,
    required this.loadAdFailCallback,
  });
}