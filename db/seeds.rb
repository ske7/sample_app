# Users
if User.count.zero?
  # Create a main sample user.
  User.create!(name: 'Example User',
               email: 'example@railstutorial.org',
               password: 'password',
               password_confirmation: 'password',
               admin: true,
               activated: true,
               activated_at: Time.zone.now)

  User.create!(name: 'Demi',
               email: 'demilichkangaxx@gmail.com',
               password: '12qwas',
               password_confirmation: '12qwas',
               admin: true,
               activated: true,
               activated_at: Time.zone.now)

  # Generate a bunch of additional users.
  99.times do |n|
    name = Faker::Name.name
    email = "example-#{n + 1}@railstutorial.org"
    password = 'password'
    User.create!(name:,
                 email:,
                 password:,
                 password_confirmation: password,
                 activated: true,
                 activated_at: Time.zone.now)
  end
end

# Microposts
unless User.count.zero?
  users = User.order(:created_at).first(6)

  50.times do
    content = Faker::Lorem.sentence(word_count: 5)
    users.each { |user| user.microposts.create!(content:) }
  end
end

# Following relationships
users = User.all
user = users.where(email: 'demilichkangaxx@gmail.com').first
following = users[2..50]
followers = users[3..40]

following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }
