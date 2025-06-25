import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'stats_cards.dart';
import 'recent_products.dart';
import 'activity_overview.dart';

class DashboardContent extends StatelessWidget {
  final String selectedMenu;

  const DashboardContent({
    super.key,
    required this.selectedMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.lightBrown.withOpacity(0.1),
                    AppColors.backgroundBeige,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard Overview',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBrown,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back! Here\'s what\'s happening with your store today.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats Cards
            const StatsCards(),
            const SizedBox(height: 20),

            // Recent Products
            const RecentProductsDashboard(),
            const SizedBox(height: 20),

            // Activity Overview
            const ActivityOverview(),
          ],
        ),
      ),
    );
  }
}
