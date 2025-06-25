const express = require("express")
const mongoose = require("mongoose")
const cors = require("cors")
const bcrypt = require("bcryptjs")
const jwt = require("jsonwebtoken")
const dotenv = require("dotenv")
const multer = require("multer")
const path = require("path")
const fs = require("fs")

// Create uploads directory if it doesn't exist
const uploadsDir = path.join(__dirname, "uploads")
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true })
}

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir)
  },
  filename: (req, file, cb) => {
    // Generate unique filename with timestamp
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9)
    cb(null, file.fieldname + "-" + uniqueSuffix + path.extname(file.originalname))
  },
})

// File filter to only allow images
const fileFilter = (req, file, cb) => {
  console.log(`📸 Processing file: ${file.fieldname}, mimetype: ${file.mimetype}`)
  if (file.mimetype.startsWith("image/")) {
    cb(null, true)
  } else {
    cb(new Error("Only image files are allowed!"), false)
  }
}

// Configure multer with flexible field handling
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
    files: 10, // Allow up to 10 files
  },
})

// Create a flexible upload middleware that accepts any field name
const flexibleUpload = (req, res, next) => {
  // Use multer.any() to accept files with any field name
  const uploadAny = upload.any()

  uploadAny(req, res, (err) => {
    if (err) {
      console.error("📸 Upload error:", err)
      return res.status(400).json({
        success: false,
        error: "File upload failed",
        message: err.message,
      })
    }

    console.log(`📸 Files received: ${req.files ? req.files.length : 0}`)
    if (req.files && req.files.length > 0) {
      req.files.forEach((file, index) => {
        console.log(`   File ${index + 1}: ${file.fieldname} -> ${file.filename}`)
      })
    }

    next()
  })
}

// Load environment variables
dotenv.config()

const app = express()
const PORT = process.env.PORT || 3007

// Middleware
app.use(
  cors({
    origin: "*", // Allow all origins for testing
    credentials: true,
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  }),
)
app.use(express.json())
app.use(express.urlencoded({ extended: true }))

// Add request logging middleware
app.use((req, res, next) => {
  console.log(`📝 ${req.method} ${req.path}`)
  if (req.body && Object.keys(req.body).length > 0) {
    console.log("📦 Request Body:", JSON.stringify(req.body, null, 2))
  }
  next()
})

// MongoDB connection
const connectDB = async () => {
  try {
    const mongoURI = process.env.MONGODB_URI || "mongodb://localhost:27017/admin_dashboard"

    await mongoose.connect(mongoURI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    })

    console.log("✅ MongoDB connected successfully")
    console.log(`📊 Database: ${mongoose.connection.name}`)
  } catch (error) {
    console.error("❌ MongoDB connection error:", error)
    process.exit(1)
  }
}

// Import Models
const User = require("./models/User")
const Vendor = require("./models/Vendor")
const Product = require("./models/VendorProduct")
const AdminProduct = require("./models/AdminProduct")
const Order = require("./models/Order")
const Report = require("./models/Report")

// Helper function to get or create default admin user
const getDefaultAdminUser = async () => {
  try {
    // Try to find an admin user
    let adminUser = await User.findOne({ role: "admin" })

    if (!adminUser) {
      console.log("🔍 No admin user found, creating default admin...")
      // Create a default admin user if none exists
      adminUser = new User({
        name: "Default Admin",
        email: "admin@example.com",
        password: await bcrypt.hash("admin123", 10),
        role: "admin",
        status: "active",
      })
      await adminUser.save()
      console.log("✅ Created default admin user")
    }

    return adminUser._id
  } catch (error) {
    console.error("❌ Error getting/creating admin user:", error)
    // Return a default ObjectId if all else fails
    return new mongoose.Types.ObjectId()
  }
}

// ==================== ADMIN PRODUCTS ROUTES ====================

