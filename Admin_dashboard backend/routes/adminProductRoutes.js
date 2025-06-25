const express = require("express");
const router = express.Router();
const AdminProduct = require("../models/AdminProduct");
const upload = require("../middleware/upload");
const path = require("path");
const fs = require("fs");

// ===========================
// GET All Products
// ===========================
router.get("/products", async (req, res) => {
  try {
    console.log("📝 GET /api/admin/products");
    const products = await AdminProduct.find().sort({ createdAt: -1 });
    console.log(`📦 Found ${products.length} admin products`);

    const productsWithImageUrls = products.map((product) => {
      const productObj = product.toObject();
      productObj.id = productObj._id.toString();
      delete productObj._id;

      if (productObj.image_url && productObj.image_url.trim() !== "") {
        if (productObj.image_url.startsWith("http")) {
          productObj.images = [productObj.image_url];
        } else {
          productObj.images = [
            `${req.protocol}://${req.get("host")}/uploads/${path.basename(productObj.image_url)}`,
          ];
        }
      } else {
        productObj.images = [];
      }

      // Add vendor fields
      productObj.vendorId = "admin";
      productObj.vendorName = "Admin Store";
      // Map stock quantity
      if (productObj.stock_quantity !== undefined) {
        productObj.stock = productObj.stock_quantity;
      }
      return productObj;
    });

    res.json({ success: true, products: productsWithImageUrls });
  } catch (error) {
    console.error("❌ Error fetching admin products:", error);
    res.status(500).json({
      success: false,
      message: "Error fetching admin products",
      error: error.message,
    });
  }
});

// ===========================
// GET Single Product
// ===========================
router.get("/products/:id", async (req, res) => {
  try {
    console.log(`📝 GET /api/admin/products/${req.params.id}`);
    const product = await AdminProduct.findById(req.params.id);

    if (!product) {
      return res.status(404).json({ success: false, message: "Product not found" });
    }

    const productObj = product.toObject();
    productObj.id = productObj._id.toString();
    delete productObj._id;

    if (productObj.image_url && productObj.image_url.trim() !== "") {
      if (productObj.image_url.startsWith("http")) {
        productObj.images = [productObj.image_url];
      } else {
        productObj.images = [
          `${req.protocol}://${req.get("host")}/uploads/${path.basename(productObj.image_url)}`,
        ];
      }
    } else {
      productObj.images = [];
    }

    // Add vendor fields
    productObj.vendorId = "admin";
    productObj.vendorName = "Admin Store";

    if (productObj.stock_quantity !== undefined) {
      productObj.stock = productObj.stock_quantity;
    }

    res.json({ success: true, product: productObj });
  } catch (error) {
    console.error("❌ Error fetching admin product:", error);
    res.status(500).json({
      success: false,
      message: "Error fetching admin product",
      error: error.message,
    });
  }
});

// ===========================
// POST Create Product
// ===========================
router.post("/products", upload.single("image"), async (req, res) => {
  try {
    console.log("=== ADMIN PRODUCT CREATION REQUEST ===");
    console.log("📝 Request Body:", JSON.stringify(req.body, null, 2));
    console.log("📁 Uploaded File:", req.file);

    const { name, description, price, stock, category, stock_quantity } = req.body;

    if (!name || !description || !price || !category) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields: name, description, price, category",
        received: req.body,
      });
    }

    const stockValue = stock_quantity || stock;

    if (!stockValue) {
      return res.status(400).json({
        success: false,
        message: "Missing required field: stock",
        received: req.body,
      });
    }

    const adminUserId = "6857a1c4572971fee27e4dee"; // Replace with actual admin user ID
    const imageUrl = req.file ? req.file.filename : ""; // Get uploaded image

    const productData = {
      name: name.trim(),
      description: description.trim(),
      price: parseFloat(price),
      stock_quantity: parseInt(stockValue),
      stock: parseInt(stockValue),
      category: category.trim(),
      image_url: imageUrl,
      status: "active",
      created_by: adminUserId,
    };
    console.log("📦 Final product data:", JSON.stringify(productData, null, 2));

    const newProduct = new AdminProduct(productData);
    const savedProduct = await newProduct.save();

    const responseProduct = savedProduct.toObject();
    responseProduct.id = responseProduct._id.toString();
    delete responseProduct._id;

    if (responseProduct.image_url) {
      responseProduct.images = [
        `${req.protocol}://${req.get("host")}/uploads/${responseProduct.image_url}`,
      ];
    } else {
      responseProduct.images = [];
    }

    responseProduct.vendorId = "admin";
    responseProduct.vendorName = "Admin Store";
    responseProduct.stock = responseProduct.stock_quantity;

    res.status(201).json({
      success: true,
      message: "Admin product created successfully",
      product: responseProduct,
    });
  } catch (error) {
    console.error("❌ Error creating admin product:", error);
    res.status(500).json({
      success: false,
      message: "Error creating admin product",
      error: error.message,
    });
  }
});

