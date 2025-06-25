import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../../utils/helpers.dart';
import '../../utils/app_colors.dart';
import '../../widgets/network_image_widget.dart';
import '../../services/size_service.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;
  final bool isAdminProduct;

  const EditProductScreen({
    super.key,
    required this.product,
    this.isAdminProduct = true,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _vendorNameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _sizeController = TextEditingController();

  String? _selectedCategory;

  bool _isLoading = false;
  List<String> _existingImages = [];
  List<File> _newImageFiles = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  void _loadProductData() {
    print('=== LOADING PRODUCT DATA FOR EDITING ===');
    print('Product ID: "${widget.product.id}"');
    print('Product Name: ${widget.product.name}');
    print('Product Images: ${widget.product.images}');
    print('Is Admin Product: ${widget.isAdminProduct}');

    _nameController.text = widget.product.name;
    _descriptionController.text = widget.product.description;
    _priceController.text = widget.product.price.toString();
    _stockController.text = widget.product.stock.toString();
    _vendorNameController.text = widget.product.vendorName;
    _categoryController.text = widget.product.category;
    _selectedCategory = widget.product.category.toLowerCase(); // Add this line
    _sizeController.text = widget.product.size ?? '';

    // Load existing images
    _existingImages = List.from(widget.product.images);
    print('Loaded ${_existingImages.length} existing images');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _vendorNameController.dispose();
    _categoryController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      // Use pickImage multiple times or show a dialog to pick one at a time
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Add Images',
              style: TextStyle(color: AppColors.primaryBrown),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt, color: AppColors.primaryBrown),
                  title: const Text('Take Photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickSingleImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: AppColors.primaryBrown),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickSingleImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('Error showing image picker dialog: $e');
      Helpers.showSnackBar(context, 'Error selecting images: $e', isError: true);
    }
  }

  Future<void> _pickSingleImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _newImageFiles.add(File(pickedFile.path));
        });
        print('Added new image: ${pickedFile.path}');
      }
    } catch (e) {
      print('Error picking image: $e');
      Helpers.showSnackBar(context, 'Error selecting image: $e', isError: true);
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImageFiles.removeAt(index);
    });
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated product with proper field mapping
      final updatedProduct = ProductModel(
        id: widget.product.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        category: _categoryController.text.trim(),
        size: _sizeController.text.trim().isEmpty ? null : _sizeController.text.trim(),
        vendorId: widget.product.vendorId,
        vendorName: _vendorNameController.text.trim(),
        images: [..._existingImages, ..._newImageFiles.map((f) => f.path)], // Combine existing and new
        createdAt: widget.product.createdAt,
        updatedAt: widget.product.updatedAt,
        // Remove status field since it doesn't exist in ProductModel
      );

      print('=== UPDATING PRODUCT ===');
      print('Product ID: "${updatedProduct.id}"');
      print('Product Name: ${updatedProduct.name}');
      print('Price: ${updatedProduct.price}');
      print('Stock: ${updatedProduct.stock}');
      print('Category: ${updatedProduct.category}');
      print('Vendor ID: ${updatedProduct.vendorId}');
      print('Vendor Name: ${updatedProduct.vendorName}');
      print('Existing Images: ${_existingImages.length}');
      print('New Images: ${_newImageFiles.length}');
      print('Is Admin Product: ${widget.isAdminProduct}');

      final success = await ApiService.updateProduct(
        updatedProduct,
        isAdminProduct: widget.isAdminProduct,
        imageFiles: _newImageFiles.isNotEmpty ? _newImageFiles : null,
        existingImages: _existingImages.isNotEmpty ? _existingImages : null,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          Helpers.showSnackBar(context, 'Product updated successfully');
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          Helpers.showSnackBar(context, 'Failed to update product', isError: true);
        }
      }
    } catch (e) {
      print('Error updating product: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Helpers.showSnackBar(context, 'Error updating product: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text(
          'Edit Product',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryBrown,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Debug info button
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Product Debug Info',
                    style: TextStyle(color: AppColors.primaryBrown),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: "${widget.product.id}"'),
                      Text('Length: ${widget.product.id.length}'),
                      Text('Is Admin: ${widget.isAdminProduct}'),
                      Text('Vendor ID: ${widget.product.vendorId}'),
                      Text('Images: ${widget.product.images.length}'),
                      Text('Created: ${widget.product.createdAt}'),
                      Text('Updated: ${widget.product.updatedAt}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Close',
                        style: TextStyle(color: AppColors.primaryBrown),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.info_outline, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Info Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBrown.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryBrown,
                            AppColors.lightBrown,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Product Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBrown,
                            ),
                          ),
                          Text(
                            widget.isAdminProduct ? 'Admin Product' : 'Vendor Product',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Images Section
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBrown.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.image, color: AppColors.primaryBrown),
                          const SizedBox(width: 8),
                          Text(
                            'Product Images',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBrown,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _pickImages,
                            icon: Icon(Icons.add_photo_alternate, color: AppColors.primaryBrown),
                            label: Text(
                              'Add Images',
                              style: TextStyle(color: AppColors.primaryBrown),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Existing Images
                      if (_existingImages.isNotEmpty) ...[
                        Text(
                          'Current Images (${_existingImages.length})',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _existingImages.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.primaryBrown.withOpacity(0.3)),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: NetworkImageWidget(
                                          imageUrl: _existingImages[index],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _removeExistingImage(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColors.errorColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // New Images
                      if (_newImageFiles.isNotEmpty) ...[
                        Text(
                          'New Images (${_newImageFiles.length})',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.successColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _newImageFiles.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.successColor.withOpacity(0.5)),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _newImageFiles[index],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _removeNewImage(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColors.errorColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // No images message
                      if (_existingImages.isEmpty && _newImageFiles.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundBeige.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryBrown.withOpacity(0.2)),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                color: AppColors.textSecondary,
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No images selected',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap "Add Images" to select product photos',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Form Fields
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBrown.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Product Name
                      _buildFormField(
                        controller: _nameController,
                        label: 'Product Name',
                        icon: Icons.inventory,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      _buildFormField(
                        controller: _descriptionController,
                        label: 'Description',
                        icon: Icons.description,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter product description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Price and Stock Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField(
                              controller: _priceController,
                              label: 'Price',
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter price';
                                }
                                if (double.tryParse(value.trim()) == null) {
                                  return 'Please enter valid price';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFormField(
                              controller: _stockController,
                              label: 'Stock',
                              icon: Icons.inventory_2,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter stock';
                                }
                                if (int.tryParse(value.trim()) == null) {
                                  return 'Please enter valid stock';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Category
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.backgroundBeige.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryBrown.withOpacity(0.2),
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Category *',
                            labelStyle: TextStyle(color: AppColors.primaryBrown),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(Icons.category, color: AppColors.primaryBrown),
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'menswear',
                              child: Text('Menswear'),
                            ),
                            DropdownMenuItem(
                              value: 'womenswear',
                              child: Text('Womenswear'),
                            ),
                            DropdownMenuItem(
                              value: 'shoes',
                              child: Text('Shoes'),
                            ),
                            DropdownMenuItem(
                              value: 'cosmetics',
                              child: Text('Cosmetics'),
                            ),
                            DropdownMenuItem(
                              value: 'watch',
                              child: Text('Watch'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                              _categoryController.text = value ?? '';
                              _sizeController.clear(); // Clear size when category changes
                            });
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Size field (conditional)
                      if (_selectedCategory != null && SizeService.isSizeRequired(_selectedCategory!)) ...[
                        _buildSizeField(),
                        const SizedBox(height: 16),
                      ],

                      // Vendor Name
                      _buildFormField(
                        controller: _vendorNameController,
                        label: 'Vendor Name',
                        icon: Icons.store,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter vendor name';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryBrown),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.primaryBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryBrown,
                            AppColors.lightBrown,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBrown.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Updating...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        )
                            : const Text(
                          'Update Product',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundBeige.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBrown.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.primaryBrown),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon, color: AppColors.primaryBrown),
          filled: true,
          fillColor: Colors.transparent,
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildSizeField() {
    final validSizes = SizeService.getValidSizes(_categoryController.text);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundBeige.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBrown.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _sizeController.text.isEmpty ? null : _sizeController.text,
        decoration: InputDecoration(
          labelText: 'Size',
          labelStyle: TextStyle(color: AppColors.primaryBrown),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(Icons.straighten, color: AppColors.primaryBrown),
          filled: true,
          fillColor: Colors.transparent,
        ),
        items: validSizes.map((size) => DropdownMenuItem(
          value: size,
          child: Text(size),
        )).toList(),
        onChanged: (value) {
          setState(() {
            _sizeController.text = value ?? '';
          });
        },
        validator: (value) {
          if (SizeService.isSizeRequired(_categoryController.text) &&
              (value == null || value.isEmpty)) {
            return 'Please select a size';
          }
          return null;
        },
      ),
    );
  }
}
