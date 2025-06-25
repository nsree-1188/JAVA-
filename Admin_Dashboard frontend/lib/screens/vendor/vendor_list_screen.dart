import 'package:flutter/material.dart';
import '../../models/vendor_model.dart';
import '../../services/api_service.dart';
import '../../utils/helpers.dart';
import '../../utils/app_colors.dart';
import 'all_vendor_details_screen.dart';

class VendorListScreen extends StatefulWidget {
  const VendorListScreen({super.key});

  @override
  State<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  List<VendorModel> vendors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    try {
      final fetchedVendors = await ApiService.getVendors();
      setState(() {
        vendors = fetchedVendors;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        Helpers.showSnackBar(context, 'Error loading vendors: $e', isError: true);
      }
    }
  }

  Future<void> _updateVendorStatus(String vendorId, String status) async {
    try {
      Helpers.showLoadingDialog(context);
      final success = await ApiService.updateVendorStatus(vendorId, status);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        if (success) {
          Helpers.showSnackBar(context, 'Vendor status updated successfully');
          _loadVendors(); // Refresh the list
        } else {
          Helpers.showSnackBar(context, 'Failed to update vendor status', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        Helpers.showSnackBar(context, 'Error updating vendor status: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllVendorDetailsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list, color: Colors.white),
                  label: const Text(
                    'All Vendors',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightBrown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBrown),
                ),
              )
                  : vendors.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.store_outlined,
                      size: 80,
                      color: AppColors.primaryBrown.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No vendors found',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.primaryBrown,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                onRefresh: _loadVendors,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vendors.length,
                  itemBuilder: (context, index) {
                    final vendor = vendors[index];
                    return _buildVendorCard(vendor);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorCard(VendorModel vendor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBrown.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBrown,
                  AppColors.lightBrown,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBrown.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                vendor.name.isNotEmpty ? vendor.name[0].toUpperCase() : 'V',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text(
            vendor.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBrown,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vendor.email,
                style: TextStyle(
                  color: AppColors.primaryBrown.withOpacity(0.8),
                ),
              ),
              Text(
                vendor.phone,
                style: TextStyle(
                  color: AppColors.primaryBrown.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Helpers.getStatusColor(vendor.status),
                      Helpers.getStatusColor(vendor.status).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Helpers.getStatusColor(vendor.status).withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  vendor.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          trailing: vendor.status == 'pending'
              ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.successColor,
                      AppColors.successColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.check, color: Colors.white),
                  onPressed: () => _updateVendorStatus(vendor.id, 'approved'),
                  tooltip: 'Accept',
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.errorColor,
                      AppColors.errorColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.block, color: Colors.white),
                  onPressed: () => _updateVendorStatus(vendor.id, 'blocked'),
                  tooltip: 'Block',
                ),
              ),
            ],
          )
              : Text(
            Helpers.formatDate(vendor.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primaryBrown.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }
}
