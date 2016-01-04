class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

=begin
  def initialize user_name
    super
    @user_name = user_name
    @cards = Array.new
  end

  def get_name
    @user_name
  end

  def win?
    @cards.count == 0
  end
=end
end