// POST /api/admin/products - Create new admin product
app.post("/api/admin/products", flexibleUpload, async (req, res) => {
  console.log("\n🚀 === ADMIN PRODUCT CREATION REQUEST ===")
  console.log("📝 Request Body:", JSON.stringify(req.body, null, 2))

  try {
    // Get default admin user ID for created_by field
    const adminUserId = await getDefaultAdminUser()
    console.log("👤 Using admin user ID:", adminUserId)

    // Remove problematic fields that shouldn't be set manually
    const { _id, __v, createdAt, updatedAt, vendorId, id, size, ...cleanData } = req.body

    console.log("🧹 Cleaned data:", JSON.stringify(cleanData, null, 2))

    const { name, description, price, stock, category, vendorName, images, weight, tags } = cleanData

    // Validate required fields
    const missingFields = []
    if (!name || name.trim() === "") missingFields.push("name")
    if (!description || description.trim() === "") missingFields.push("description")
    if (price === undefined || price === null || price === "") missingFields.push("price")
    if (!category || category.trim() === "") missingFields.push("category")

    if (missingFields.length > 0) {
      console.log("❌ Missing required fields:", missingFields)
      return res.status(400).json({
        success: false,
        error: `Missing required fields: ${missingFields.join(", ")}`,
        received: cleanData,
      })
    }

    // Validate and convert numeric values
    let parsedPrice, parsedStock

    try {
      parsedPrice = Number.parseFloat(price)
      if (isNaN(parsedPrice) || parsedPrice < 0) {
        throw new Error("Invalid price")
      }
    } catch (e) {
      console.log("❌ Price validation failed:", price)
      return res.status(400).json({
        success: false,
        error: "Price must be a valid positive number",
        received: price,
      })
    }

    try {
      parsedStock = stock !== undefined ? Number.parseInt(stock) : 0
      if (isNaN(parsedStock) || parsedStock < 0) {
        throw new Error("Invalid stock")
      }
    } catch (e) {
      console.log("❌ Stock validation failed:", stock)
      return res.status(400).json({
        success: false,
        error: "Stock must be a valid non-negative number",
        received: stock,
      })
    }

    console.log("✅ Validation passed:", {
      parsedPrice,
      parsedStock,
    })

    // Process uploaded images
    const imagePaths = req.files ? req.files.map((file) => file.filename) : []

    // Prepare product data for adminproducts table
    const productData = {
      name: name.trim(),
      description: description.trim(),
      price: parsedPrice,
      stock_quantity: parsedStock,
      stock: parsedStock, // Add both fields for compatibility
      category: category.trim(),
      image_url: imagePaths.length > 0 ? imagePaths[0] : "", // Use first uploaded image
      status: "active",
      created_by: adminUserId,
    }

    // Remove undefined fields
    Object.keys(productData).forEach((key) => {
      if (productData[key] === undefined) {
        delete productData[key]
      }
    })

    console.log("📦 Final product data to save:", JSON.stringify(productData, null, 2))

    // Create and save the product
    const newAdminProduct = new AdminProduct(productData)

    console.log("💾 Attempting to save to adminproducts collection...")
    const savedProduct = await newAdminProduct.save()

    console.log("✅ Admin product created successfully!")
    console.log("📋 Saved product:", {
      id: savedProduct._id,
      name: savedProduct.name,
      price: savedProduct.price,
      stock_quantity: savedProduct.stock_quantity,
      status: savedProduct.status,
      created_by: savedProduct.created_by,
    })

    // Transform response to match frontend expectations
    const responseProduct = {
      id: savedProduct._id.toString(),
      name: savedProduct.name,
      description: savedProduct.description,
      price: savedProduct.price,
      stock: savedProduct.stock || savedProduct.stock_quantity,
      category: savedProduct.category,
      vendorId: "admin",
      vendorName: "Admin Store",
      images: imagePaths.length > 0 ? imagePaths.map((path) => `http://10.0.2.2:${PORT}/uploads/${path}`) : [],
      createdAt: savedProduct.createdAt,
      updatedAt: savedProduct.updatedAt,
      status: savedProduct.status,
    }

    res.status(201).json({
      success: true,
      message: "Admin product created successfully",
      product: responseProduct,
    })
  } catch (error) {
    console.error("💥 Error creating admin product:")
    console.error("Error name:", error.name)
    console.error("Error message:", error.message)
    console.error("Full error:", error)

    if (error.code === 11000) {
      console.log("❌ Duplicate key error")
      return res.status(400).json({
        success: false,
        error: "Product with this name or SKU already exists",
        details: error.keyValue,
      })
    }

    if (error.name === "ValidationError") {
      console.log("❌ Validation error")
      const validationErrors = Object.values(error.errors).map((e) => ({
        field: e.path,
        message: e.message,
        value: e.value,
      }))
      return res.status(400).json({
        success: false,
        error: "Validation failed",
        details: validationErrors,
      })
    }

    if (error.name === "CastError") {
      console.log("❌ Cast error")
      return res.status(400).json({
        success: false,
        error: "Invalid data type",
        details: error.message,
      })
    }

    res.status(500).json({
      success: false,
      error: "Internal server error",
      message: error.message,
      type: error.name,
    })
  }
})

