class Ticket < ApplicationRecord
  belongs_to :user
  has_many :messages, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
end