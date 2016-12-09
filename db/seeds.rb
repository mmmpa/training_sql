# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if ENV['TOO_MANY_STUDENT']
  total = 100000
  kinds = %w(国語 理科 数学 英語)

  total.times do
    student = Student.create!(
      name: Faker::Name.first_name,
      email: Faker::Internet.email,
      city: Faker::Address.city
    )

    kinds.each do |name|
      Result.create!(
        student: student,
        name: name,
        point: rand(0..100)
      )
    end
  end
end

if ENV['FRIEND_SHIP']
  total = 1000000
  ids = Student.ids

  total.times do
    FriendShip.create!(
      owner_id: ids.sample,
      ownee_id: ids.sample
    )
  end
end

if ENV['LAST_DAY']
  now = DateTime.now.to_i
  Student.find_each do |s|
    if rand(0..1) == 1
      s.update!(last_day: Time.at(rand(0..now)))
    else
      s.update!(last_day: nil)
    end
  end
end

