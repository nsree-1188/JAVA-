const AdminProduct = require("../models/AdminProduct")
const { validationResult } = require("express-validator")

const adminProductController = {
  // Get all admin products
  getAllAdminProducts: async (req, res) => {
    try {
      console.log("Fetching all admin products...")

      const page = Number.parseInt(req.query.page) || 1
      const limit = Number.parseInt(req.query.limit) || 10
      const skip = (page - 1) * limit

      const filter = {}
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

      let products
      try {
        products = await AdminProduct.find(filter)
          .populate("created_by", "name email")
          .sort({ createdAt: -1 })
          .skip(skip)
          .limit(limit)
      } catch (populateError) {
        console.warn("Population failed, fetching without populate:", populateError.message)
        products = await AdminProduct.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit)
      }

      const total = await AdminProduct.countDocuments(filter)

      // Transform data to match frontend expectations
      const transformedProducts = products.map((product) => ({
        id: product._id.toString(),
        name: product.name,
        description: product.description,
        price: product.price,
        stock: product.stock_quantity, // Map stock_quantity to stock for frontend
        category: product.category,
        vendorId: "admin",
        vendorName: "Admin Store",
        images: product.image_url ? [product.image_url] : [],
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
        status: product.status || "active",
      }))

      console.log(`Found ${products.length} admin products`)
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
      console.error("Error fetching admin products:", error)
      res.status(500).json({
        success: false,
        message: "Failed to fetch admin products",
        error: error.message,
      })
    }
  },

  // Get admin product by ID
  getAdminProductById: async (req, res) => {
    try {
      const { id } = req.params
      console.log(`Fetching admin product with ID: ${id}`)

      let product
      try {
        product = await AdminProduct.findById(id).populate("created_by", "name email")
      } catch (populateError) {
        console.warn("Population failed, fetching without populate:", populateError.message)
        product = await AdminProduct.findById(id)
      }

      if (!product) {
        console.log(`Admin product not found with ID: ${id}`)
        return res.status(404).json({
          success: false,
          message: "Admin product not found",
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
        vendorId: "admin",
        vendorName: "Admin Store",
        images: product.image_url ? [product.image_url] : [],
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
        status: product.status || "active",
      }

      console.log(`Admin product found: ${product.name} with stock: ${transformedProduct.stock}`)

      res.json({
        success: true,
        data: transformedProduct,
      })
    } catch (error) {
      console.error("Error fetching admin product:", error)
      res.status(500).json({
        success: false,
        message: "Failed to fetch admin product",
        error: error.message,
      })
    }
  },

  // Create new admin product
  createAdminProduct: async (req, res) => {
    try {
      const errors = validationResult(req)
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: "Validation errors",
          errors: errors.array(),
        })
      }

      console.log("Creating new admin product:", req.body)

      // Get default admin user helper function
      const getDefaultAdminUser = async () => {
        const User = require("../models/User")
        let adminUser = await User.findOne({ role: "admin" })

        if (!adminUser) {
          console.log("No admin user found, creating default admin...")
          const bcrypt = require("bcryptjs")
          const hashedPassword = await bcrypt.hash("admin123", 10)

          adminUser = new User({
            name: "Default Admin",
            email: process.env.DEFAULT_ADMIN_EMAIL || "admin@example.com",
            password: hashedPassword,
            role: "admin",
            status: "active",
          })
          await adminUser.save()
          console.log("Default admin user created")
        }

        return adminUser
      }

      const adminUser = await getDefaultAdminUser()

      // Transform frontend data to database format
      const productData = {
        name: req.body.name,
        description: req.body.description,
        price: req.body.price,
        stock_quantity: req.body.stock || req.body.stock_quantity || 0, // Handle both field names
        category: req.body.category,
        image_url: req.body.image_url || "",
        status: req.body.status || "active",
        created_by: adminUser._id,
      }

      console.log("Transformed product data:", productData)

      const product = new AdminProduct(productData)
      await product.save()

      // Transform response back to frontend format
      const transformedProduct = {
        id: product._id.toString(),
        name: product.name,
        description: product.description,
        price: product.price,
        stock: product.stock_quantity, // Map back to stock for frontend
        category: product.category,
        vendorId: "admin",
        vendorName: "Admin Store",
        images: product.image_url ? [product.image_url] : [],
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
        status: product.status,
      }

      console.log(`Admin product created successfully: ${product.name} with stock: ${product.stock_quantity}`)

      res.status(201).json({
        success: true,
        message: "Admin product created successfully",
        data: transformedProduct,
      })
    } catch (error) {
      console.error("Error creating admin product:", error)
      res.status(500).json({
        success: false,
        message: "Failed to create admin product",
        error: error.message,
      })
    }
  },

  // Update admin product
  updateAdminProduct: async (req, res) => {
    try {
      const { id } = req.params
      console.log(`Updating admin product with ID: ${id}`)

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
        image_url: req.body.image_url || "",
        status: req.body.status || "active",
        updatedAt: new Date(),
      }

      console.log("Update data:", updateData)

      let product
      try {
        product = await AdminProduct.findByIdAndUpdate(id, updateData, { new: true, runValidators: true }).populate(
          "created_by",
          "name email",
        )
      } catch (populateError) {
        console.warn("Population failed during update, updating without populate:", populateError.message)
        product = await AdminProduct.findByIdAndUpdate(id, updateData, { new: true, runValidators: true })
      }

      if (!product) {
        console.log(`Admin product not found with ID: ${id}`)
        return res.status(404).json({
          success: false,
          message: "Admin product not found",
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
        vendorId: "admin",
        vendorName: "Admin Store",
        images: product.image_url ? [product.image_url] : [],
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
        status: product.status,
      }

      console.log(`Admin product updated successfully: ${product.name} with stock: ${product.stock_quantity}`)

      res.json({
        success: true,
        message: "Admin product updated successfully",
        data: transformedProduct,
      })
    } catch (error) {
      console.error("Error updating admin product:", error)
      res.status(500).json({
        success: false,
        message: "Failed to update admin product",
        error: error.message,
      })
    }
  },

  // Delete admin product
  deleteAdminProduct: async (req, res) => {
    try {
      const { id } = req.params
      console.log(`Deleting admin product with ID: ${id}`)

      const product = await AdminProduct.findByIdAndDelete(id)

      if (!product) {
        console.log(`Admin product not found with ID: ${id}`)
        return res.status(404).json({
          success: false,
          message: "Admin product not found",
        })
      }

      console.log(`Admin product deleted successfully: ${product.name}`)

      res.json({
        success: true,
        message: "Admin product deleted successfully",
        data: { id: product._id, name: product.name },
      })
    } catch (error) {
      console.error("Error deleting admin product:", error)
      res.status(500).json({
        success: false,
        message: "Failed to delete admin product",
        error: error.message,
      })
    }
  },

  // Get admin product categories
  getAdminProductCategories: async (req, res) => {
    try {
      const categories = await AdminProduct.distinct("category")

      res.json({
        success: true,
        data: categories,
      })
    } catch (error) {
      console.error("Error fetching admin product categories:", error)
      res.status(500).json({
        success: false,
        message: "Failed to fetch categories",
        error: error.message,
      })
    }
  },
}

module.exports = adminProductController
