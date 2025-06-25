class DashboardStats {
  final int totalUsers;
  final int totalVendors;
  final int totalProducts;
  final int totalOrders;
  final double totalRevenue;
  final int pendingOrders;
  final int pendingVendors;
  final int activeReports;

  DashboardStats({
    required this.totalUsers,
    required this.totalVendors,
    required this.totalProducts,
    required this.totalOrders,
    required this.totalRevenue,
    required this.pendingOrders,
    required this.pendingVendors,
    required this.activeReports,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalVendors: json['totalVendors'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      pendingOrders: json['pendingOrders'] ?? 0,
      pendingVendors: json['pendingVendors'] ?? 0,
      activeReports: json['activeReports'] ?? 0,
    );
  }
}
