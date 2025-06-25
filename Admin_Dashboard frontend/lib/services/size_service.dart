class SizeService {
  // Size validation constants
  static const List<String> shoeSizes = ['3', '4', '5', '6', '7', '8'];
  static const List<String> clothingSizes = ['S', 'M', 'L', 'XL', 'XXL', 'XXXL'];
  static const List<String> sizeRequiredCategories = ['shoes', 'menswear', 'womenswear'];

  // Check if size is required for a category
  static bool isSizeRequired(String category) {
    return sizeRequiredCategories.contains(category.toLowerCase());
  }

  // Get valid sizes for a category
  static List<String> getValidSizes(String category) {
    final categoryLower = category.toLowerCase();

    if (categoryLower == 'shoes') {
      return shoeSizes;
    } else if (categoryLower == 'menswear' || categoryLower == 'womenswear') {
      return clothingSizes;
    }

    return [];
  }

  // Validate size for a category
  static Map<String, dynamic> validateSize(String? size, String category) {
    final categoryLower = category.toLowerCase();

    // If size is required but not provided
    if (isSizeRequired(category) && (size == null || size.trim().isEmpty)) {
      return {
        'valid': false,
        'error': 'Size is required for $category',
        'validSizes': getValidSizes(category)
      };
    }

    // If size is provided, validate it
    if (size != null && size.trim().isNotEmpty) {
      final validSizes = getValidSizes(category);
      if (validSizes.isNotEmpty && !validSizes.contains(size)) {
        return {
          'valid': false,
          'error': 'Invalid size for $category. Valid sizes: ${validSizes.join(', ')}',
          'validSizes': validSizes
        };
      }
    }

    return {'valid': true};
  }

  // Get size options for dropdown
  static List<Map<String, String>> getSizeOptions(String category) {
    final validSizes = getValidSizes(category);
    return validSizes.map((size) => {
      'value': size,
      'label': size
    }).toList();
  }

  // Get category display name
  static String getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'shoes':
        return 'Shoes';
      case 'menswear':
        return 'Menswear';
      case 'womenswear':
        return 'Womenswear';
      default:
        return category;
    }
  }
}
