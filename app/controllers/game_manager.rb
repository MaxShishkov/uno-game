class GameManager < ApplicationController

  def initialize(attributes = {})
    #game starts as active, turns false when the game ends
    @active = true

    #assuming users have already been added to game at this point
    @game = attributes[:game]
    @game.whoseTurn = @game.user[0]

  end

  def game_init
    deck = self.create_deck
    deck.each do |card|
      #add each card to database based on the deck array
      card.save
    end
    #set top card of discard pile
    top_card = Card.where(game_id: @game.id, owner: 0).order("RANDOM()").first
    top_card.update_attributes(owner: -2)
    @game.lastPlayedCard = top_card.id
    #add each user to the database for this game
  end

  def create_deck
    temp_deck =[]

    for color in 1..4
      #create 1 of each 0 card and 4 of wild and wild draw 4
      temp_deck << Card.new(value: 0, color: color, game_id: @game.id)
      temp_deck << Card.new(value: 13, color: 0, game_id: @game.id)
      temp_deck << Card.new(value: 14, color: 0, game_id: @game.id)
      for value in 1..12
        #create 2 copies of each 1-9 for each color
        temp_deck << Card.new(value: value, color: color, game_id: @game.id)
        temp_deck << Card.new(value: value, color: color, game_id: @game.id)
      end
    end
     return temp_deck
  end

  def shuffle_discard!
    #get all cards that are in the discard pile, but ignore the top card
    Card.where(game_id: @game.id, owner: -1).find_each do |card|
      card.update_attributes(owner: 0)
      
    end
  end

  def card_playable?(card)
=begin
    check if the card the player picks is ok to play
    must be same color or rank unless...
    either the card trying to be played or the top card
    is wild or wild draw 4, then you can play anything
    return true if its playable, false if not
=end
    top_card = Card.find(@game.lastPlayedCard)
    if(card.color == 0 || top_card.color == 0) then
      return true
    else

      if(top_card.value == card.value || top_card.color == card.color) then
        return true
      else
        return false
      end
    end
  end

  def update_last_played(card)
    #change the current top of discard's owner to -1
    #change owner of the card played to -2 (top of the discard pile)
    #update top of discard to the card played
    current_top = Card.find(@game.lastPlayedCard)
    current_top.update_attributes(owner: -1)
    card.update_attributes(owner: -2)
    @game.update_attributes(lastPlayedCard: card.id)
  end

  def draw_cards(user, number)
    #find first card with game_ID of the game and owner 0
    #change the owner to the user who drew it
    if(number > self.cards_in_deck) then
      number -= self.cards_in_deck
      drawn_card = Card.where(game_id: @game.id, owner: 0).limit(self.cards_in_deck).order("RANDOM()")
      drawn_card.each do |card|
        card.update_attributes(owner: user.id)
      end
        self.shuffle_discard!
    end
    drawn_card = Card.where(game_id: @game.id, owner: 0).limit(number).order("RANDOM()")
    drawn_card.each do |card|
      card.update_attributes(owner: user.id)
    end
  end

  def game
    while(@active)
      #react to the player only if it's their turn

      #check if the card is playable, if it is, apply any effects if the card is special
    end
  end

  def end_game
    #remove game from table as well as all cards associated with that game
    @game.destroy
  end

  #applies effects of the card played if that card is a special card
  def apply_effects(card)
    if(card.value == 10) then
    #skip
      if(@game.user.length > 2) then
        self.set_next_player_turn(2)
      end
    elsif(card.value == 11) then
    #reverse
      if(@game.user.length > 2) then
        self.toggle_clockwise
        self.set_next_player_turn(1)
      end
    elsif(card.value == 12) then
    #draw2
      user = self.get_next_player
      self.draw_cards(user, 2)
      if(@game.user.length > 2) then
        self.set_next_player_turn(2)
      end
    elsif(card.value == 14) then
    #wild draw 4
      user =self.get_next_player
      self.draw_cards(user, 4)
      if(@game.user.length > 2) then
        self.set_next_player_turn(2)
      end
    else
    #just a regular card, change the whoseturn to the next user
    self.set_next_player_turn(1)
    end
  end
=begin
  # applies effects of the card played if that card is a special card
  # and there are only 2 players
  def apply_effects2p(card)
    if(card.value == 10 || card.value == 11) then
    #skip or reverse (player gets to play another card, so does nothing)
    elsif(card.value == 12) then
    #draw2 (also gives you another turn)
    user = self.get_next_player
    self.draw_cards(user, 2)
    elsif(card.value == 14) then
    #wild draw 4 (also gives you another turn)
    user = self.get_next_player
    self.draw_cards(user, 4)
    else
      #just a regular card, change the whoseturn to the next user
      self.set_next_player_turn(1)
    end
  end
=end
  def get_next_player
    crnt_plyr_indx = @game.user.index(@game.whoseTurn)
    temp_usr_array = @game.user.rotate(crnt_plyr_indx)
    if(@game.clockwise) then
      return User.find(temp_usr_array[1])
    else
      return User.find(temp_usr_array[-1])
    end
  end

  def set_next_player_turn(spaces_ahead)
    crnt_plyr_indx = @game.user.index(@game.whoseTurn)
    temp_usr_array = @game.user.rotate(crnt_plyr_indx)
    if(@game.clockwise) then
      @game.whoseTurn = temp_usr_array[spaces_ahead]
    else
      @game.whoseTurn = temp_usr_array[spaces_ahead * -1]
    end
  end

  def toggle_clockwise
    if (@game.clockwise == false) then
      @game.clockwise = true
      @game.save
    else
      @game.clockwise = false
      @game.save
    end
  end
  #returns the number of cards left in the deck available to draw from
  #if this number is too low, the discard pile needs to be shuffled
  def cards_in_deck
    Card.where(game_id: @game.id, owner: 0).size
  end

  def user_cards(user)
    Card.where(game_id: @game.id, owner: user.id).all
  end

end
