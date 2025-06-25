const Admin = require("../models/Admin")
const User = require("../models/User")
const Vendor = require("../models/Vendor")
const Product = require("../models/Product")
const Order = require("../models/Order")
const Report = require("../models/Report")
const jwt = require("jsonwebtoken")
const bcrypt = require("bcryptjs")

// Generate JWT Token
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRE,
  })
}

// @desc    Login admin
// @route   POST /api/admin/login
// @access  Public
const loginAdmin = async (req, res) => {
  try {
    const { email, password } = req.body

    // Check if email and password are provided
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Please provide email and password",
      })
    }

    // Check for admin
    const admin = await Admin.findOne({ email }).select("+password")

    if (!admin) {
      return res.status(401).json({
        success: false,
        message: "Invalid credentials",
      })
    }

    // Check if password matches
    const isMatch = await admin.matchPassword(password)

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Invalid credentials",
      })
    }

    // Check if admin is active
    if (!admin.isActive) {
      return res.status(401).json({
        success: false,
        message: "Account is deactivated",
      })
    }

    const token = generateToken(admin._id)

    res.status(200).json({
      success: true,
      token,
      admin: {
        id: admin._id,
        name: admin.name,
        email: admin.email,
        phone: admin.phone,
        role: admin.role,
      },
    })
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    })
  }
}

// @desc    Get admin profile
// @route   GET /api/admin/profile
// @access  Private
const getAdminProfile = async (req, res) => {
  try {
    const admin = await Admin.findById(req.admin.id)

    res.status(200).json({
      success: true,
      data: admin,
    })
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    })
  }
}

// @desc    Update admin profile
// @route   PUT /api/admin/profile
// @access  Private
const updateAdminProfile = async (req, res) => {
  try {
    const { name, email, phone } = req.body

    const admin = await Admin.findByIdAndUpdate(
      req.admin.id,
      {
        name,
        email,
        phone,
      },
      {
        new: true,
        runValidators: true,
      },
    )

    res.status(200).json({
      success: true,
      data: admin,
    })
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    })
  }
}

// @desc    Change admin password
// @route   POST /api/admin/change-password
// @access  Private
const changePassword = async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body

    if (!oldPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: "Please provide old and new password",
      })
    }

    const admin = await Admin.findById(req.admin.id).select("+password")

    // Check old password
    const isMatch = await admin.matchPassword(oldPassword)

    if (!isMatch) {
      return res.status(400).json({
        success: false,
        message: "Old password is incorrect",
      })
    }

    // Update password
    admin.password = newPassword
    await admin.save()

    res.status(200).json({
      success: true,
      message: "Password updated successfully",
    })
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    })
  }
}

// @desc    Get dashboard statistics
// @route   GET /api/admin/dashboard-stats
// @access  Private
const getDashboardStats = async (req, res) => {
  try {
    const totalUsers = await User.countDocuments()
    const totalVendors = await Vendor.countDocuments()
    const totalProducts = await Product.countDocuments()
    const totalOrders = await Order.countDocuments()
    const pendingReports = await Report.countDocuments({ status: "pending" })

    // Recent orders
    const recentOrders = await Order.find()
      .sort({ createdAt: -1 })
      .limit(5)
      .select("orderNumber customerName totalAmount status createdAt")

    // Monthly revenue
    const currentMonth = new Date()
    currentMonth.setDate(1)
    currentMonth.setHours(0, 0, 0, 0)

    const monthlyRevenue = await Order.aggregate([
      {
        $match: {
          createdAt: { $gte: currentMonth },
          paymentStatus: "completed",
        },
      },
      {
        $group: {
          _id: null,
          total: { $sum: "$totalAmount" },
        },
      },
    ])

    // Vendor status distribution
    const vendorStats = await Vendor.aggregate([
      {
        $group: {
          _id: "$status",
          count: { $sum: 1 },
        },
      },
    ])

    res.status(200).json({
      success: true,
      data: {
        totalUsers,
        totalVendors,
        totalProducts,
        totalOrders,
        pendingReports,
        monthlyRevenue: monthlyRevenue[0]?.total || 0,
        recentOrders,
        vendorStats,
      },
    })
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    })
  }
}

module.exports = {
  loginAdmin,
  getAdminProfile,
  updateAdminProfile,
  changePassword,
  getDashboardStats,
}