// ===========================
// PUT Update Product
// ===========================
router.put("/products/:id", upload.single("image"), async (req, res) => {
  try {
    console.log("=== UPDATING ADMIN PRODUCT ===");
    console.log("Product ID:", req.params.id);
    console.log("Body:", req.body);
    console.log("File:", req.file);

    const { name, description, price, stock, category, stock_quantity } = req.body;

    const product = await AdminProduct.findById(req.params.id);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Product not found",
      });
    }

    const updateData = {
      name: name?.trim() || product.name,
      description: description?.trim() || product.description,
      price: price ? parseFloat(price) : product.price,
      stock_quantity: stock_quantity
        ? parseInt(stock_quantity)
        : (stock ? parseInt(stock) : product.stock_quantity),
      stock: stock_quantity
        ? parseInt(stock_quantity)
        : (stock ? parseInt(stock) : product.stock_quantity),
      category: category?.trim() || product.category,
      updatedAt: new Date(),
    };
    if (req.file) {
      updateData.image_url = req.file.filename;
      console.log("🖼️ New image uploaded:", req.file.filename);
    }

    console.log("🔄 Final update data:", JSON.stringify(updateData, null, 2));

    const updatedProduct = await AdminProduct.findByIdAndUpdate(req.params.id, updateData, {
      new: true,
      runValidators: true,
    });

    const responseProduct = updatedProduct.toObject();
    responseProduct.id = responseProduct._id.toString();
    delete responseProduct._id;

    if (responseProduct.image_url) {
      responseProduct.images = responseProduct.image_url.startsWith("http")
        ? [responseProduct.image_url]
        : [`${req.protocol}://${req.get("host")}/uploads/${responseProduct.image_url}`];
    } else {
      responseProduct.images = [];
    }

    responseProduct.vendorId = "admin";
    responseProduct.vendorName = "Admin Store";
    responseProduct.stock = responseProduct.stock_quantity;

    res.json({
      success: true,
      message: "Admin product updated successfully",
      product: responseProduct,
    });
  } catch (error) {
    console.error("❌ Error updating admin product:", error);
    res.status(500).json({
      success: false,
      message: "Error updating admin product",
      error: error.message,
    });
  }
});

// ===========================
// DELETE Product
// ===========================
router.delete("/products/:id", async (req, res) => {
  try {
    const product = await AdminProduct.findById(req.params.id);

    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Product not found",
      });
    }

    // Delete associated image
    if (product.image_url) {
      const fullPath = path.join(__dirname, "../uploads", path.basename(product.image_url));
      if (fs.existsSync(fullPath)) {
        fs.unlinkSync(fullPath);
        console.log("🗑️ Deleted image file:", product.image_url);
      }
    }

    await AdminProduct.findByIdAndDelete(req.params.id);
    res.json({
      success: true,
      message: "Admin product deleted successfully",
    });
  } catch (error) {
    console.error("❌ Error deleting admin product:", error);
    res.status(500).json({
      success: false,
      message: "Error deleting admin product",
      error: error.message,
    });
  }
});

// ===========================
// GET Dashboard Stats
// ===========================
router.get("/dashboard-stats", async (req, res) => {
  try {
    const totalAdminProducts = await AdminProduct.countDocuments();

    res.json({
      success: true,
      stats: {
        totalUsers: 1250,
        totalVendors: 85,
        totalProducts: totalAdminProducts + 150,
        totalOrders: 320,
        totalRevenue: 45000.0,
        pendingOrders: 25,
        pendingVendors: 8,
        activeReports: 12,
      },
    });
  } catch (error) {
    console.error("❌ Error fetching dashboard stats:", error);
    res.status(500).json({
      success: false,
      message: "Error fetching dashboard stats",
      error: error.message,
    });
  }
});

module.exports = router;
