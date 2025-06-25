const validator = require("validator")

// Validate email
const validateEmail = (email) => {
  return validator.isEmail(email)
}

// Validate phone number
const validatePhone = (phone) => {
  return validator.isMobilePhone(phone)
}

// Validate password strength
const validatePassword = (password) => {
  return validator.isStrongPassword(password, {
    minLength: 6,
    minLowercase: 1,
    minUppercase: 1,
    minNumbers: 1,
    minSymbols: 0,
  })
}

// Validate MongoDB ObjectId
const validateObjectId = (id) => {
  return validator.isMongoId(id)
}

// Validate URL
const validateURL = (url) => {
  return validator.isURL(url)
}

// Sanitize input
const sanitizeInput = (input) => {
  return validator.escape(input)
}

// Validate price
const validatePrice = (price) => {
  return validator.isFloat(price.toString(), { min: 0 })
}

// Validate stock quantity
const validateStock = (stock) => {
  return validator.isInt(stock.toString(), { min: 0 })
}

module.exports = {
  validateEmail,
  validatePhone,
  validatePassword,
  validateObjectId,
  validateURL,
  sanitizeInput,
  validatePrice,
  validateStock,
}
