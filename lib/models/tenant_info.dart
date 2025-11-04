class TenantInfo {
  String id;
  DateTime subscriptionEndDate;
  TenantSubscription subscriptionType;

  TenantInfo({
    required this.id,
    required this.subscriptionEndDate,
    required this.subscriptionType,
  });

  factory TenantInfo.fromJson(Map<String, dynamic> json) {
    return TenantInfo(
      id: json['id'],
      subscriptionEndDate: DateTime.parse(json['subscriptionEndDate']),
      subscriptionType: json['subscriptionType'] == 'Premium'
          ? TenantSubscription.premium
          : TenantSubscription.free,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscriptionEndDate': subscriptionEndDate.toIso8601String(),
      'subscriptionType': subscriptionType == TenantSubscription.premium
          ? 'Premium'
          : 'Free',
    };
  }
}

enum TenantSubscription { free, premium }
