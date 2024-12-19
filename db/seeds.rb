# Admin user
User.create!(email: 'admin@email.com', password: 'admin-000', role: :admin)

# Regular users
user1 = User.create!(email: 'user1@email.com', password: 'user1-000', role: :regular)
user2 = User.create!(email: 'user2@email.com', password: 'user2-000', role: :regular)

# Tickets
Ticket.create!(name: 'Ticket 1', description: 'Issue with HR portal', user: user1)
Ticket.create!(name: 'Ticket 2', description: 'Leave request issue', user: user2)