// GET /api/admin/products - Get all admin products
app.get("/api/admin/products", async (req, res) => {
  try {
    console.log("📋 Fetching admin products from adminproducts collection...")

    const { category, status, search, page = 1, limit = 50 } = req.query

    const query = {}
    const skip = (page - 1) * limit

    // Filter by category
    if (category) {
      query.category = new RegExp(category, "i")
    }

    // Filter by status
    if (status) {
      query.status = status
    }

    // Search functionality
    if (search) {
      query.$or = [
        { name: new RegExp(search, "i") },
        { description: new RegExp(search, "i") },
        { category: new RegExp(search, "i") },
      ]
    }

    console.log("🔍 Query:", JSON.stringify(query, null, 2))

    // Fetch admin products with proper population
    const adminProducts = await AdminProduct.find(query)
      .populate("created_by", "name email")
      .sort({ createdAt: -1 })
      .limit(Number.parseInt(limit))
      .skip(Number.parseInt(skip))

    const total = await AdminProduct.countDocuments(query)

    // Transform data to match frontend expectations
    const transformedProducts = adminProducts.map((product) => ({
      id: product._id.toString(),
      name: product.name,
      description: product.description,
      price: product.price,
      stock: product.stock || product.stock_quantity,
      category: product.category,
      vendorId: "admin",
      vendorName: "Admin Store",
      images: product.image_url ? [`http://10.0.2.2:${PORT}/uploads/${product.image_url}`] : [],
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      status: product.status || "active",
    }))

    // Add debugging for image URLs
    transformedProducts.forEach((product, index) => {
      console.log(`📸 Product ${index + 1} (${product.name}):`)
      console.log(`   - Image URLs: ${JSON.stringify(product.images)}`)
      console.log(`   - First image: ${product.images[0] || "No image"}`)
    })

    console.log(`📦 Found ${adminProducts.length} admin products (Total: ${total})`)

    res.json({
      success: true,
      products: transformedProducts,
      pagination: {
        current: Number.parseInt(page),
        pages: Math.ceil(total / limit),
        total,
        limit: Number.parseInt(limit),
      },
    })
  } catch (error) {
    console.error("❌ Error fetching admin products:", error)
    res.status(500).json({
      success: false,
      error: "Failed to fetch admin products",
      message: error.message,
    })
  }
})

// GET /api/admin/products/:id - Get admin product by ID
app.get("/api/admin/products/:id", async (req, res) => {
  try {
    console.log(`🔍 Fetching admin product with ID: ${req.params.id}`)

    const adminProduct = await AdminProduct.findById(req.params.id).populate("created_by", "name email")

    if (!adminProduct) {
      console.log("❌ Admin product not found")
      return res.status(404).json({
        success: false,
        error: "Admin product not found",
      })
    }

    // Transform data to match frontend expectations
    const transformedProduct = {
      id: adminProduct._id.toString(),
      name: adminProduct.name,
      description: adminProduct.description,
      price: adminProduct.price,
      stock: adminProduct.stock || adminProduct.stock_quantity,
      category: adminProduct.category,
      vendorId: "admin",
      vendorName: "Admin Store",
      images: adminProduct.image_url ? [`http://10.0.2.2:${PORT}/uploads/${adminProduct.image_url}`] : [],
      createdAt: adminProduct.createdAt,
      updatedAt: adminProduct.updatedAt,
      status: adminProduct.status || "active",
    }

    console.log(`✅ Retrieved admin product: ${adminProduct.name}`)
    res.json({
      success: true,
      product: transformedProduct,
    })
  } catch (error) {
    console.error("❌ Error fetching admin product:", error)
    if (error.name === "CastError") {
      return res.status(400).json({
        success: false,
        error: "Invalid product ID format",
        message: error.message,
      })
    }
    res.status(500).json({
      success: false,
      error: "Failed to fetch admin product",
      message: error.message,
    })
  }
})

