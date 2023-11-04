# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create an admin user
admin = User.create(
  username: 'admin',
  email: 'admin@example.com',
  password: 'Pa$$w0rd',
  password_confirmation: 'Pa$$w0rd',
  role: User.roles["admin"]
)

# Create five regular users using Faker
5.times do
  User.create(
    username: Faker::Internet.username,
    email: Faker::Internet.email,
    password: 'Pa$$w0rd',
    password_confirmation: 'Pa$$w0rd',
    role: User.roles["regular"]
  )
end

# Create 30 time entries for each user
users = User.all

users.each do |user|
  30.times do
    date = Faker::Date.between(from: 1.year.ago, to: Date.today)
    distance = Faker::Number.decimal(l_digits: 2)
    hours = Faker::Number.between(from: 0, to: 10)
    minutes = Faker::Number.between(from: 0, to: 59)
    seconds = Faker::Number.between(from: 0, to: 59)

    TimeEntry.create(
      user: user,
      date: date,
      distance: distance,
      hours: hours,
      minutes: minutes,
      seconds: seconds
    )
  end
end