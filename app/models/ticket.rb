# Model representing a ticket in the system
class Ticket < ApplicationRecord
  # Associations
  belongs_to :user                       # Each ticket is created by a specific user
  has_many :messages, dependent: :destroy # A ticket can have multiple messages, which are deleted when the ticket is deleted

  # Validations
  validates :name, presence: true           # Ensures the ticket has a name
  validates :description, presence: true    # Ensures the ticket has a description
  validates :sentiment, numericality: { only_integer: true, allow_nil: true } # Sentiment must be an integer or nil
end