// PUT /api/admin/products/:id - Update admin product
app.put("/api/admin/products/:id", flexibleUpload, async (req, res) => {
  try {
    console.log(`\n🔄 === UPDATING ADMIN PRODUCT ===`)
    console.log(`Product ID: ${req.params.id}`)
    console.log(`Request Method: ${req.method}`)
    console.log("📝 Request Body:", JSON.stringify(req.body, null, 2))
    console.log(`📸 Files received: ${req.files ? req.files.length : 0}`)

    // Find the existing product first
    const existingProduct = await AdminProduct.findById(req.params.id)
    if (!existingProduct) {
      console.log("❌ Admin product not found for update")
      return res.status(404).json({
        success: false,
        error: "Admin product not found",
      })
    }

    console.log(`📋 Found existing product: ${existingProduct.name}`)

    // Remove problematic fields that shouldn't be updated manually
    const { _id, __v, createdAt, id, created_by, size, ...cleanData } = req.body

    console.log("🧹 Cleaned update data:", JSON.stringify(cleanData, null, 2))

    // Build update data object
    const updateData = {}

    // Update basic fields if provided
    if (cleanData.name !== undefined && cleanData.name.trim() !== "") {
      updateData.name = cleanData.name.trim()
    }
    if (cleanData.description !== undefined && cleanData.description.trim() !== "") {
      updateData.description = cleanData.description.trim()
    }
    if (cleanData.category !== undefined && cleanData.category.trim() !== "") {
      updateData.category = cleanData.category.trim()
    }

    // Handle price validation and update
    if (cleanData.price !== undefined && cleanData.price !== "") {
      const parsedPrice = Number.parseFloat(cleanData.price)
      if (isNaN(parsedPrice) || parsedPrice < 0) {
        return res.status(400).json({
          success: false,
          error: "Price must be a valid positive number",
          received: cleanData.price,
        })
      }
      updateData.price = parsedPrice
    }

    // Handle stock validation and update
    if (
      (cleanData.stock !== undefined && cleanData.stock !== "") ||
      (cleanData.stock_quantity !== undefined && cleanData.stock_quantity !== "")
    ) {
      const stockValue = cleanData.stock || cleanData.stock_quantity
      const parsedStock = Number.parseInt(stockValue)
      if (isNaN(parsedStock) || parsedStock < 0) {
        return res.status(400).json({
          success: false,
          error: "Stock must be a valid non-negative number",
          received: stockValue,
        })
      }
      updateData.stock_quantity = parsedStock
      updateData.stock = parsedStock // Update both fields for compatibility
    }

    // Handle image updates
    if (req.files && req.files.length > 0) {
      // If new files are uploaded, use the first one
      const newImagePath = req.files[0].filename
      updateData.image_url = newImagePath
      console.log(`📸 New image uploaded: ${newImagePath}`)
    } else if (cleanData.image_url !== undefined) {
      // If image_url is provided in the body, use it
      updateData.image_url = cleanData.image_url
      console.log(`📸 Image URL from body: ${cleanData.image_url}`)
    }

    // Handle existing images from the request body
    const existingImages = []
    Object.keys(cleanData).forEach((key) => {
      if (key.startsWith("existingImages[") && cleanData[key]) {
        existingImages.push(cleanData[key])
      }
    })

    if (existingImages.length > 0) {
      console.log(`📸 Existing images to keep: ${existingImages.length}`)
      // For admin products, we typically use the first existing image
      updateData.image_url = existingImages[0].replace(`http://10.0.2.2:${PORT}/uploads/`, "")
    }

    // Set updated timestamp
    updateData.updatedAt = new Date()

    console.log("🔄 Final update data:", JSON.stringify(updateData, null, 2))

    // Perform the update
    const updatedProduct = await AdminProduct.findByIdAndUpdate(req.params.id, updateData, {
      new: true, // Return the updated document
      runValidators: true, // Run schema validators
    }).populate("created_by", "name email")

    if (!updatedProduct) {
      console.log("❌ Product not found after update attempt")
      return res.status(404).json({
        success: false,
        error: "Product not found after update",
      })
    }

    console.log(`✅ Admin product updated successfully: ${updatedProduct.name}`)
    console.log(`📋 Updated fields:`, Object.keys(updateData))

    // Transform response to match frontend expectations
    const transformedProduct = {
      id: updatedProduct._id.toString(),
      name: updatedProduct.name,
      description: updatedProduct.description,
      price: updatedProduct.price,
      stock: updatedProduct.stock || updatedProduct.stock_quantity,
      category: updatedProduct.category,
      vendorId: "admin",
      vendorName: "Admin Store",
      images: updatedProduct.image_url ? [`http://10.0.2.2:${PORT}/uploads/${updatedProduct.image_url}`] : [],
      createdAt: updatedProduct.createdAt,
      updatedAt: updatedProduct.updatedAt,
      status: updatedProduct.status || "active",
    }

    res.json({
      success: true,
      message: "Admin product updated successfully",
      product: transformedProduct,
      updatedFields: Object.keys(updateData),
    })
  } catch (error) {
    console.error("❌ Error updating admin product:", error)
    if (error.name === "CastError") {
      return res.status(400).json({
        success: false,
        error: "Invalid product ID format",
        message: error.message,
      })
    }
    if (error.name === "ValidationError") {
      const validationErrors = Object.values(error.errors).map((e) => ({
        field: e.path,
        message: e.message,
        value: e.value,
      }))
      return res.status(400).json({
        success: false,
        error: "Validation failed",
        details: validationErrors,
      })
    }
    res.status(500).json({
      success: false,
      error: "Failed to update admin product",
      message: error.message,
    })
  }
})

// DELETE /api/admin/products/:id - Delete admin product
app.delete("/api/admin/products/:id", async (req, res) => {
  try {
    console.log(`🗑️ Deleting admin product with ID: ${req.params.id}`)

    const adminProduct = await AdminProduct.findByIdAndDelete(req.params.id)

    if (!adminProduct) {
      console.log("❌ Admin product not found for deletion")
      return res.status(404).json({
        success: false,
        error: "Admin product not found",
      })
    }

    console.log(`✅ Admin product deleted successfully: ${adminProduct.name}`)
    res.json({
      success: true,
      message: "Admin product deleted successfully",
      deletedProduct: {
        id: adminProduct._id,
        name: adminProduct.name,
      },
    })
  } catch (error) {
    console.error("❌ Error deleting admin product:", error)
    if (error.name === "CastError") {
      return res.status(400).json({
        success: false,
        error: "Invalid product ID format",
        message: error.message,
      })
    }
    res.status(500).json({
      success: false,
      error: "Failed to delete admin product",
      message: error.message,
    })
  }
})

// ==================== VENDOR PRODUCTS ROUTES ====================

