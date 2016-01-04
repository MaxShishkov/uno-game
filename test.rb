class Test < ApplicationController

  def initialize
    #game starts as active, turns false when the game ends
    @active = true
    @game = Game.new(name:"teste")
    @game.save
    #test
    #self.c
    r=0
    puts "test\n\n"
    Game.all.each do |u|
      puts u.id
      r+=1
    end
    puts r
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

  def c
    deck = self.create_deck
    deck.each do |card|
      #add each card to database based on the deck array
      card.save
    end
    #set top card of discard pile
    top_card = Card.where(game_id: @game.id, owner: 0).order("RANDOM()").first


    top_card.update_attributes(owner: -2)
    @game.lastPlayedCard = top_card.id

    users = []
    for x in 0..3
      u = User.new
      users << u
      users[x].save
    end

    for x in 0..3
      users[x] = users[x].id
    end
    @game.user=users
    puts "\npart 1\n"
    @game.save

    users.each do |u|
      puts u.id
    end
    #@game.user.each do |usr|
     # puts usr.to_s
   # end
  end

  def create_deck
    temp_deck =[]

    for color in 1..4
      #create 1 of each 0 card and 4 of wild and wild draw 4
      temp_deck << Card.new(value: 0, color: color, owner: 0, game_id: @game.id)
      temp_deck << Card.new(value: 13, color: 0, owner: 0, game_id: @game.id)
      temp_deck << Card.new(value: 14, color: 0, owner: 0, game_id: @game.id)
      for value in 1..12
        #create 2 copies of each 1-9 for each color
        temp_deck << Card.new(value: value, color: color, owner: 0, game_id: @game.id)
        temp_deck << Card.new(value: value, color: color, owner: 0, game_id: @game.id)
      end
    end
     return temp_deck
  end

  def shuffle_discard!
    #get all cards that are in the discard pile, but ignore the top card
    Card.where(game_id: @game.id, owner: -1).find_each do |card|
      card.update_attributes(owner: 0)
      puts self.print_card(card)
    end
  end

  def card_playable?(card)
    #check if card player picks is ok to play
    #(must be same color or rank) wild and wild draw 4 is always playable
    #return true if its playable, false if not

    #not sure if this syntax is right.
    #will @game.lastPlayedCard give a card object? i hope so
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

  #applies effects of the card played if that card is a special card and there are more than 2 players
  def apply_effects(card)
    if(card.value == 10) then
    #skip

    elsif(card.value == 11) then
    #reverse
    @game.toggle(clockwise)
    @game.save
    elsif(card.value == 12) then
    #draw2
    user =
    self.draw_cards(user, 2)
    elsif(card.value == 14) then
    #wild draw 4
    user =
    self.draw_cards(user, 4)
    else
      #just a regular card, change the whoseturn to the next user

    end
  end

  #applies effects of the card played if that card is a special card and there are only 2 players
  def apply_effects2p(card)
    if(card.value == 10) then
    #skip

    elsif(card.value == 11) then
    #reverse (just skips opponent's turn)

    elsif(card.value == 12) then
    #draw2 (also gives you another turn)
    user =
    self.draw_cards(user, 2)
    elsif(card.value == 14) then
    #wild draw 4 (also gives you another turn)
    user =
    self.draw_cards(user, 4)
    else
      #just a regular card, change the whoseturn to the next user

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

#debugging methods
  def print_card(card)
    s = ""
    s << "owner: " + card.owner.to_s + ' '
    if card.color == 0 then
      s << "black  "
    elsif card.color == 1 then
      s << "red    "
    elsif card.color == 2 then
      s << "yellow "
    elsif card.color == 3 then
      s << "green  "
    elsif card.color == 4 then
      s << "blue   "
    else
      s << "????   "
    end

    if card.value == 10 then
      s << "skip"
    elsif card.value == 11 then
        s << "reverse"
    elsif card.value == 12 then
      s << "draw 2"
    elsif card.value == 13 then
      s << "wild"
    elsif card.value == 14 then
      s << "wild draw 4"
    else
      s << card.value.to_s
    end
    return s
  end

  def print_top
    puts "top card is " + print_card(Card.find(@game.lastPlayedCard))
  end

  def print_all_cards
    count = 0
    Card.where(game_id: @game.id).find_each do |card|
      puts self.print_card(card)
      count += 1
    end
    puts "#{count} results"
  end

  def draw_cardz(number)
    #find first card with game_ID of the game and owner 0
    #change the owner to the user who drew it
    if(number > self.cards_in_deck) then
      number -= self.cards_in_deck
      drawn_card = Card.where(game_id: @game.id, owner: 0).limit(self.cards_in_deck).order("RANDOM()")
      drawn_card.each do |card|
        card.update_attributes(owner: 41)
      end
      self.shuffle_discard!
    end
    drawn_card = Card.where(game_id: @game.id, owner: 0).limit(number).order("RANDOM()")
    drawn_card.each do |card|
      card.update_attributes(owner: 41)
    end
  end

  def draw_card
    #find first card with game_ID of the game and owner 0
    #change the owner to the user who drew it
    drawn_card = Card.where(game_id: @game.id, owner: 0).order("RANDOM()").first
    drawn_card.update_attributes(owner: 41)
    return drawn_card
  end
end
