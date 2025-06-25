import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/helpers.dart';
import '../../widgets/network_image_widget.dart';
import 'add_product_screen.dart';
import 'product_details_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ProductModel> adminProducts = [];
  List<ProductModel> vendorProducts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      print('=== LOADING ALL PRODUCTS ===');

      // Load admin and vendor products separately
      final adminProductsFuture = ApiService.getAdminProducts();
      final vendorProductsFuture = ApiService.getVendorProducts();

      final results = await Future.wait([
        adminProductsFuture,
        vendorProductsFuture,
      ]);

      final fetchedAdminProducts = results[0];
      final fetchedVendorProducts = results[1];

      print('Admin products loaded: ${fetchedAdminProducts.length}');
      print('Vendor products loaded: ${fetchedVendorProducts.length}');

      // Debug: Print image URLs
      /*print('=== ADMIN PRODUCT IMAGE URLs ===');
      for (var product in fetchedAdminProducts) {
        print('Product: ${product.name}');
        print('Images: ${product.images}');
        if (product.images.isNotEmpty) {
          print('First image URL: ${product.images.first}');
        }
      }*/

      if (mounted) {
        setState(() {
          adminProducts = fetchedAdminProducts;
          vendorProducts = fetchedVendorProducts;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading products: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _navigateToAddProduct() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductScreen(),
      ),
    );

    if (result == true) {
      _loadProducts(); // Refresh the list
    }
  }

  Future<void> _navigateToProductDetails(ProductModel product, bool isAdminProduct) async {
    print('=== NAVIGATING TO PRODUCT DETAILS ===');
    print('Product: ${product.name}');
    print('Product ID: "${product.id}"');
    print('Is Admin Product: $isAdminProduct');

    // Validate product ID before navigation
    if (product.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error: Product ID is missing'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    try {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(
            productId: product.id,
            isAdminProduct: isAdminProduct,
          ),
        ),
      );

      if (result == true) {
        _loadProducts(); // Refresh the list if product was deleted
      }
    } catch (e) {
      print('Error navigating to product details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening product details: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text(
          'Product Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryBrown,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadProducts,
            tooltip: 'Refresh Products',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: AppColors.primaryBrown,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.admin_panel_settings, size: 18),
                      const SizedBox(width: 8),
                      Text('Admin (${adminProducts.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.store, size: 18),
                      const SizedBox(width: 8),
                      Text('Vendor (${vendorProducts.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductList(adminProducts, true),
                _buildProductList(vendorProducts, false),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddProduct,
        backgroundColor: AppColors.primaryBrown,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Product',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProductList(List<ProductModel> products, bool isAdminProducts) {
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
              'Loading products...',
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
              'Error Loading Products',
              style: TextStyle(
                fontSize: 18,
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
              onPressed: _loadProducts,
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

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAdminProducts ? Icons.admin_panel_settings : Icons.store,
              size: 80,
              color: AppColors.primaryBrown.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isAdminProducts
                  ? 'No admin products found'
                  : 'No vendor products found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBrown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAdminProducts
                  ? 'Click the + button to add your first admin product'
                  : 'Vendor products will appear here when vendors add them',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: AppColors.primaryBrown,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(product, isAdminProducts);
        },
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, bool isAdminProduct) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 3,
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => _navigateToProductDetails(product, isAdminProduct),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Image
                Row(
                  children: [
                    // Product Image or Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isAdminProduct
                            ? AppColors.primaryBrown.withOpacity(0.1)
                            : AppColors.infoColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buildProductImage(product, isAdminProduct),
                    ),

                    const SizedBox(width: 16),

                    // Product Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBrown,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isAdminProduct
                                      ? AppColors.primaryBrown.withOpacity(0.1)
                                      : AppColors.infoColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isAdminProduct ? AppColors.primaryBrown : AppColors.infoColor,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  isAdminProduct ? 'ADMIN' : 'VENDOR',
                                  style: TextStyle(
                                    color: isAdminProduct ? AppColors.primaryBrown : AppColors.infoColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Store: ${product.vendorName}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.category,
                            style: TextStyle(
                              color: AppColors.lightBrown,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (product.size != null && product.size!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.straighten,
                                  size: 12,
                                  color: AppColors.primaryBrown,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Size: ${product.size}',
                                  style: TextStyle(
                                    color: AppColors.primaryBrown,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],

                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  product.description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Price and Stock Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBrown,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        Helpers.formatCurrency(product.price),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: product.stock > 0
                            ? AppColors.successColor.withOpacity(0.1)
                            : AppColors.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: product.stock > 0
                              ? AppColors.successColor
                              : AppColors.errorColor,
                        ),
                      ),
                      child: Text(
                        'Stock: ${product.stock}',
                        style: TextStyle(
                          color: product.stock > 0
                              ? AppColors.successColor
                              : AppColors.errorColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(ProductModel product, bool isAdminProduct) {
    if (product.images.isEmpty) {
      return Icon(
        isAdminProduct ? Icons.admin_panel_settings : Icons.store,
        color: isAdminProduct ? AppColors.primaryBrown : AppColors.infoColor,
        size: 32,
      );
    }

    final imageUrl = product.images.first;
    print('🖼️ Building image widget for: $imageUrl');

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: NetworkImageWidget(
        imageUrl: imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorWidget: Container(
          color: AppColors.errorColor.withOpacity(0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image,
                color: AppColors.errorColor,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                'Failed',
                style: TextStyle(
                  color: AppColors.errorColor,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
        placeholder: Container(
          color: AppColors.backgroundBeige.withOpacity(0.3),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isAdminProduct ? AppColors.primaryBrown : AppColors.infoColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
