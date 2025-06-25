import 'package:flutter/material.dart';
import '../../models/report_model.dart';
import '../../services/api_service.dart';
import '../../utils/helpers.dart';
import '../../utils/app_colors.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<ReportModel> reports = [];
  List<ReportModel> filteredReports = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReports();
    _searchController.addListener(_filterReports);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    try {
      final fetchedReports = await ApiService.getReports();
      setState(() {
        reports = fetchedReports;
        filteredReports = fetchedReports;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        Helpers.showSnackBar(context, 'Error loading reports: $e', isError: true);
      }
    }
  }

  void _filterReports() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredReports = reports.where((report) {
        return report.userName.toLowerCase().contains(query) ||
            report.message.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,

      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search reports by user or message...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Reports List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredReports.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.report_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isEmpty
                        ? 'No reports found'
                        : 'No reports match your search',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadReports,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredReports.length,
                itemBuilder: (context, index) {
                  final report = filteredReports[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: Helpers.getStatusColor(report.status),
                        child: Icon(
                          report.status == 'pending'
                              ? Icons.pending
                              : Icons.check_circle,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        report.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Helpers.getStatusColor(report.status),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  report.status.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                Helpers.formatDate(report.createdAt),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Full Message:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                report.message,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: report.status == 'resolved'
                                          ? null
                                          : () {
                                        Helpers.showSnackBar(context, 'Response sent successfully');
                                      },
                                      icon: const Icon(Icons.reply),
                                      label: const Text('Respond'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryBrown,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: report.status == 'resolved'
                                          ? null
                                          : () {
                                        Helpers.showSnackBar(context, 'Report marked as resolved');
                                        _loadReports();
                                      },
                                      icon: const Icon(Icons.check),
                                      label: const Text('Mark Resolved'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.successColor,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
