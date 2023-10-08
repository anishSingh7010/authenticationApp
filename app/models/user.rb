class User
  include ActiveModel::SecurePassword
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :email, type: String
  field :password_digest, type: String
  field :role, type: String, default: 'user'
  field :active, type: Boolean
  field :uniqueActivationId, type: String, default: ''
  field :resetPasswordId, type: String, default: ''

  validates :name, presence: {message: "Name is required."}
  validates :email, presence: {message: "Email is required."}, uniqueness: {message: "User already exists."}, format: {message: "Please enter a valid email",with: /\A[^@\s]+@([^@.\s]+\.)+[^@.\s]+\z/ }
  validates :password, presence: {message: "Password is required."}, confirmation: {message: "Passwords do not match."}, length: {minimum: 5, message: "Password is too short"}
  validates :password_confirmation, presence: {message: "Password is required."}

  has_secure_password validations: false
end
