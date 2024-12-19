# Admin user
admin1 = User.create!(email: 'admin1@email.com', password: 'admin1-000', role: :admin)

# Regular users
user1 = User.create!(email: 'user1@email.com', password: 'user1-000', role: :regular)
user2 = User.create!(email: 'user2@email.com', password: 'user2-000', role: :regular)

# Tickets
ticket1 = Ticket.create!(name: 'Ticket 1', description: 'Issue with HR portal', user: user1)
ticket2 = Ticket.create!(name: 'Ticket 2', description: 'Leave request issue', user: user2)

# Messages
Message.create!(content: 'First message on this ticket', user: user1, ticket: ticket1)
Message.create!(content: 'Another update on the ticket', user: user1, ticket: ticket1)
Message.create!(content: 'HR update on the ticket', user: admin1, ticket: ticket1)