# Model representing a user in the system
class User < ApplicationRecord
  # Devise modules for authentication
  devise :database_authenticatable, :registerable, :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist
  # Includes database authentication, registration, and JWT-based authentication with a denylist strategy.

  # User roles using an enum
  enum role: { regular: 0, admin: 1 } # Defines user roles: regular (default) and admin.

  # Sets a default role for new users
  after_initialize do
    self.role ||= :regular if new_record? # Assigns 'regular' role unless explicitly set
  end

  # Associations
  has_many :tickets, dependent: :destroy  # A user can create multiple tickets; tickets are deleted if the user is deleted
  has_many :messages, dependent: :destroy # A user can create multiple messages; messages are deleted if the user is deleted
end