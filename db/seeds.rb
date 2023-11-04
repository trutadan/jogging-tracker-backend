# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
# Create a main sample user.
# Create an admin user
admin = User.create(
  username: 'admin',
  email: 'admin@example.com',
  password: 'admin_password',
  password_confirmation: 'admin_password',
  role: User.roles["admin"]
)

# Create five regular users using Faker
5.times do
  User.create(
    username: Faker::Internet.username,
    email: Faker::Internet.email,
    password: 'password123',
    password_confirmation: 'password123',
    role: User.roles["regular"]
  )
end