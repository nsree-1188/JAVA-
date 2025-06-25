const express = require("express")
const router = express.Router()
const Product = require("../models/VendorProduct")
const upload = require("../middleware/upload")
const path = require("path")

// Get all vendor products
router.get("/products", async (req, res) => {
  try {
    const { vendorId } = req.query

    const query = {}
    if (vendorId) {
      query.vendorId = vendorId
    }

    const products = await Product.find(query).sort({ createdAt: -1 })

    // Add full image URLs
    const productsWithImageUrls = products.map((product) => {
      const productObj = product.toObject()
      if (productObj.images && productObj.images.length > 0) {
        productObj.images = productObj.images.map((imagePath) => {
          if (imagePath.startsWith("http")) {
            return imagePath
          }
          return `${req.protocol}://${req.get("host")}/uploads/${path.basename(imagePath)}`
        })
      }
      return productObj
    })

    res.json({
      success: true,
      products: productsWithImageUrls,
    })
  } catch (error) {
    console.error("Error fetching vendor products:", error)
    res.status(500).json({
      success: false,
      message: "Error fetching vendor products",
      error: error.message,
    })
  }
})

// Get vendor product by ID
router.get("/products/:id", async (req, res) => {
  try {
    const product = await Product.findById(req.params.id)

    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Product not found",
      })
    }

    const productObj = product.toObject()
    if (productObj.images && productObj.images.length > 0) {
      productObj.images = productObj.images.map((imagePath) => {
        if (imagePath.startsWith("http")) {
          return imagePath
        }
        return `${req.protocol}://${req.get("host")}/uploads/${path.basename(imagePath)}`
      })
    }

    res.json({
      success: true,
      product: productObj,
    })
  } catch (error) {
    console.error("Error fetching vendor product:", error)
    res.status(500).json({
      success: false,
      message: "Error fetching vendor product",
      error: error.message,
    })
  }
})

// Add new vendor product with image upload
router.post("/products", upload.array("images", 5), async (req, res) => {
  try {
    console.log("=== ADDING VENDOR PRODUCT ===")
    console.log("Body:", req.body)
    console.log("Files:", req.files)

    const { name, description, price, stock, category, vendorId, vendorName } = req.body

    // Validate required fields
    if (!name || !description || !price || !stock || !category || !vendorId) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields",
      })
    }

    // Process uploaded images
    const imagePaths = req.files ? req.files.map((file) => file.filename) : []

    const newProduct = new Product({
      name: name.trim(),
      description: description.trim(),
      price: Number.parseFloat(price),
      stock: Number.parseInt(stock),
      category: category.trim(),
      vendorId: vendorId.trim(),
      vendorName: vendorName?.trim() || "Unknown Vendor",
      images: imagePaths,
      createdAt: new Date(),
      updatedAt: new Date(),
    })

    const savedProduct = await newProduct.save()
    console.log("Vendor product saved successfully:", savedProduct._id)

    // Return product with full image URLs
    const productObj = savedProduct.toObject()
    if (productObj.images && productObj.images.length > 0) {
      productObj.images = productObj.images.map((imagePath) => {
        return `${req.protocol}://${req.get("host")}/uploads/${imagePath}`
      })
    }

    res.status(201).json({
      success: true,
      message: "Vendor product created successfully",
      product: productObj,
    })
  } catch (error) {
    console.error("Error creating vendor product:", error)
    res.status(500).json({
      success: false,
      message: "Error creating vendor product",
      error: error.message,
    })
  }
})

// Update vendor product
router.put("/products/:id", upload.array("images", 5), async (req, res) => {
  try {
    console.log("=== UPDATING VENDOR PRODUCT ===")
    console.log("Product ID:", req.params.id)
    console.log("Body:", req.body)
    console.log("Files:", req.files)

    const { name, description, price, stock, category, vendorName, existingImages } = req.body

    const product = await Product.findById(req.params.id)
    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Product not found",
      })
    }

    // Handle images
    let imagePaths = []

    // Keep existing images if specified
    if (existingImages) {
      const existing = Array.isArray(existingImages) ? existingImages : [existingImages]
      imagePaths = existing.map((img) => path.basename(img))
    }

    // Add new uploaded images
    if (req.files && req.files.length > 0) {
      const newImages = req.files.map((file) => file.filename)
      imagePaths = [...imagePaths, ...newImages]
    }

    // Update product
    const updatedProduct = await Product.findByIdAndUpdate(
      req.params.id,
      {
        name: name?.trim() || product.name,
        description: description?.trim() || product.description,
        price: price ? Number.parseFloat(price) : product.price,
        stock: stock ? Number.parseInt(stock) : product.stock,
        category: category?.trim() || product.category,
        vendorName: vendorName?.trim() || product.vendorName,
        images: imagePaths,
        updatedAt: new Date(),
      },
      { new: true },
    )

    // Return product with full image URLs
    const productObj = updatedProduct.toObject()
    if (productObj.images && productObj.images.length > 0) {
      productObj.images = productObj.images.map((imagePath) => {
        if (imagePath.startsWith("http")) {
          return imagePath
        }
        return `${req.protocol}://${req.get("host")}/uploads/${imagePath}`
      })
    }

    res.json({
      success: true,
      message: "Vendor product updated successfully",
      product: productObj,
    })
  } catch (error) {
    console.error("Error updating vendor product:", error)
    res.status(500).json({
      success: false,
      message: "Error updating vendor product",
      error: error.message,
    })
  }
})

// Delete vendor product
router.delete("/products/:id", async (req, res) => {
  try {
    const product = await Product.findById(req.params.id)

    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Product not found",
      })
    }

    // Delete associated image files
    if (product.images && product.images.length > 0) {
      const fs = require("fs")
      product.images.forEach((imagePath) => {
        const fullPath = path.join(__dirname, "../uploads", path.basename(imagePath))
        if (fs.existsSync(fullPath)) {
          fs.unlinkSync(fullPath)
        }
      })
    }

    await Product.findByIdAndDelete(req.params.id)

    res.json({
      success: true,
      message: "Vendor product deleted successfully",
    })
  } catch (error) {
    console.error("Error deleting vendor product:", error)
    res.status(500).json({
      success: false,
      message: "Error deleting vendor product",
      error: error.message,
    })
  }
})

module.exports = router
