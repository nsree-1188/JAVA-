const VendorProduct = require("../models/VendorProduct")
const { validationResult } = require("express-validator")

const vendorProductController = {
  // Get all vendor products
  getAllVendorProducts: async (req, res) => {
    try {
      console.log("Fetching all vendor products...")

      const page = Number.parseInt(req.query.page) || 1
      const limit = Number.parseInt(req.query.limit) || 10
      const skip = (page - 1) * limit

      const filter = {}
      if (req.query.vendor_id) {
        filter.vendor_id = req.query.vendor_id
      }
      if (req.query.category) {
        filter.category = req.query.category
      }
      if (req.query.status) {
        filter.status = req.query.status
      }
      if (req.query.search) {
        filter.$or = [
          { name: { $regex: req.query.search, $options: "i" } },
          { description: { $regex: req.query.search, $options: "i" } },
        ]
      }

      const products = await VendorProduct.find(filter)
        .populate("vendor_id", "name email business_name")
        .populate("approved_by", "name email")
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)

      const total = await VendorProduct.countDocuments(filter)

      // Transform data to match frontend expectations
      const transformedProducts = products.map((product) => ({
        id: product._id.toString(),
        name: product.name,
        description: product.description,
        price: product.price,
        stock: product.stock_quantity, // Map stock_quantity to stock for frontend
        category: product.category,
        size: product.size, // Add size field
        vendorId: product.vendor_id ? product.vendor_id._id.toString() : product.vendor_id,
        vendorName: product.vendor_id ? product.vendor_id.business_name || product.vendor_id.name : "Unknown Vendor",
        images: product.image_url ? [product.image_url] : [],
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
        status: product.status || "pending",
      }))

      console.log(`Found ${products.length} vendor products`)
      console.log(
        `Sample stock values: ${transformedProducts
          .slice(0, 3)
          .map((p) => `${p.name}: ${p.stock}`)
          .join(", ")}`,
      )

      res.json({
        success: true,
        data: transformedProducts,
        pagination: {
          current_page: page,
          total_pages: Math.ceil(total / limit),
          total_items: total,
          items_per_page: limit,
        },
      })
    } catch (error) {
      console.error("Error fetching vendor products:", error)
      res.status(500).json({
        success: false,
        message: "Failed to fetch vendor products",
        error: error.message,
      })
    }
  },

  // Get vendor product by ID
  getVendorProductById: async (req, res) => {
    try {
      const { id } = req.params
      console.log(`Fetching vendor product with ID: ${id}`)

      const product = await VendorProduct.findById(id)
        .populate("vendor_id", "name email business_name")
        .populate("approved_by", "name email")

      if (!product) {
        console.log(`Vendor product not found with ID: ${id}`)
        return res.status(404).json({
          success: false,
          message: "Vendor product not found",
        })
      }

      // Transform data to match frontend expectations
      const transformedProduct = {
        id: product._id.toString(),
        name: product.name,
        description: product.description,
        price: product.price,
        stock: product.stock_quantity, // Map stock_quantity to stock for frontend
        category: product.category,
        size: product.size, // Add size field
        vendorId: product.vendor_id ? product.vendor_id._id.toString() : product.vendor_id,
        vendorName: product.vendor_id ? product.vendor_id.business_name || product.vendor_id.name : "Unknown Vendor",
        images: product.image_url ? [product.image_url] : [],
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
        status: product.status || "pending",
      }

      console.log(`Vendor product found: ${product.name} with stock: ${transformedProduct.stock}`)

      res.json({
        success: true,
        data: transformedProduct,
      })
    } catch (error) {
      console.error("Error fetching vendor product:", error)
      res.status(500).json({
        success: false,
        message: "Failed to fetch vendor product",
        error: error.message,
      })
    }
  },

  // Create new vendor product
  createVendorProduct: async (req, res) => {
    try {
      const errors = validationResult(req)
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: "Validation errors",
          errors: errors.array(),
        })
      }

      console.log("Creating new vendor product:", req.body)

      // Transform frontend data to database format
      const productData = {
        name: req.body.name,
        description: req.body.description,
        price: req.body.price,
        stock_quantity: req.body.stock || req.body.stock_quantity || 0, // Handle both field names
        category: req.body.category,
        size: req.body.size, // Add size field
        vendor_id: req.body.vendor_id,
        image_url: req.body.image_url || "",
        status: req.body.status || "pending",
      }

      console.log("Transformed product data:", productData)

      const product = new VendorProduct(productData)
      await product.save()

      // Transform response back to frontend format
      const transformedProduct = {
        id: product._id.toString(),
        name: product.name,
        description: product.description,
        price: product.price,
        stock: product.stock_quantity, // Map back to stock for frontend
        category: product.category,
        size: product.size, // Add size field
        vendorId: product.vendor_id,
        vendorName: "Vendor Store", // Will be populated in subsequent requests
        images: product.image_url ? [product.image_url] : [],
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
        status: product.status,
      }

      console.log(`Vendor product created successfully: ${product.name} with stock: ${product.stock_quantity}`)

      res.status(201).json({
        success: true,
        message: "Vendor product created successfully",
        data: transformedProduct,
      })
    } catch (error) {
      console.error("Error creating vendor product:", error)
      res.status(500).json({
        success: false,
        message: "Failed to create vendor product",
        error: error.message,
      })
    }
  },

  // Update vendor product
  updateVendorProduct: async (req, res) => {
    try {
      const { id } = req.params
      console.log(`Updating vendor product with ID: ${id}`)

      const errors = validationResult(req)
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: "Validation errors",
          errors: errors.array(),
        })
      }

      // Transform frontend data to database format
      const updateData = {
        name: req.body.name,
        description: req.body.description,
        price: req.body.price,
        stock_quantity: req.body.stock || req.body.stock_quantity, // Handle both field names
        category: req.body.category,
        size: req.body.size, // Add size field
        image_url: req.body.image_url || "",
        status: req.body.status || "pending",
        updatedAt: new Date(),
      }

      console.log("Update data:", updateData)

      const product = await VendorProduct.findByIdAndUpdate(id, updateData, { new: true, runValidators: true })
        .populate("vendor_id", "name email business_name")
        .populate("approved_by", "name email")

      if (!product) {
        console.log(`Vendor product not found with ID: ${id}`)
        return res.status(404).json({
          success: false,
          message: "Vendor product not found",
        })
      }

      // Transform response back to frontend format
      const transformedProduct = {
        id: product._id.toString(),
        name: product.name,
        description: product.description,
        price: product.price,
        stock: product.stock_quantity, // Map back to stock for frontend
        category: product.category,
        size: product.size, // Add size field
        vendorId: product.vendor_id ? product.vendor_id._id.toString() : product.vendor_id,
        vendorName: product.vendor_id ? product.vendor_id.business_name || product.vendor_id.name : "Unknown Vendor",
        images: product.image_url ? [product.image_url] : [],
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
        status: product.status,
      }

      console.log(`Vendor product updated successfully: ${product.name} with stock: ${product.stock_quantity}`)

      res.json({
        success: true,
        message: "Vendor product updated successfully",
        data: transformedProduct,
      })
    } catch (error) {
      console.error("Error updating vendor product:", error)
      res.status(500).json({
        success: false,
        message: "Failed to update vendor product",
        error: error.message,
      })
    }
  },

  // Delete vendor product
  deleteVendorProduct: async (req, res) => {
    try {
      const { id } = req.params
      console.log(`Deleting vendor product with ID: ${id}`)

      const product = await VendorProduct.findByIdAndDelete(id)

      if (!product) {
        console.log(`Vendor product not found with ID: ${id}`)
        return res.status(404).json({
          success: false,
          message: "Vendor product not found",
        })
      }

      console.log(`Vendor product deleted successfully: ${product.name}`)

      res.json({
        success: true,
        message: "Vendor product deleted successfully",
        data: { id: product._id, name: product.name },
      })
    } catch (error) {
      console.error("Error deleting vendor product:", error)
      res.status(500).json({
        success: false,
        message: "Failed to delete vendor product",
        error: error.message,
      })
    }
  },

  // Approve vendor product (Admin only)
  approveVendorProduct: async (req, res) => {
    try {
      const { id } = req.params
      console.log(`Approving vendor product with ID: ${id}`)

      const product = await VendorProduct.findByIdAndUpdate(
        id,
        {
          status: "active",
          approved_by: req.user.id,
          approved_at: new Date(),
        },
        { new: true },
      )
        .populate("vendor_id", "name email business_name")
        .populate("approved_by", "name email")

      if (!product) {
        return res.status(404).json({
          success: false,
          message: "Vendor product not found",
        })
      }

      console.log(`Vendor product approved successfully: ${product.name}`)

      res.json({
        success: true,
        message: "Vendor product approved successfully",
        data: product,
      })
    } catch (error) {
      console.error("Error approving vendor product:", error)
      res.status(500).json({
        success: false,
        message: "Failed to approve vendor product",
        error: error.message,
      })
    }
  },

  // Get vendor product categories
  getVendorProductCategories: async (req, res) => {
    try {
      const categories = await VendorProduct.distinct("category")

      res.json({
        success: true,
        data: categories,
      })
    } catch (error) {
      console.error("Error fetching vendor product categories:", error)
      res.status(500).json({
        success: false,
        message: "Failed to fetch categories",
        error: error.message,
      })
    }
  },
}

module.exports = vendorProductController
