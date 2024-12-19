class AddSentimentToTickets < ActiveRecord::Migration[7.2]
  def change
    add_column :tickets, :sentiment, :integer, null: true
  end
end
