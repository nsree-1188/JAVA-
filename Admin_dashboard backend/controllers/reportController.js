const Report = require("../models/Report")
const User = require("../models/User")

// @desc    Get all reports
// @route   GET /api/reports
// @access  Private
const getReports = async (req, res) => {
  try {
    const page = Number.parseInt(req.query.page) || 1
    const limit = Number.parseInt(req.query.limit) || 10
    const skip = (page - 1) * limit
    const status = req.query.status
    const category = req.query.category
    const priority = req.query.priority

    const filter = {}
    if (status) filter.status = status
    if (category) filter.category = category
    if (priority) filter.priority = priority

    const reports = await Report.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .populate("userId", "name email phone")
      .populate("assignedTo", "name email")

    const total = await Report.countDocuments(filter)

    res.status(200).json({
      success: true,
      count: reports.length,
      total,
      page,
      pages: Math.ceil(total / limit),
      data: reports,
    })
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    })
  }
}

// @desc    Get single report
// @route   GET /api/reports/:id
// @access  Private
const getReportById = async (req, res) => {
  try {
    const report = await Report.findById(req.params.id)
      .populate("userId", "name email phone")
      .populate("assignedTo", "name email")
      .populate("responses.adminId", "name email")
      .populate("orderId", "orderNumber totalAmount status")
      .populate("productId", "name price")

    if (!report) {
      return res.status(404).json({
        success: false,
        message: "Report not found",
      })
    }

    res.status(200).json({
      success: true,
      data: report,
    })
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    })
  }
}

// @desc    Update report status
// @route   PUT /api/reports/:id/status
// @access  Private
const updateReportStatus = async (req, res) => {
  try {
    const { status, assignedTo, priority } = req.body

    const updateData = {}
    if (status) {
      updateData.status = status
      if (status === "resolved") {
        updateData.resolvedAt = new Date()
        updateData.resolvedBy = req.admin.id
      }
    }
    if (assignedTo) updateData.assignedTo = assignedTo
    if (priority) updateData.priority = priority

    const report = await Report.findByIdAndUpdate(req.params.id, updateData, {
      new: true,
      runValidators: true,
    })

    if (!report) {
      return res.status(404).json({
        success: false,
        message: "Report not found",
      })
    }

    res.status(200).json({
      success: true,
      message: "Report status updated successfully",
      data: report,
    })
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    })
  }
}

// @desc    Respond to report
// @route   POST /api/reports/:id/respond
// @access  Private
const respondToReport = async (req, res) => {
  try {
    const { message } = req.body

    if (!message) {
      return res.status(400).json({
        success: false,
        message: "Please provide a response message",
      })
    }

    const report = await Report.findById(req.params.id)

    if (!report) {
      return res.status(404).json({
        success: false,
        message: "Report not found",
      })
    }

    // Add response
    report.responses.push({
      adminId: req.admin.id,
      adminName: req.admin.name,
      message,
      timestamp: new Date(),
    })

    // Update status to in_progress if it's pending
    if (report.status === "pending") {
      report.status = "in_progress"
    }

    await report.save()

    res.status(200).json({
      success: true,
      message: "Response added successfully",
      data: report,
    })
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    })
  }
}

// @desc    Get reports by status
// @route   GET /api/reports/status/:status
// @access  Private
const getReportsByStatus = async (req, res) => {
  try {
    const page = Number.parseInt(req.query.page) || 1
    const limit = Number.parseInt(req.query.limit) || 10
    const skip = (page - 1) * limit

    const reports = await Report.find({ status: req.params.status })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .populate("userId", "name email")

    const total = await Report.countDocuments({ status: req.params.status })

    res.status(200).json({
      success: true,
      count: reports.length,
      total,
      page,
      pages: Math.ceil(total / limit),
      data: reports,
    })
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    })
  }
}

// @desc    Delete report
// @route   DELETE /api/reports/:id
// @access  Private
const deleteReport = async (req, res) => {
  try {
    const report = await Report.findById(req.params.id)

    if (!report) {
      return res.status(404).json({
        success: false,
        message: "Report not found",
      })
    }

    await Report.findByIdAndDelete(req.params.id)

    res.status(200).json({
      success: true,
      message: "Report deleted successfully",
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
  getReports,
  getReportById,
  updateReportStatus,
  respondToReport,
  getReportsByStatus,
  deleteReport,
}
