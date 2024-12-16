# Admin user
admin1 = User.create!(email: 'admin1@email.com', password: 'admin1-000', role: :admin)
admin2 = User.create!(email: 'admin2@email.com', password: 'admin2-000', role: :admin)

# Regular users
user1 = User.create!(email: 'user1@email.com', password: 'user1-000', role: :regular)
user2 = User.create!(email: 'user2@email.com', password: 'user2-000', role: :regular)

# Tickets
ticket1 = Ticket.create!(name: 'Workstation Setup Issue', description: 'The desk and chair provided are not ergonomic, causing back pain after long hours of work. Requesting an assessment and adjustment of the workstation to meet ergonomic standards.', user: user1, sentiment: 3)
ticket2 = Ticket.create!(name: 'Lack of Clear Communication on Policy Updates', description: 'Recent updates to the remote work policy were unclear, and there was no opportunity to ask questions. Requesting a clearer communication process for future policy changes.', user: user2, sentiment: 4)

# Messages
Message.create!(content: 'The desk and chair provided are not ergonomic, causing back pain after long hours of work. Requesting an assessment and adjustment of the workstation to meet ergonomic standards.', user: user1, ticket: ticket1)
Message.create!(content: 'Thank you for bringing this to our attention. We take employee well-being seriously and will schedule an ergonomic assessment of your workstation to identify necessary adjustments. Interim solutions, such as ergonomic accessories, can be provided if needed, and required changes will be implemented promptly. Please let us know your availability for the assessment, and feel free to share any additional details or preferences.', user: admin1, ticket: ticket1)

Message.create!(content: 'Recent updates to the remote work policy were unclear, and there was no opportunity to ask questions. Requesting a clearer communication process for future policy changes.', user: user1, ticket: ticket2)
Message.create!(content: 'Thank you for your feedback regarding the recent policy updates. We apologize for any confusion caused and will work to improve our communication process. To address this, we plan to provide more detailed explanations of policy changes and organize Q&A sessions for employees to ask questions. If you have specific concerns or require clarification on the current policy, please let us know, and we’ll assist you directly.', user: admin2, ticket: ticket2)