// GET /api/vendor/products - Get all vendor products
app.get("/api/vendor/products", async (req, res) => {
  try {
    console.log("📋 Fetching vendor products...")

    const { vendorId, category, status, search, page = 1, limit = 50 } = req.query

    const query = {}
    const skip = (page - 1) * limit

    // Filter by vendor
    if (vendorId) {
      query.vendor_id = vendorId
    }

    // Filter by category
    if (category) {
      query.category = new RegExp(category, "i")
    }

    // Filter by status
    if (status) {
      query.status = status
    }

    // Search functionality
    if (search) {
      query.$or = [{ name: new RegExp(search, "i") }, { description: new RegExp(search, "i") }]
    }

    console.log("🔍 Vendor products query:", JSON.stringify(query, null, 2))

    const vendorProducts = await Product.find(query)
      .populate("vendor_id", "name email status")
      .sort({ createdAt: -1 })
      .limit(Number.parseInt(limit))
      .skip(Number.parseInt(skip))

    const total = await Product.countDocuments(query)

    // Transform data to match frontend expectations
    const transformedProducts = vendorProducts.map((product) => ({
      id: product._id.toString(),
      name: product.name,
      description: product.description,
      price: product.price,
      stock: product.stock || product.stock_quantity || 0,
      category: product.category,
      size: product.size,
      vendorId: product.vendor_id ? product.vendor_id._id.toString() : product.vendor_id,
      vendorName: product.vendor_id ? product.vendor_id.name : "Unknown Vendor",
      images: product.image_url ? [`http://10.0.2.2:${PORT}/uploads/${product.image_url}`] : [],
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      status: product.status || "active",
    }))

    console.log(`📦 Found ${vendorProducts.length} vendor products (Total: ${total})`)

    res.json({
      success: true,
      products: transformedProducts,
      pagination: {
        current: Number.parseInt(page),
        pages: Math.ceil(total / limit),
        total,
        limit: Number.parseInt(limit),
      },
    })
  } catch (error) {
    console.error("❌ Error fetching vendor products:", error)
    res.status(500).json({
      success: false,
      error: "Failed to fetch vendor products",
      message: error.message,
    })
  }
})

// GET /api/vendor/products/:id - Get vendor product by ID
app.get("/api/vendor/products/:id", async (req, res) => {
  try {
    console.log(`🔍 Fetching vendor product with ID: ${req.params.id}`)

    const vendorProduct = await Product.findById(req.params.id).populate("vendor_id", "name email status")

    if (!vendorProduct) {
      console.log("❌ Vendor product not found")
      return res.status(404).json({
        success: false,
        error: "Vendor product not found",
      })
    }

    // Transform data to match frontend expectations
    const transformedProduct = {
      id: vendorProduct._id.toString(),
      name: vendorProduct.name,
      description: vendorProduct.description,
      price: vendorProduct.price,
      stock: vendorProduct.stock || vendorProduct.stock_quantity,
      category: vendorProduct.category,
      size: vendorProduct.size,
      vendorId: vendorProduct.vendor_id ? vendorProduct.vendor_id._id.toString() : vendorProduct.vendor_id,
      vendorName: vendorProduct.vendor_id ? vendorProduct.vendor_id.name : "Unknown Vendor",
      images: vendorProduct.image_url ? [`http://10.0.2.2:${PORT}/uploads/${vendorProduct.image_url}`] : [],
      createdAt: vendorProduct.createdAt,
      updatedAt: vendorProduct.updatedAt,
      status: vendorProduct.status || "active",
    }

    console.log(`✅ Retrieved vendor product: ${vendorProduct.name}`)
    res.json({
      success: true,
      product: transformedProduct,
    })
  } catch (error) {
    console.error("❌ Error fetching vendor product:", error)
    if (error.name === "CastError") {
      return res.status(400).json({
        success: false,
        error: "Invalid product ID format",
        message: error.message,
      })
    }
    res.status(500).json({
      success: false,
      error: "Failed to fetch vendor product",
      message: error.message,
    })
  }
})

