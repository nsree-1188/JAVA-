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
    console.log("✅ MongoDB connected for safe seeding")
  } catch (error) {
    console.error("❌ MongoDB connection error:", error)
    process.exit(1)
  }
}

const hashPassword = async (password) => {
  const salt = await bcrypt.genSalt(10)
  return await bcrypt.hash(password, salt)
}

const seedDatabaseSafe = async () => {
  try {
    console.log("🌱 Starting SAFE database seeding (preserves existing products)...")

    // Check existing data counts
    const existingUsers = await User.countDocuments()
    const existingVendors = await Vendor.countDocuments()
    const existingAdminProducts = await AdminProduct.countDocuments()
    const existingVendorProducts = await Product.countDocuments()

    console.log("📊 Current database state:")
    console.log(`   - Users: ${existingUsers}`)
    console.log(`   - Vendors: ${existingVendors}`)
    console.log(`   - Admin Products: ${existingAdminProducts}`)
    console.log(`   - Vendor Products: ${existingVendorProducts}`)

    // Only add data if it doesn't exist

    // Add admin user if none exists
    let adminUser = await User.findOne({ role: "admin" })
    if (!adminUser) {
      console.log("👤 Creating admin user...")
      adminUser = new User({
        name: "Admin User",
        email: process.env.DEFAULT_ADMIN_EMAIL || "admin@example.com",
        password: await hashPassword(process.env.DEFAULT_ADMIN_PASSWORD || "admin123"),
        role: "admin",
        status: "active",
        phone: "+1234567893",
        address: "Admin Office, Business District",
      })
      await adminUser.save()
      console.log("✅ Admin user created")
    } else {
      console.log("ℹ️  Admin user already exists")
    }

    // Add sample users if none exist
    if (existingUsers === 0 || (existingUsers === 1 && adminUser)) {
      console.log("👥 Adding sample users...")
      const sampleUsers = [
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
      ]

      for (const userData of sampleUsers) {
        const existingUser = await User.findOne({ email: userData.email })
        if (!existingUser) {
          const user = new User(userData)
          await user.save()
          console.log(`   ✅ Created user: ${userData.name}`)
        } else {
          console.log(`   ℹ️  User already exists: ${userData.name}`)
        }
      }
    } else {
      console.log("ℹ️  Users already exist, skipping user creation")
    }

    // Add sample vendors if none exist
    if (existingVendors === 0) {
      console.log("🏪 Adding sample vendors...")
      const sampleVendors = [
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
      ]

      for (const vendorData of sampleVendors) {
        const existingVendor = await Vendor.findOne({ email: vendorData.email })
        if (!existingVendor) {
          const vendor = new Vendor(vendorData)
          await vendor.save()
          console.log(`   ✅ Created vendor: ${vendorData.name}`)
        } else {
          console.log(`   ℹ️  Vendor already exists: ${vendorData.name}`)
        }
      }
    } else {
      console.log("ℹ️  Vendors already exist, skipping vendor creation")
    }

    // Add sample admin products ONLY if none exist
    if (existingAdminProducts === 0) {
      console.log("🏢 Adding sample admin products...")
      const sampleAdminProducts = [
        {
          name: "Sample Laptop",
          description: "Sample laptop for testing purposes",
          price: 999.99,
          stock_quantity: 10,
          stock: 10,
          category: "Electronics",
          created_by: adminUser._id,
          image_url: "",
          status: "active",
        },
        {
          name: "Sample Chair",
          description: "Sample office chair for testing",
          price: 299.99,
          stock_quantity: 15,
          stock: 15,
          category: "Furniture",
          created_by: adminUser._id,
          image_url: "",
          status: "active",
        },
      ]

      for (const productData of sampleAdminProducts) {
        const existingProduct = await AdminProduct.findOne({ name: productData.name })
        if (!existingProduct) {
          const product = new AdminProduct(productData)
          await product.save()
          console.log(`   ✅ Created admin product: ${productData.name}`)
        } else {
          console.log(`   ℹ️  Admin product already exists: ${productData.name}`)
        }
      }
    } else {
      console.log("ℹ️  Admin products already exist, preserving existing products")
      console.log("🎉 Your manually added products are safe!")
    }

    // Final count
    const finalUsers = await User.countDocuments()
    const finalVendors = await Vendor.countDocuments()
    const finalAdminProducts = await AdminProduct.countDocuments()
    const finalVendorProducts = await Product.countDocuments()

    console.log("\n✅ Safe seeding completed!")
    console.log("📊 Final database state:")
    console.log(`   - Users: ${finalUsers}`)
    console.log(`   - Vendors: ${finalVendors}`)
    console.log(`   - Admin Products: ${finalAdminProducts} (YOUR PRODUCTS ARE PRESERVED!)`)
    console.log(`   - Vendor Products: ${finalVendorProducts}`)

    console.log("\n🔑 Login Credentials:")
    console.log("Admin:")
    console.log(`   Email: ${process.env.DEFAULT_ADMIN_EMAIL || "admin@example.com"}`)
    console.log(`   Password: ${process.env.DEFAULT_ADMIN_PASSWORD || "admin123"}`)
  } catch (error) {
    console.error("❌ Error in safe seeding:", error)
    console.error("Stack trace:", error.stack)
  } finally {
    await mongoose.connection.close()
    console.log("🔌 Database connection closed")
    process.exit(0)
  }
}

// Run the safe seeder
connectDB().then(() => {
  seedDatabaseSafe()
})
