import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../models/dashboard_stats.dart';

class StatsCards extends StatefulWidget {
  const StatsCards({super.key});

  @override
  State<StatsCards> createState() => _StatsCardsState();
}

class _StatsCardsState extends State<StatsCards> {
  DashboardStats? stats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final fetchedStats = await ApiService.getDashboardStats();
      setState(() {
        stats = fetchedStats;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBrown),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatsCard(
                title: 'Orders',
                value: '${stats?.totalOrders ?? 0}',
                subtitle: 'Total orders placed',
                icon: Icons.shopping_cart,
                color: AppColors.infoColor,
                isPositive: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatsCard(
                title: 'Sales',
                value: '\₹${stats?.totalRevenue.toStringAsFixed(0) ?? '0'}',
                subtitle: 'Total revenue',
                icon: Icons.trending_up,
                color: AppColors.successColor,
                isPositive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatsCard(
                title: 'Delivered',
                value: '${(stats?.totalOrders ?? 0) - (stats?.pendingOrders ?? 0)}',
                subtitle: 'Successfully delivered',
                icon: Icons.local_shipping,
                color: AppColors.chartGreen,
                isPositive: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatsCard(
                title: 'Pending',
                value: '${stats?.pendingOrders ?? 0}',
                subtitle: 'Awaiting processing',
                icon: Icons.pending,
                color: AppColors.warningColor,
                isPositive: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? AppColors.successColor : AppColors.errorColor,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
