# Model representing a message within a ticket
class Message < ApplicationRecord
  # Associations
  belongs_to :ticket # Each message belongs to a specific ticket
  belongs_to :user   # Each message is created by a specific user

  # Validations
  validates :content, presence: true # Ensures a message must have content
end