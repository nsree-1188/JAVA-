import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../utils/helpers.dart';
import '../../utils/app_colors.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  OrderModel? order;
  bool isLoading = true;
  String returnStatus = 'none'; // none, requested, approved, rejected

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    try {
      final fetchedOrder = await ApiService.getOrderById(widget.orderId);
      setState(() {
        order = fetchedOrder;
        isLoading = false;
        // Mock return status - in real app, this would come from API
        returnStatus = _getMockReturnStatus(order!.status);
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        Helpers.showSnackBar(context, 'Error loading order: $e', isError: true);
      }
    }
  }

  String _getMockReturnStatus(String orderStatus) {
    if (orderStatus == 'delivered') return 'none';
    if (orderStatus == 'cancelled') return 'approved';
    return 'none';
  }

  Color _getReturnStatusColor(String status) {
    switch (status) {
      case 'requested':
        return AppColors.warningColor;
      case 'approved':
        return AppColors.successColor;
      case 'rejected':
        return AppColors.errorColor;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryBrown,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBrown),
        ),
      )
          : order == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.primaryBrown.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Order not found',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.primaryBrown,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header Card
            Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${order!.id}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBrown,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                Helpers.formatDateTime(order!.createdAt),
                                style: TextStyle(
                                  color: AppColors.primaryBrown.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Helpers.getStatusColor(order!.status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order!.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            if (returnStatus != 'none') ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getReturnStatusColor(returnStatus),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Return: ${returnStatus.toUpperCase()}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(
                      Icons.person,
                      'Customer',
                      order!.customerName,
                    ),
                    _buildDetailRow(
                      Icons.payment,
                      'Payment Status',
                      order!.paymentStatus,
                    ),
                    _buildDetailRow(
                      Icons.attach_money,
                      'Total Amount',
                      Helpers.formatCurrency(order!.totalAmount),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Order Items Card
            Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_cart,
                          color: AppColors.primaryBrown,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Order Items (${order!.items.length})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBrown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order!.items.length,
                      separatorBuilder: (context, index) => Divider(
                        color: AppColors.primaryBrown.withOpacity(0.2),
                        height: 20,
                      ),
                      itemBuilder: (context, index) {
                        final item = order!.items[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundBeige.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBrown.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.inventory,
                                  color: AppColors.primaryBrown,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.primaryBrown,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Qty: ${item.quantity}',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                Helpers.formatCurrency(item.price * item.quantity),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBrown,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Shipping Address Card
            Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          color: AppColors.primaryBrown,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Shipping Address',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBrown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundBeige.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order!.shippingAddress,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryBrown,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primaryBrown.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBrown,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
