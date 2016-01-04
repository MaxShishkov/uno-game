# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

=begin
cards = []
colors = ["red", "blue", "green", "yellow"]
colors.each do |color|
  for i in 0..12
    if i == 0
      c = [i.to_s, color]
      cards << c
    end
    if i > 0 && i < 10
      c = [i.to_s, color]
      cards << c
      cards << c
    end
    if i == 10
      c = ["draw2", color]
      cards << c
      cards << c
    end
    if i == 11
      c = ["reverse", color]
      cards << c
      cards << c
    end
    if i == 12
      c = ["skip", color]
      cards << c
      cards << c
    end
  end
end

for i in 0..1
  for j in 0..3
    if i == 0
      c = ["wild", "wild"]
      cards << c
    else
      c = ["draw4", "wild"]
      cards << c
    end
  end
end

cards.each do |value, color|
  CardLibrary.create( value: value, color: color )
end
=end
