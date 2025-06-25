const fs = require("fs")
const path = require("path")

console.log("🔍 Checking project dependencies...")

// Check if package.json exists
const packageJsonPath = path.join(__dirname, "../package.json")
if (!fs.existsSync(packageJsonPath)) {
  console.error("❌ package.json not found!")
  process.exit(1)
}

// Check if node_modules exists
const nodeModulesPath = path.join(__dirname, "../node_modules")
if (!fs.existsSync(nodeModulesPath)) {
  console.error("❌ node_modules not found! Please run: npm install")
  process.exit(1)
}

// Check if .env exists
const envPath = path.join(__dirname, "../.env")
if (!fs.existsSync(envPath)) {
  console.log("⚠️  .env file not found, using default environment variables")
}

console.log("✅ Dependencies check passed!")