// PUT /api/vendor/products/:id - Update vendor product
app.put("/api/vendor/products/:id", flexibleUpload, async (req, res) => {
  try {
    console.log(`\n🔄 === UPDATING VENDOR PRODUCT ===`)
    console.log(`Product ID: ${req.params.id}`)
    console.log("📝 Request Body:", JSON.stringify(req.body, null, 2))
    console.log(`📸 Files received: ${req.files ? req.files.length : 0}`)

    // Find the existing product first
    const existingProduct = await Product.findById(req.params.id)
    if (!existingProduct) {
      console.log("❌ Vendor product not found for update")
      return res.status(404).json({
        success: false,
        error: "Vendor product not found",
      })
    }

    console.log(`📋 Found existing vendor product: ${existingProduct.name}`)

    // Remove problematic fields
    const { _id, __v, createdAt, id, vendor_id, vendorId, ...cleanData } = req.body

    // Build update data object
    const updateData = {}

    // Update basic fields if provided
    if (cleanData.name !== undefined && cleanData.name.trim() !== "") {
      updateData.name = cleanData.name.trim()
    }
    if (cleanData.description !== undefined && cleanData.description.trim() !== "") {
      updateData.description = cleanData.description.trim()
    }
    if (cleanData.category !== undefined && cleanData.category.trim() !== "") {
      updateData.category = cleanData.category.trim()
    }

    // Handle price validation and update
    if (cleanData.price !== undefined && cleanData.price !== "") {
      const parsedPrice = Number.parseFloat(cleanData.price)
      if (isNaN(parsedPrice) || parsedPrice < 0) {
        return res.status(400).json({
          success: false,
          error: "Price must be a valid positive number",
          received: cleanData.price,
        })
      }
      updateData.price = parsedPrice
    }

    // Handle stock validation and update
    if (
      (cleanData.stock !== undefined && cleanData.stock !== "") ||
      (cleanData.stock_quantity !== undefined && cleanData.stock_quantity !== "")
    ) {
      const stockValue = cleanData.stock || cleanData.stock_quantity
      const parsedStock = Number.parseInt(stockValue)
      if (isNaN(parsedStock) || parsedStock < 0) {
        return res.status(400).json({
          success: false,
          error: "Stock must be a valid non-negative number",
          received: stockValue,
        })
      }
      updateData.stock_quantity = parsedStock
      updateData.stock = parsedStock
    }

    // Handle image updates
    if (req.files && req.files.length > 0) {
      const newImagePath = req.files[0].filename
      updateData.image_url = newImagePath
      console.log(`📸 New vendor image uploaded: ${newImagePath}`)
    }

    // Set updated timestamp
    updateData.updatedAt = new Date()

    console.log("🔄 Final vendor update data:", JSON.stringify(updateData, null, 2))

    // Perform the update
    const updatedProduct = await Product.findByIdAndUpdate(req.params.id, updateData, {
      new: true,
      runValidators: true,
    }).populate("vendor_id", "name email status")

    if (!updatedProduct) {
      return res.status(404).json({
        success: false,
        error: "Vendor product not found after update",
      })
    }

    console.log(`✅ Vendor product updated successfully: ${updatedProduct.name}`)

    // Transform response to match frontend expectations
    const transformedProduct = {
      id: updatedProduct._id.toString(),
      name: updatedProduct.name,
      description: updatedProduct.description,
      price: updatedProduct.price,
      stock: updatedProduct.stock || updatedProduct.stock_quantity,
      category: updatedProduct.category,
      size: updatedProduct.size,
      vendorId: updatedProduct.vendor_id ? updatedProduct.vendor_id._id.toString() : updatedProduct.vendor_id,
      vendorName: updatedProduct.vendor_id ? updatedProduct.vendor_id.name : "Unknown Vendor",
      images: updatedProduct.image_url ? [`http://10.0.2.2:${PORT}/uploads/${updatedProduct.image_url}`] : [],
      createdAt: updatedProduct.createdAt,
      updatedAt: updatedProduct.updatedAt,
      status: updatedProduct.status || "active",
    }

    res.json({
      success: true,
      message: "Vendor product updated successfully",
      product: transformedProduct,
      updatedFields: Object.keys(updateData),
    })
  } catch (error) {
    console.error("❌ Error updating vendor product:", error)
    if (error.name === "CastError") {
      return res.status(400).json({
        success: false,
        error: "Invalid product ID format",
        message: error.message,
      })
    }
    if (error.name === "ValidationError") {
      const validationErrors = Object.values(error.errors).map((e) => ({
        field: e.path,
        message: e.message,
        value: e.value,
      }))
      return res.status(400).json({
        success: false,
        error: "Validation failed",
        details: validationErrors,
      })
    }
    res.status(500).json({
      success: false,
      error: "Failed to update vendor product",
      message: error.message,
    })
  }
})

// ==================== OTHER ROUTES ====================

// GET /api/users - Get all users
app.get("/api/users", async (req, res) => {
  try {
    const users = await User.find().select("-password").sort({ createdAt: -1 })
    res.json({
      success: true,
      users,
    })
  } catch (error) {
    console.error("❌ Error fetching users:", error)
    res.status(500).json({
      success: false,
      error: "Failed to fetch users",
      message: error.message,
    })
  }
})

// GET /api/vendors - Get all vendors
app.get("/api/vendors", async (req, res) => {
  try {
    const vendors = await Vendor.find().sort({ createdAt: -1 })
    res.json({
      success: true,
      vendors,
    })
  } catch (error) {
    console.error("❌ Error fetching vendors:", error)
    res.status(500).json({
      success: false,
      error: "Failed to fetch vendors",
      message: error.message,
    })
  }
})

// PUT /api/vendors/:id - Update vendor status
app.put("/api/vendors/:id", async (req, res) => {
  try {
    const { status } = req.body
    const vendor = await Vendor.findByIdAndUpdate(req.params.id, { status }, { new: true })

    if (!vendor) {
      return res.status(404).json({
        success: false,
        error: "Vendor not found",
      })
    }

    console.log(`✅ Vendor ${vendor.name} status updated to: ${status}`)
    res.json({
      success: true,
      message: "Vendor status updated successfully",
      vendor,
    })
  } catch (error) {
    console.error("❌ Error updating vendor:", error)
    res.status(500).json({
      success: false,
      error: "Failed to update vendor",
      message: error.message,
    })
  }
})

