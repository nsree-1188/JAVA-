import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/helpers.dart';
import 'edit_product_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final bool isAdminProduct;

  const ProductDetailsScreen({
    Key? key,
    required this.productId,
    this.isAdminProduct = false,
  }) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  ProductModel? product;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      print('=== LOADING PRODUCT DETAILS ===');
      print('Product ID: ${widget.productId}');
      print('Is Admin Product: ${widget.isAdminProduct}');

      if (widget.productId.isEmpty) {
        throw Exception('Product ID is empty');
      }

      final fetchedProduct = await ApiService.getProductById(
        widget.productId,
        isAdminProduct: widget.isAdminProduct,
      );

      print('Product fetched successfully: ${fetchedProduct.name}');
      print('Product details: ${fetchedProduct.toJson()}');

      if (mounted) {
        setState(() {
          product = fetchedProduct;
          isLoading = false;
          errorMessage = null;
        });
      }
    } catch (e) {
      print('Error loading product: $e');
      if (mounted) {
        setState(() {
          product = null;
          isLoading = false;
          errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _deleteProduct() async {
    if (product == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Product',
          style: TextStyle(
            color: AppColors.primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${product!.name}"?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await ApiService.deleteProduct(
          product!.id,
          isAdminProduct: widget.isAdminProduct,
        );

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Product deleted successfully'),
                backgroundColor: AppColors.successColor,
              ),
            );
            Navigator.pop(context, true); // Return true to indicate deletion
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Failed to delete product'),
                backgroundColor: AppColors.errorColor,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting product: $e'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _editProduct() async {
    if (product == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(
          product: product!,
          isAdminProduct: widget.isAdminProduct,
        ),
      ),
    );

    if (result == true) {
      // Refresh product details after edit
      _loadProduct();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: Text(
          widget.isAdminProduct ? 'Admin Product Details' : 'Vendor Product Details',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryBrown,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (product != null && widget.isAdminProduct) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _editProduct,
              tooltip: 'Edit Product',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _deleteProduct,
              tooltip: 'Delete Product',
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBrown),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading product details...',
              style: TextStyle(
                color: AppColors.primaryBrown,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.errorColor.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Product',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBrown,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.errorColor,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBrown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (product == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppColors.primaryBrown.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Product not found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBrown,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Card
          Card(
            elevation: 4,
            color: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Header
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBrown.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.inventory,
                          color: AppColors.primaryBrown,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product!.name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBrown,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: widget.isAdminProduct
                                    ? AppColors.primaryBrown
                                    : AppColors.infoColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.isAdminProduct ? 'Admin Product' : 'Vendor Product',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Price and Stock Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Price',
                          Helpers.formatCurrency(product!.price),
                          Icons.attach_money,
                          AppColors.successColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard(
                          'Stock',
                          '${product!.stock} units',
                          Icons.inventory,
                          product!.stock > 0 ? AppColors.successColor : AppColors.errorColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Category and Vendor
                  _buildDetailSection('Category', product!.category),
                  if (product!.size != null && product!.size!.isNotEmpty)
                    _buildDetailSection('Size', product!.size!),
                  _buildDetailSection('Vendor', product!.vendorName),
                  _buildDetailSection('Description', product!.description),
                  _buildDetailSection('Added', Helpers.formatDate(product!.createdAt)),
                ],
              ),
            ),
          ),

          // Action Buttons (only for admin products)
          if (widget.isAdminProduct) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _editProduct,
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      'Edit Product',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warningColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _deleteProduct,
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text(
                      'Delete Product',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.infoColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.infoColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This is a vendor product. You can view details but cannot edit or delete it.',
                      style: TextStyle(
                        color: AppColors.infoColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
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
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundBeige.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBrown.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryBrown,
            ),
          ),
        ],
      ),
    );
  }
}
