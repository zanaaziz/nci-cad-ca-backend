class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :validatable

  enum role: { regular: 0, admin: 1 }

  after_initialize do
    self.role ||= :regular if new_record?
  end

  has_many :tickets, dependent: :destroy
  has_many :messages, dependent: :destroy
end