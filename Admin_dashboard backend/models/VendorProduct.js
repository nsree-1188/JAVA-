const mongoose = require("mongoose")

const vendorProductSchema = new mongoose.Schema(
  {
    vendor_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Vendor",
      required: true,
    },
    vendorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Vendor",
      required: true,
    },
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
      enum: ["active", "inactive", "pending"],
      default: "active",
    },
    approved_by: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Admin",
    },
    approved_at: {
      type: Date,
    },
    // Remove size field validation that was causing issues
    size: {
      type: String,
      required: false,
    },
  },
  {
    timestamps: true,
  },
)

// Add indexes for better performance
vendorProductSchema.index({ vendor_id: 1 })
vendorProductSchema.index({ vendorId: 1 })
vendorProductSchema.index({ name: 1 })
vendorProductSchema.index({ category: 1 })
vendorProductSchema.index({ status: 1 })

module.exports = mongoose.model("VendorProduct", vendorProductSchema)
