const mongoose = require("mongoose")
const dotenv = require("dotenv")
const bcrypt = require("bcryptjs")

// Import models
const User = require("../models/User")
const Vendor = require("../models/Vendor")
const Product = require("../models/VendorProduct")
const AdminProduct = require("../models/AdminProduct")
const Order = require("../models/Order")

dotenv.config()

const connectDB = async () => {
  try {
    const mongoURI = process.env.MONGODB_URI || "mongodb://localhost:27017/admin_dashboard"
    await mongoose.connect(mongoURI)
    console.log("✅ MongoDB connected for seeding")
  } catch (error) {
    console.error("❌ MongoDB connection error:", error)
    process.exit(1)
  }
}

const hashPassword = async (password) => {
  const salt = await bcrypt.genSalt(10)
  return await bcrypt.hash(password, salt)
}

const seedDatabase = async () => {
  try {
    console.log("🌱 Starting database seeding...")

    // Clear existing data
    await Promise.all([
      User.deleteMany({}),
      Vendor.deleteMany({}),
      Product.deleteMany({}),
      AdminProduct.deleteMany({}),
      Order.deleteMany({}),
    ])

    console.log("🗑️  Cleared existing data")

    // Create sample users
    const users = [
      {
        name: "John Doe",
        email: "john@example.com",
        password: await hashPassword("password123"),
        role: "user",
        status: "active",
        phone: "+1234567890",
        address: "123 Main Street, Anytown, CA 12345",
      },
      {
        name: "Jane Smith",
        email: "jane@example.com",
        password: await hashPassword("password123"),
        role: "user",
        status: "active",
        phone: "+1234567891",
        address: "456 Oak Avenue, Another City, NY 67890",
      },
      {
        name: "Bob Wilson",
        email: "bob@example.com",
        password: await hashPassword("password123"),
        role: "user",
        status: "inactive",
        phone: "+1234567892",
        address: "789 Pine Road, Third City, TX 54321",
      },
      {
        name: "Admin User",
        email: process.env.DEFAULT_ADMIN_EMAIL || "admin@example.com",
        password: await hashPassword(process.env.DEFAULT_ADMIN_PASSWORD || "admin123"),
        role: "admin",
        status: "active",
        phone: "+1234567893",
        address: "Admin Office, Business District",
      },
    ]

    const createdUsers = await User.insertMany(users)
    console.log(`👥 Created ${createdUsers.length} users (including admin)`)

    const adminUser = createdUsers.find((user) => user.role === "admin")

    // Create sample vendors
    const vendors = [
      {
        name: "Tech Store Inc",
        email: "tech@store.com",
        phone: "+1234567890",
        address: "123 Tech Street, Silicon Valley, CA",
        status: "approved",
        businessName: "Tech Store Inc",
        businessType: "Electronics",
      },
      {
        name: "Fashion Hub",
        email: "fashion@hub.com",
        phone: "+1234567891",
        address: "456 Fashion Ave, New York, NY",
        status: "pending",
        businessName: "Fashion Hub",
        businessType: "Fashion",
      },
      {
        name: "Home Goods Co",
        email: "home@goods.com",
        phone: "+1234567892",
        address: "789 Home Street, Chicago, IL",
        status: "approved",
        businessName: "Home Goods Co",
        businessType: "Home & Garden",
      },
      {
        name: "Sports World",
        email: "sports@world.com",
        phone: "+1234567893",
        address: "321 Sports Blvd, Miami, FL",
        status: "approved",
        businessName: "Sports World",
        businessType: "Sports",
      },
    ]

    const createdVendors = await Vendor.insertMany(vendors)
    console.log(`🏪 Created ${createdVendors.length} vendors`)

    // Create sample vendor products (FIXED - removed size field)
    const vendorProducts = [
      {
        name: "Black Leather Loafers",
        description: "Sleek, stylish, and ideal for office wear or formal events.",
        price: 599.99,
        stock_quantity: 50,
        stock: 50,
        category: "Shoes",
        vendor_id: createdVendors[0]._id,
        vendorId: createdVendors[0]._id,
        image_url: "shoe2.jpg",
        status: "active",
      },
      {
        name: "Chunky Running Shoes",
        description: "Lightweight and cushioned for all-day comfort and athletic performance.",
        price: 799.99,
        stock_quantity: 20,
        stock: 20,
        category: "Shoes",
        vendor_id: createdVendors[0]._id,
        vendorId: createdVendors[0]._id,
        image_url: "shoe3.jpg",
        status: "active",
      },
      {
        name: "Leather Loafers",
        description: "Polished and professional, perfect for work or formal events.",
        price: 999.99,
        stock_quantity: 20,
        stock: 20,
        category: "Shoes",
        vendor_id: createdVendors[0]._id,
        vendorId: createdVendors[0]._id,
        image_url: "shoe4.jpg",
        status: "active",
      },
      {
        name: "Sports Trainers",
        description: "Sleek, stylish, and ideal for office wear or formal events.",
        price: 599.99,
        stock_quantity: 30,
        stock: 30,
        category: "Shoes",
        vendor_id: createdVendors[0]._id,
        vendorId: createdVendors[0]._id,
        image_url: "shoe5.jpg",
        status: "active",
      },
      {
        name: "TECH Smart Watch",
        description: "Feature-rich smartwatch with health monitoring, GPS, and water resistance",
        price: 699.99,
        stock_quantity: 30,
        stock: 30,
        category: "Electronics",
        vendor_id: createdVendors[0]._id,
        vendorId: createdVendors[0]._id,
        image_url: "smartwatch1.jpg",
        status: "active",
      },
      {
        name: "Running Shoes",
        description: "Professional running shoes with advanced cushioning technology",
        price: 129.99,
        stock_quantity: 40,
        stock: 40,
        category: "Shoes",
        vendor_id: createdVendors[3]._id,
        vendorId: createdVendors[3]._id,
        image_url: "shoe6.jpg",
        status: "active",
      },
    ]

    console.log("📦 Creating vendor products...")
    const createdVendorProducts = []
    for (let i = 0; i < vendorProducts.length; i++) {
      try {
        console.log(`   Creating product ${i + 1}: ${vendorProducts[i].name}`)
        const product = new Product(vendorProducts[i])
        const savedProduct = await product.save()
        createdVendorProducts.push(savedProduct)
        console.log(`   ✅ Created: ${savedProduct.name}`)
      } catch (error) {
        console.error(`   ❌ Failed to create product ${vendorProducts[i].name}:`, error.message)
      }
    }
    console.log(`📦 Successfully created ${createdVendorProducts.length} vendor products`)

    // Create sample admin products (FIXED - flexible categories)
    const adminProducts = [
      {
        name: "Athleisure Shoes for Men",
        description: "Timeless and versatile, perfect for casual outfits or weekend strolls",
        price: 699,
        stock_quantity: 20,
        stock: 20,
        category: "Shoes",
        created_by: adminUser._id,
        image_url: "shoe1.jpg",
        status: "active",
      },
      {
        name: "Lakme 9to5 Primer",
        description: "Bold, long-lasting color with a smooth, non-drying finish",
        price: 399.99,
        stock_quantity: 35,
        stock: 35,
        category: "Cosmetics",
        created_by: adminUser._id,
        image_url: "cosmetics4.webp",
        status: "active",
      },
      {
        name: "Wireless Mouse",
        description: "Precision wireless mouse for productivity with long battery life",
        price: 549.99,
        stock_quantity: 100,
        stock: 100,
        category: "Electronics",
        created_by: adminUser._id,
        image_url: "electro4.webp",
        status: "active",
      },
      {
        name: "Fitness Smartwatch",
        description: "Tracks steps, heart rate, and sleep with precision.",
        price: 1079.99,
        stock_quantity: 60,
        stock: 60,
        category: "Electronics",
        created_by: adminUser._id,
        image_url: "electro5.webp",
        status: "active",
      },
      {
        name: "Mechanical Keyboard",
        description: "Professional mechanical keyboard with RGB backlighting",
        price: 1159.99,
        stock_quantity: 45,
        stock: 45,
        category: "Electronics",
        created_by: adminUser._id,
        image_url: "electro7.webp",
        status: "active",
      },
    ]

    console.log("🏢 Creating admin products...")
    const createdAdminProducts = []
    for (let i = 0; i < adminProducts.length; i++) {
      try {
        console.log(`   Creating admin product ${i + 1}: ${adminProducts[i].name}`)
        const product = new AdminProduct(adminProducts[i])
        const savedProduct = await product.save()
        createdAdminProducts.push(savedProduct)
        console.log(`   ✅ Created: ${savedProduct.name}`)
      } catch (error) {
        console.error(`   ❌ Failed to create admin product ${adminProducts[i].name}:`, error.message)
        if (error.errors) {
          Object.keys(error.errors).forEach((key) => {
            console.error(`     - ${key}: ${error.errors[key].message}`)
          })
        }
      }
    }
    console.log(`🏢 Successfully created ${createdAdminProducts.length} admin products`)

    console.log("✅ Database seeding completed successfully!")
    console.log("\n📊 Summary:")
    console.log(`   - Users: ${createdUsers.length} (including 1 admin)`)
    console.log(`   - Vendors: ${createdVendors.length}`)
    console.log(`   - Vendor Products: ${createdVendorProducts.length}`)
    console.log(`   - Admin Products: ${createdAdminProducts.length}`)

    console.log("\n🔑 Login Credentials:")
    console.log("Admin:")
    console.log(`   Email: ${process.env.DEFAULT_ADMIN_EMAIL || "admin@example.com"}`)
    console.log(`   Password: ${process.env.DEFAULT_ADMIN_PASSWORD || "admin123"}`)

  } catch (error) {
    console.error("❌ Error seeding database:", error)
    console.error("Stack trace:", error.stack)
  } finally {
    await mongoose.connection.close()
    console.log("🔌 Database connection closed")
    process.exit(0)
  }
}

// Run the seeder
connectDB().then(() => {
  seedDatabase()
})