// GET /api/orders - Get all orders
app.get("/api/orders", async (req, res) => {
  try {
    const orders = await Order.find().populate("customerId", "name email").sort({ createdAt: -1 })
    res.json({
      success: true,
      orders,
    })
  } catch (error) {
    console.error("❌ Error fetching orders:", error)
    res.status(500).json({
      success: false,
      error: "Failed to fetch orders",
      message: error.message,
    })
  }
})

// GET /api/reports - Get all reports
app.get("/api/reports", async (req, res) => {
  try {
    const reports = await Report.find()
      .populate("userId", "name email")
      .populate("orderId", "orderNumber totalAmount status")
      .sort({ createdAt: -1 })
    res.json({
      success: true,
      reports,
    })
  } catch (error) {
    console.error("❌ Error fetching reports:", error)
    res.status(500).json({
      success: false,
      error: "Failed to fetch reports",
      message: error.message,
    })
  }
})

// GET /api/admin/dashboard-stats - Get dashboard statistics
app.get("/api/admin/dashboard-stats", async (req, res) => {
  try {
    const [
      totalUsers,
      totalVendors,
      totalAdminProducts,
      totalVendorProducts,
      totalOrders,
      pendingOrders,
      pendingVendors,
      activeReports,
    ] = await Promise.all([
      User.countDocuments({ role: "user" }),
      Vendor.countDocuments(),
      AdminProduct.countDocuments(),
      Product.countDocuments(),
      Order.countDocuments(),
      Order.countDocuments({ status: "pending" }),
      Vendor.countDocuments({ status: "pending" }),
      Report.countDocuments({ status: { $in: ["pending", "in_progress"] } }),
    ])

    // Calculate total revenue
    const revenueResult = await Order.aggregate([
      { $match: { paymentStatus: "completed" } },
      { $group: { _id: null, total: { $sum: "$totalAmount" } } },
    ])
    const totalRevenue = revenueResult.length > 0 ? revenueResult[0].total : 0

    const stats = {
      totalUsers,
      totalVendors,
      totalProducts: totalAdminProducts + totalVendorProducts,
      totalAdminProducts,
      totalVendorProducts,
      totalOrders,
      totalRevenue,
      pendingOrders,
      pendingVendors,
      activeReports,
    }

    console.log("📊 Dashboard stats:", stats)
    res.json({
      success: true,
      stats,
    })
  } catch (error) {
    console.error("❌ Error fetching dashboard stats:", error)
    res.status(500).json({
      success: false,
      error: "Failed to fetch dashboard stats",
      message: error.message,
    })
  }
})

// GET /api/sizes/:category - Get available sizes for a category
app.get("/api/sizes/:category", (req, res) => {
  try {
    const { category } = req.params
    const sizeValidator = require("./utils/sizeValidator")

    const sizeOptions = sizeValidator.getSizeOptions(category)
    const isRequired = sizeValidator.isSizeRequired(category)

    res.json({
      success: true,
      category: category,
      sizeRequired: isRequired,
      sizes: sizeOptions,
      validSizes: sizeValidator.getValidSizes(category),
    })
  } catch (error) {
    console.error("❌ Error fetching sizes for category:", error)
    res.status(500).json({
      success: false,
      error: "Failed to fetch sizes",
      message: error.message,
    })
  }
})

// GET /api/size-categories - Get all categories that require sizes
app.get("/api/size-categories", (req, res) => {
  try {
    const sizeValidator = require("./utils/sizeValidator")

    res.json({
      success: true,
      sizeRequiredCategories: sizeValidator.SIZE_REQUIRED_CATEGORIES,
      shoeSizes: sizeValidator.SHOE_SIZES,
      clothingSizes: sizeValidator.CLOTHING_SIZES,
    })
  } catch (error) {
    console.error("❌ Error fetching size categories:", error)
    res.status(500).json({
      success: false,
      error: "Failed to fetch size categories",
      message: error.message,
    })
  }
})

// Serve uploaded images
app.use("/uploads", express.static(path.join(__dirname, "uploads")))

// Health check endpoint
app.get("/api/health", (req, res) => {
  res.json({
    status: "OK",
    message: "Admin Dashboard API is running",
    timestamp: new Date().toISOString(),
    database: "MongoDB",
    connection: mongoose.connection.readyState === 1 ? "Connected" : "Disconnected",
    endpoints: {
      adminProducts: "/api/admin/products",
      vendorProducts: "/api/vendor/products",
    },
  })
})

// Test endpoint to list uploaded files
app.get("/api/test-images", (req, res) => {
  try {
    const files = fs.readdirSync(uploadsDir)
    const imageFiles = files.filter((file) => file.match(/\.(jpg|jpeg|png|gif|webp)$/i))

    const imageUrls = imageFiles.map((file) => ({
      filename: file,
      url: `http://10.0.2.2:${PORT}/uploads/${file}`,
      localUrl: `http://localhost:${PORT}/uploads/${file}`,
      path: path.join(uploadsDir, file),
      exists: fs.existsSync(path.join(uploadsDir, file)),
      size: fs.existsSync(path.join(uploadsDir, file)) ? fs.statSync(path.join(uploadsDir, file)).size : 0,
    }))

    res.json({
      success: true,
      uploadsDir,
      totalFiles: files.length,
      imageFiles: imageFiles.length,
      images: imageUrls,
      serverInfo: {
        port: PORT,
        androidEmulatorUrl: `http://10.0.2.2:${PORT}`,
        localUrl: `http://localhost:${PORT}`,
      },
    })
  } catch (error) {
    console.error("Error reading uploads directory:", error)
    res.status(500).json({
      success: false,
      error: error.message,
      uploadsDir,
      dirExists: fs.existsSync(uploadsDir),
    })
  }
})

