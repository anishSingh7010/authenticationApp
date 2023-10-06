class User
  include ActiveModel::SecurePassword
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :email, type: String
  field :password_digest, type: String
  field :role, type: String
  field :active, type: Boolean
  field :uniqueActivationId, type: String
  field :resetPasswordId, type: String

  validates :name, presence: {message: "Name is required."}
  validates :email, presence: {message: "Email is required."}, uniqueness: {message: "User already exists."}
  validates :password, presence: {message: "Password is required."}

  has_secure_password validations: false
end
