class AdRevenueBean{
  double revenue;
  String networkName;
  String adUnitId;
  String revenuePrecision;
  AdRevenueBean({
    required this.revenue,
    required this.adUnitId,
    required this.networkName,
    required this.revenuePrecision,
  });

  @override
  String toString() {
    return 'AdRevenueBean{revenue: $revenue, networkName: $networkName, adUnitId: $adUnitId, revenuePrecision: $revenuePrecision}';
  }
}