// Test endpoint to check specific image
app.get("/api/test-image/:filename", (req, res) => {
  try {
    const filename = req.params.filename
    const imagePath = path.join(uploadsDir, filename)

    console.log(`🧪 Testing image: ${filename}`)
    console.log(`📁 Full path: ${imagePath}`)
    console.log(`📋 File exists: ${fs.existsSync(imagePath)}`)

    if (!fs.existsSync(imagePath)) {
      return res.status(404).json({
        success: false,
        error: "Image not found",
        filename,
        path: imagePath,
        uploadsDir,
        availableFiles: fs.readdirSync(uploadsDir),
      })
    }

    const stats = fs.statSync(imagePath)
    const mimeType = filename.endsWith(".webp")
      ? "image/webp"
      : filename.endsWith(".png")
        ? "image/png"
        : filename.endsWith(".jpg") || filename.endsWith(".jpeg")
          ? "image/jpeg"
          : "application/octet-stream"

    res.json({
      success: true,
      filename,
      path: imagePath,
      exists: true,
      size: stats.size,
      mimeType,
      androidUrl: `http://10.0.2.2:${PORT}/uploads/${filename}`,
      localUrl: `http://localhost:${PORT}/uploads/${filename}`,
      lastModified: stats.mtime,
    })
  } catch (error) {
    console.error("Error testing image:", error)
    res.status(500).json({
      success: false,
      error: error.message,
    })
  }
})

// Test endpoint to check database connection
app.get("/api/test-db", async (req, res) => {
  try {
    const collections = await mongoose.connection.db.listCollections().toArray()
    const collectionNames = collections.map((c) => c.name)

    res.json({
      status: "OK",
      database: mongoose.connection.name,
      collections: collectionNames,
      adminProductsExists: collectionNames.includes("adminproducts"),
      vendorProductsExists: collectionNames.includes("vendorproducts"),
    })
  } catch (error) {
    res.status(500).json({
      error: "Database test failed",
      message: error.message,
    })
  }
})

// Error handling middleware
app.use((err, req, res, next) => {
  console.error("💥 Unhandled error:", err.stack)
  res.status(500).json({
    success: false,
    error: "Something went wrong!",
    message: err.message,
  })
})

// 404 handler
app.use("*", (req, res) => {
  console.log(`❌ Route not found: ${req.method} ${req.originalUrl}`)
  res.status(404).json({
    success: false,
    error: "Route not found",
    availableEndpoints: [
      "GET /api/health",
      "GET /api/test-db",
      "GET /api/test-images",
      "GET /api/test-image/:filename",
      "GET /api/admin/products",
      "POST /api/admin/products",
      "PUT /api/admin/products/:id",
      "DELETE /api/admin/products/:id",
      "GET /api/vendor/products",
      "PUT /api/vendor/products/:id",
      "GET /api/users",
      "GET /api/vendors",
      "GET /api/orders",
      "GET /api/reports",
      "GET /api/admin/dashboard-stats",
    ],
  })
})

// Start server
const startServer = async () => {
  try {
    await connectDB()

    app.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`)
      console.log(`🌐 API Base URL: http://localhost:${PORT}`)
      console.log(`🏥 Health Check: http://localhost:${PORT}/api/health`)
      console.log(`🧪 Database Test: http://localhost:${PORT}/api/test-db`)
      console.log(`📋 Available endpoints:`)
      console.log(`   === ADMIN PRODUCTS ===`)
      console.log(`   - POST /api/admin/products`)
      console.log(`   - GET  /api/admin/products`)
      console.log(`   - GET  /api/admin/products/:id`)
      console.log(`   - PUT  /api/admin/products/:id`)
      console.log(`   - DELETE /api/admin/products/:id`)
      console.log(`   === VENDOR PRODUCTS ===`)
      console.log(`   - GET  /api/vendor/products`)
      console.log(`   - PUT  /api/vendor/products/:id`)
      console.log(`   === OTHER ENDPOINTS ===`)
      console.log(`   - GET  /api/users`)
      console.log(`   - GET  /api/vendors`)
      console.log(`   - GET  /api/orders`)
      console.log(`   - GET  /api/reports`)
      console.log(`   - GET  /api/admin/dashboard-stats`)
    })
  } catch (error) {
    console.error("❌ Failed to start server:", error)
    process.exit(1)
  }
}

startServer()

// Graceful shutdown
process.on("SIGINT", async () => {
  console.log("\n🛑 Shutting down server...")
  await mongoose.connection.close()
  console.log("✅ Database connection closed")
  process.exit(0)
})

module.exports = app
