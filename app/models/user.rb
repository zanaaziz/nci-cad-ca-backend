class User < ApplicationRecord
  # Devise modules for authentication
  devise :database_authenticatable, :registerable, :recoverable, :validatable
  
  # Role-based access
  enum role: { regular: 0, admin: 1 }

  # Set default role
  after_initialize do
    self.role ||= :regular if new_record?
  end
end