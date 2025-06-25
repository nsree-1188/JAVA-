const express = require("express")
const router = express.Router()
const Report = require("../models/Report")

// Get all reports
router.get("/", async (req, res) => {
  try {
    const reports = await Report.find().sort({ createdAt: -1 })
    res.json(reports)
  } catch (error) {
    res.status(500).json({ message: error.message })
  }
})

// Get report by ID
router.get("/:id", async (req, res) => {
  try {
    const report = await Report.findById(req.params.id)
    if (!report) {
      return res.status(404).json({ message: "Report not found" })
    }
    res.json(report)
  } catch (error) {
    res.status(500).json({ message: error.message })
  }
})

// Update report
router.put("/:id", async (req, res) => {
  try {
    const report = await Report.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true })
    if (!report) {
      return res.status(404).json({ message: "Report not found" })
    }
    res.json(report)
  } catch (error) {
    res.status(400).json({ message: error.message })
  }
})

module.exports = router
