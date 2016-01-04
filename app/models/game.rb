class Game < ActiveRecord::Base
  has_many :cards, dependent: :destroy
  has_many :users
  #serialize :user, Array
end
