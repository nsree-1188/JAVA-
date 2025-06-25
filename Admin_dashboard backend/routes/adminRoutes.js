const express = require("express")
const router = express.Router()
const User = require("../models/User")
const Vendor = require("../models/Vendor")
const Product = require("../models/Product")
const Order = require("../models/Order")
const Report = require("../models/Report")

// Dashboard statistics
router.get("/dashboard-stats", async (req, res) => {
  try {
    // Get counts
    const totalUsers = await User.countDocuments()
    const totalVendors = await Vendor.countDocuments()
    const totalProducts = await Product.countDocuments()
    const totalOrders = await Order.countDocuments()

    // Get pending counts
    const pendingOrders = await Order.countDocuments({ status: "pending" })
    const pendingVendors = await Vendor.countDocuments({ status: "pending" })
    const activeReports = await Report.countDocuments({ status: "pending" })

    // Calculate total revenue
    const revenueResult = await Order.aggregate([
      { $match: { status: { $in: ["completed", "delivered"] } } },
      { $group: { _id: null, total: { $sum: "$totalAmount" } } },
    ])
    const totalRevenue = revenueResult.length > 0 ? revenueResult[0].total : 0

    // Get order status breakdown
    const orderStatusBreakdown = await Order.aggregate([{ $group: { _id: "$status", count: { $sum: 1 } } }])

    // Get recent activity (last 30 days)
    const thirtyDaysAgo = new Date()
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)

    const recentOrders = await Order.countDocuments({
      createdAt: { $gte: thirtyDaysAgo },
    })

    const deliveredOrders = await Order.countDocuments({
      status: "delivered",
      updatedAt: { $gte: thirtyDaysAgo },
    })

    res.json({
      totalUsers,
      totalVendors,
      totalProducts,
      totalOrders,
      totalRevenue,
      pendingOrders,
      pendingVendors,
      activeReports,
      orderStatusBreakdown,
      recentActivity: {
        recentOrders,
        deliveredOrders,
      },
    })
  } catch (error) {
    res.status(500).json({ message: error.message })
  }
})

// Get sales data for charts
router.get("/sales-data", async (req, res) => {
  try {
    const { period = "7d" } = req.query

    const startDate = new Date()
    if (period === "7d") {
      startDate.setDate(startDate.getDate() - 7)
    } else if (period === "30d") {
      startDate.setDate(startDate.getDate() - 30)
    } else if (period === "1y") {
      startDate.setFullYear(startDate.getFullYear() - 1)
    }

    const salesData = await Order.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
          status: { $in: ["completed", "delivered"] },
        },
      },
      {
        $group: {
          _id: {
            $dateToString: {
              format: period === "7d" ? "%Y-%m-%d" : "%Y-%m",
              date: "$createdAt",
            },
          },
          sales: { $sum: "$totalAmount" },
          orders: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ])

    res.json(salesData)
  } catch (error) {
    res.status(500).json({ message: error.message })
  }
})

module.exports = router
