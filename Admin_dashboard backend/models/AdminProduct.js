const mongoose = require("mongoose")

const adminProductSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      required: true,
    },
    price: {
      type: Number,
      required: true,
      min: 0,
    },
    category: {
      type: String,
      required: true,
      // Remove enum restriction to allow flexible categories
    },
    image_url: {
      type: String,
      default: "",
    },
    stock_quantity: {
      type: Number,
      required: true,
      min: 0,
      default: 0,
    },
    stock: {
      type: Number,
      required: true,
      min: 0,
      default: 0,
    },
    status: {
      type: String,
      enum: ["active", "inactive"],
      default: "active",
    },
    created_by: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
  },
  {
    timestamps: true,
  },
)

// Add indexes for better performance
adminProductSchema.index({ name: 1 })
adminProductSchema.index({ category: 1 })
adminProductSchema.index({ status: 1 })

module.exports = mongoose.model("AdminProduct", adminProductSchema)
