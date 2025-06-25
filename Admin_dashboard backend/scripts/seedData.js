const mongoose = require("mongoose")
const dotenv = require("dotenv")
const bcrypt = require("bcryptjs")

// Import models (these should match your actual model files)
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

const generateOrderNumber = () => {
  const timestamp = Date.now()
  const random = Math.floor(Math.random() * 10000)
    .toString()
    .padStart(4, "0")
  return `ORD-${timestamp}-${random}`
}

const hashPassword = async (password) => {
  const salt = await bcrypt.genSalt(10)
  return await bcrypt.hash(password, salt)
}

const seedDatabase = async () => {
  try {
    console.log("🌱 Starting database seeding...")

    // Clear existing data and drop problematic indexes
    await Promise.all([
      User.deleteMany({}),
      Vendor.deleteMany({}),
      Product.deleteMany({}),
      AdminProduct.deleteMany({}),
      Order.deleteMany({}),
    ])

    // Drop the orders collection to remove any problematic indexes
    try {
      await mongoose.connection.db.collection("orders").drop()
      console.log("🗑️  Dropped orders collection and indexes")
    } catch (error) {
      console.log("ℹ️  Orders collection didn't exist or couldn't be dropped")
    }

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

    // Find the admin user for creating admin products
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

    // Create sample vendor products - providing both field names for compatibility
    if (createdVendors.length === 0) {
      console.log("⚠️  No vendors created, skipping vendor products creation")
      return
    }

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
        stock: 50,
        category: "Shoes",
        vendor_id: createdVendors[0]._id,
        vendorId: createdVendors[0]._id,
        image_url: "shoe5.jpg",
        status: "active",
      },

      {
        name: " TECH Smart Watch",
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
        name: "NoiseFit Halo Smartwatch",
        description: "Tracks steps, heart rate, and sleep with precision.",
        price: 899.99,
        stock_quantity: 20,
        stock: 20,
        category: "Electronics",
        vendor_id: createdVendors[0]._id,
        vendorId: createdVendors[0]._id,
        image_url: "smartwatch2.webp",
        status: "active",
      },
      {
        name: "Titan Heritage",
        description: " Premium build with customizable watch faces and apps.",
        price: 1899.99,
        stock_quantity: 20,
        stock: 20,
        category: "Electronics",
        vendor_id: createdVendors[0]._id,
        vendorId: createdVendors[0]._id,
        image_url: "smartwatch3.jpg",
        status: "active",
      },
      {
        name: "Designer Jacket",
        description: "Stylish designer jacket for all seasons, made with premium materials",
        price: 749.99,
        stock_quantity: 25,
        stock: 25,
        category: "Fashion",
        vendor_id: createdVendors[1]._id,
        vendorId: createdVendors[1]._id,
        image_url: "womenswear4.webp",
        status: "active", // Changed from "pending" to "active"
      },
      {
        name: "Short Sleeves Casual Shirt",
        description: "Soft, breathable fabric perfect for everyday",
        price: 549.99,
        stock_quantity: 25,
        stock: 25,
        category: "Menswear",
        vendor_id: createdVendors[1]._id,
        vendorId: createdVendors[1]._id,
        image_url: "menswear.webp",
        status: "active", // Changed from "pending" to "active"
      },
      {
        name: "Oversized Corduroy Casual Shirt",
        description: "Soft, breathable fabric perfect for everyday",
        price: 649.99,
        stock_quantity: 25,
        stock: 25,
        category: "Menswear",
        vendor_id: createdVendors[1]._id,
        vendorId: createdVendors[1]._id,
        image_url: "menswear1.webp",
        status: "active", // Changed from "pending" to "active"
      },

      {
        name: " Maniac Striped Round Neck T-shirt",
        description: "Comfortable and versatile, great for both work and weekends.",
        price: 249.99,
        stock_quantity: 25,
        stock: 25,
        category: "Menswear",
        vendor_id: createdVendors[1]._id,
        vendorId: createdVendors[1]._id,
        image_url: "menswear3.webp",
        status: "active", // Changed from "pending" to "active"
      },
      {
        name: "Rainbow Women's Floral Printed Bell Sleeve Top",
        description: "Soft, breathable fabric perfect for everyday",
        price: 549.99,
        stock_quantity: 25,
        stock: 25,
        category: "Womenswear",
        vendor_id: createdVendors[1]._id,
        vendorId: createdVendors[1]._id,
        image_url: "womenswear1.webp",
        status: "active", // Changed from "pending" to "active"
      },
      {
        name: "Women's Oversized Korean Casual Shirt",
        description: "Soft, breathable fabric perfect for everyday",
        price: 649.99,
        stock_quantity: 25,
        stock: 25,
        category: "Womenswear",
        vendor_id: createdVendors[1]._id,
        vendorId: createdVendors[1]._id,
        image_url: "womenswear2.webp",
        status: "active", // Changed from "pending" to "active"
      },

      {
        name: " Libas Women's Printed Straight Kurta Set",
        description: "Comfortable and versatile, great for both work and weekends.",
        price: 449.99,
        stock_quantity: 25,
        stock: 25,
        category: "Womenswear",
        vendor_id: createdVendors[1]._id,
        vendorId: createdVendors[1]._id,
        image_url: "womenswear3.webp",
        status: "active", // Changed from "pending" to "active"
      },

      {
        name: "Samsung Galaxy S25 Ultra 5G",
        description: " High-speed performance with top-tier camera and display",
        price: 122249.99,
        stock_quantity: 15,
        stock: 15,
        category: "Electronics",
        vendor_id: createdVendors[2]._id,
        vendorId: createdVendors[2]._id,
        image_url: "electro.webp",
        status: "active",
      },
      {
        name: "BoAt Airdopes 311 PRO ",
        description: " High-speed performance with top-tier camera and display",
        price: 799.99,
        stock_quantity: 19,
        stock: 19,
        category: "Electronics",
        vendor_id: createdVendors[2]._id,
        vendorId: createdVendors[2]._id,
        image_url: "electro1.webp",
        status: "active",
      },
      {
        name: "15-inch MacBook Air Apple",
        description: " High-speed performance with top-tier camera and display",
        price: 172249.99,
        stock_quantity: 15,
        stock: 15,
        category: "Electronics",
        vendor_id: createdVendors[2]._id,
        vendorId: createdVendors[2]._id,
        image_url: "electro2.webp",
        status: "active",
      },
      {
        name: "Noise Two Wireless Headphones ",
        description: " High-speed performance with top-tier camera and display",
        price: 1799.99,
        stock_quantity: 19,
        stock: 19,
        category: "Electronics",
        vendor_id: createdVendors[2]._id,
        vendorId: createdVendors[2]._id,
        image_url: "electro3.webp",
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
      {
        name: "Creamy Matte Lipstick",
        description: "Long lasting for 10hrs and smudge proof",
        price: 399.99,
        stock_quantity: 15,
        stock: 15,
        category: "Cosmetics",
        vendor_id: createdVendors[3]._id,
        vendorId: createdVendors[3]._id,
        image_url: "cosmetics.webp",
        status: "active",
      },
      {
        name: "Makeup Kit",
        description: "Easy to blend with a natural, dewy glow.",
        price: 599.99,
        stock_quantity: 5,
        stock: 5,
        category: "Cosmetics",
        vendor_id: createdVendors[3]._id,
        vendorId: createdVendors[3]._id,
        image_url: "cosmetics1.webp",
        status: "active",
      },
      {
        name: "Foundation Stick SUGAR Cosmetics",
        description: "Lightweight coverage that blends seamlessly for a flawless look.",
        price: 799.99,
        stock_quantity: 25,
        stock: 25,
        category: "Cosmetics",
        vendor_id: createdVendors[3]._id,
        vendorId: createdVendors[3]._id,
        image_url: "cosmetics2.webp",
        status: "active",
      },
    ]

    // Insert vendor products one by one to handle validation issues
    console.log("📦 Creating vendor products...")
    const createdVendorProducts = []
    for (let i = 0; i < vendorProducts.length; i++) {
      try {
        console.log(`   Creating product ${i + 1}: ${vendorProducts[i].name}`)
        console.log(`   Vendor ID: ${vendorProducts[i].vendor_id}`)

        const product = new Product(vendorProducts[i])
        const savedProduct = await product.save()
        createdVendorProducts.push(savedProduct)
        console.log(`   ✅ Created: ${savedProduct.name}`)
      } catch (error) {
        console.error(`   ❌ Failed to create product ${vendorProducts[i].name}:`, error.message)
        if (error.errors) {
          Object.keys(error.errors).forEach((key) => {
            console.error(`     - ${key}: ${error.errors[key].message}`)
          })
        }
      }
    }
    console.log(`📦 Successfully created ${createdVendorProducts.length} vendor products`)

    // Create sample admin products - providing both field names for compatibility
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
        console.log(`   Created by: ${adminProducts[i].created_by}`)

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

    // Create sample orders only if we have products
    if (createdVendorProducts.length > 0 && createdAdminProducts.length > 0) {
      console.log("📋 Creating orders...")

      const orders = [
        {
          customerId: createdUsers[0]._id,
          customerName: createdUsers[0].name,
          customerEmail: createdUsers[0].email,
          items: [
            {
              productId: createdVendorProducts[0]._id,
              productName: createdVendorProducts[0].name,
              quantity: 1,
              price: createdVendorProducts[0].price,
              vendorId: createdVendorProducts[0].vendor_id,
            },
          ],
          totalAmount: createdVendorProducts[0].price + 20 + createdVendorProducts[0].price * 0.08,
          status: "delivered",
          paymentStatus: "completed",
          paymentMethod: "credit_card",
          shippingAddress: {
            street: "123 Main Street",
            city: "Anytown",
            state: "CA",
            zipCode: "12345",
            country: "USA",
            fullAddress: "123 Main Street, Anytown, CA 12345",
          },
          trackingNumber: "TRK123456789",
          estimatedDelivery: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
          actualDelivery: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
        },
        {
          customerId: createdUsers[1]._id,
          customerName: createdUsers[1].name,
          customerEmail: createdUsers[1].email,
          items: [
            {
              productId: createdAdminProducts[0]._id,
              productName: createdAdminProducts[0].name,
              quantity: 1,
              price: createdAdminProducts[0].price,
              vendorId: "admin",
            },
          ],
          totalAmount: createdAdminProducts[0].price + 25 + createdAdminProducts[0].price * 0.08,
          status: "processing",
          paymentStatus: "completed",
          paymentMethod: "paypal",
          shippingAddress: {
            street: "456 Oak Avenue",
            city: "Another City",
            state: "NY",
            zipCode: "67890",
            country: "USA",
            fullAddress: "456 Oak Avenue, Another City, NY 67890",
          },
          estimatedDelivery: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000),
        },
        {
          customerId: createdUsers[2]._id,
          customerName: createdUsers[2].name,
          customerEmail: createdUsers[2].email,
          items: [
            {
              productId: createdVendorProducts[1]._id,
              productName: createdVendorProducts[1].name,
              quantity: 2,
              price: createdVendorProducts[1].price,
              vendorId: createdVendorProducts[1].vendor_id,
            },
            {
              productId: createdAdminProducts[2]._id,
              productName: createdAdminProducts[2].name,
              quantity: 1,
              price: createdAdminProducts[2].price,
              vendorId: "admin",
            },
          ],
          totalAmount:
            createdVendorProducts[1].price * 2 +
            createdAdminProducts[2].price +
            30 +
            (createdVendorProducts[1].price * 2 + createdAdminProducts[2].price) * 0.08,
          status: "shipped",
          paymentStatus: "completed",
          paymentMethod: "debit_card",
          shippingAddress: {
            street: "789 Pine Road",
            city: "Third City",
            state: "TX",
            zipCode: "54321",
            country: "USA",
            fullAddress: "789 Pine Road, Third City, TX 54321",
          },
          trackingNumber: "TRK987654321",
          estimatedDelivery: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000),
        },
      ]

      // Insert orders one by one with proper error handling
      let createdOrdersCount = 0
      for (let i = 0; i < orders.length; i++) {
        try {
          const orderData = orders[i]
          const order = new Order(orderData)
          await order.save()
          createdOrdersCount++
          console.log(`   ✅ Order ${createdOrdersCount}: ${order._id}`)
        } catch (error) {
          console.error(`   ❌ Failed to create order ${i + 1}: ${error.message}`)
          if (error.errors) {
            Object.keys(error.errors).forEach((key) => {
              console.error(`     - ${key}: ${error.errors[key].message}`)
            })
          }
        }
      }

      console.log("✅ Database seeding completed successfully!")
      console.log("\n📊 Summary:")
      console.log(`   - Users: ${createdUsers.length} (including 1 admin)`)
      console.log(`   - Vendors: ${createdVendors.length}`)
      console.log(`   - Vendor Products: ${createdVendorProducts.length}`)
      console.log(`   - Admin Products: ${createdAdminProducts.length}`)
      console.log(`   - Orders: ${createdOrdersCount}`)
    } else {
      console.log("⚠️  Skipping order creation due to missing products")
      console.log("\n📊 Summary:")
      console.log(`   - Users: ${createdUsers.length} (including 1 admin)`)
      console.log(`   - Vendors: ${createdVendors.length}`)
      console.log(`   - Vendor Products: ${createdVendorProducts.length}`)
      console.log(`   - Admin Products: ${createdAdminProducts.length}`)
      console.log(`   - Orders: 0`)
    }

    console.log("\n🔑 Login Credentials:")
    console.log("Admin:")
    console.log(`   Email: ${process.env.DEFAULT_ADMIN_EMAIL || "admin@example.com"}`)
    console.log(`   Password: ${process.env.DEFAULT_ADMIN_PASSWORD || "admin123"}`)

    console.log("\nSample Vendor:")
    console.log(`   Email: tech@store.com`)
    console.log(`   Password: vendor123`)

    console.log("\nSample User:")
    console.log(`   Email: john@example.com`)
    console.log(`   Password: password123`)

    console.log("\n🌐 Backend Server:")
    console.log(`   Start with: npm start`)
    console.log(`   URL: http://localhost:${process.env.PORT || 3003}`)
    console.log(`   Health Check: http://localhost:${process.env.PORT || 3003}/api/health`)
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
