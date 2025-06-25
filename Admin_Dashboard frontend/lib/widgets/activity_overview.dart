import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../models/dashboard_stats.dart';

class ActivityOverview extends StatefulWidget {
  const ActivityOverview({super.key});

  @override
  State<ActivityOverview> createState() => _ActivityOverviewState();
}

class _ActivityOverviewState extends State<ActivityOverview> {
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
            children: [
              Icon(
                Icons.analytics,
                color: AppColors.primaryBrown,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Activity Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBrown),
                ),
              ),
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildActivityCard(
                        icon: Icons.people,
                        title: 'Users',
                        value: '${stats?.totalUsers ?? 0}',
                        color: AppColors.infoColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActivityCard(
                        icon: Icons.store,
                        title: 'Vendors',
                        value: '${stats?.totalVendors ?? 0}',
                        color: AppColors.chartPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActivityCard(
                        icon: Icons.inventory,
                        title: 'Products',
                        value: '${stats?.totalProducts ?? 0}',
                        color: AppColors.successColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActivityCard(
                        icon: Icons.report,
                        title: 'Reports',
                        value: '${stats?.activeReports ?? 0}',
                        color: AppColors.warningColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
