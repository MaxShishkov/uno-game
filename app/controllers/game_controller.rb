class GameController < ApplicationController
  def index
    @games = Game.all
    @game = Game.new
  end

  def new
    @game = Game.new
  end


  def show
    @game = Game.find(params[:id])
    @chat_message = ChatMessage.new

    #If user is not already in game.users, insert that user
    if current_user[:game_id] != @game.id
      @game[:user] << current_user.id
      @game.save
    end
    #append the id game to user joining game
    current_user[:game_id] = @game.id
    current_user.save
  end

  def create
    @game = Game.new

    game = params[:game]
    name = game[:name]
    @game[:name] = name

    # hard coded firelds for now (fix null errors)
     @game[:clockwise] = true
     @game[:lastPlayedCard] = 0
     #the user who created the game will be part of the game
     @game[:user] = [current_user.id]
     @game[:whoseTurn] = 1000000

    
    
    # save data to table
    if @game.save
      #after a game is saved that means a new row is created
      #append the id of the new row to the user who created the game
      current_user[:game_id] = @game.id
      current_user.save
      #end user

      #new game new deck
      cards = new_deck
      #add the cards to the database
      add_cards(cards.shuffle)


      redirect_to @game, alert: "game created"
    else
      render 'new'
    end
  end

  def leave_game
    
    #find the Game object based on what game the user is part of
    @game = Game.find(current_user[:game_id])
    #delete the user from the game
    @game[:user].delete(current_user[:id])
    if @game.save
      #destroy the game from database if no users
      if @game[:user].size == 0
        Game.destroy(current_user[:game_id])
        #cards are automatically destroyed
      end
    end

    current_user[:game_id] = 0
    current_user[:activeTurn] = false
    current_user.save

    redirect_to "/"
  end

  def start_game
    #who ever press the start game button grab their game object
    @game = Game.find(current_user[:game_id])
    #set game as being played so no other users can join
    @game[:session] = true
    @game.save

    #pass out cards to users
    @game[:user].each do |id|
      7.times do
        top_card = Card.where(game_id: @game.id, owner: 0).first
        top_card[:owner] = id
        top_card.save
      end
    end
    #discard pile starting card
    top_card = Card.where(game_id: @game.id, owner: 0).order("RANDOM()").first
    #first card must not be wild because no one can declare color
    while top_card.color == "wild" do
      top_card = Card.where(game_id: @game.id, owner: 0).order("RANDOM()").first
    end
    top_card[:owner] = -2
    top_card.save
    @game[:lastPlayedCard] = top_card[:id]
    @game[:value] = top_card[:value]
    @game[:color] = top_card[:color]
    @game.save

    nextUser = User.find(@game.user[@game.whoseTurn % @game.user.count])
    nextUser.activeTurn = true
    nextUser.save

    redirect_to @game
  end

  def draw2(card,game)
    if @game.clockwise
      @game.whoseTurn+=1
    else
      @game.whoseTurn-=1
    end
    2.times do
      top_card = Card.where(game_id: @game.id, owner: 0).order("RANDOM()").first
      #if there are no more cards in deck
      if top_card == nil
        shuffle_discard!
        #draw a card again so that top_card is not nil
        top_card = Card.where(game_id: @game.id, owner: 0).order("RANDOM()").first
      end
      #give the card a owner
      top_card[:owner] = @game.user[@game.whoseTurn % @game.user.count]
      top_card.save
    end
  end

  def reverse(game)
    if @game.user.count == 2
      @game.clockwise = !@game.clockwise
      skip(@game)
    else
      @game.clockwise = !@game.clockwise
    end
  end

  def skip(game)
    if @game.clockwise
      @game.whoseTurn+=1
    else
      @game.whoseTurn-=1
    end
  end

  def draw4(card,game)
    if @game.clockwise
      @game.whoseTurn+=1
    else
      @game.whoseTurn-=1
    end
    4.times do
      top_card = Card.where(game_id: @game.id, owner: 0).order("RANDOM()").first
      #if there are no more cards in deck
      if top_card == nil
        shuffle_discard!
        #draw a card again so that top_card is not nil
        top_card = Card.where(game_id: @game.id, owner: 0).order("RANDOM()").first
      end
      #give the card a owner
      top_card[:owner] = @game.user[@game.whoseTurn % @game.user.count]
      top_card.save
    end
  end

  #when user plays a card
  def play_card(card, game)
    #the card will be in the discard pile
    card.owner = -2
    card.save
    #the user will no longer have an activeTurn
    current_user.activeTurn = false
    current_user.save

    if card.value == "draw2"
      draw2(card,@game)
    elsif card.value == "reverse"
      reverse(@game)
    elsif card.value == "skip"
      skip(@game)
    elsif card.value == "draw4"
      draw4(card,@game)
    end
      

    #depending whether or not the game is clockwise next user
    if @game.clockwise
      @game.whoseTurn+=1
    else
      @game.whoseTurn-=1
    end
    #find the next user and set as true activeTurn
    nextUser = User.find(@game.user[@game.whoseTurn % @game.user.count])
    nextUser.activeTurn = true
    nextUser.save
    #lastplayed card id & value
    @game.lastPlayedCard = card.id
    @game.value = card.value
    
  end

#if a normal color card is played
#this includes all cards that are not wild color
  def normal_card
    card = Card.find(params[:id])
    @game = Game.find(current_user[:game_id])
    
    play_card(card, @game)

    @game.color = card.color
    @game.save

    redirect_to @game
  end

#if the user plays a wild card and declare the color as blue
  def wild_blue
    card = Card.find(params[:id])
    @game = Game.find(current_user[:game_id])
    
    play_card(card, @game)

=begin Not needed
    current_user.activeTurn = false
    current_user.save
    nextUser = User.find(@game.user[@game.whoseTurn % @game.user.count])
    nextUser.activeTurn = true
    nextUser.save
=end

    @game.color = "blue"
    @game.save

    redirect_to @game
  end

#if the user plays a wild card and declare the color as yellow
  def wild_yellow
    card = Card.find(params[:id])
    @game = Game.find(current_user[:game_id])
    
    play_card(card, @game)

    @game.color = "yellow"
    @game.save

    redirect_to @game
  end
  
#if the user plays a wild card and declare the color as green
  def wild_green
    card = Card.find(params[:id])
    @game = Game.find(current_user[:game_id])
    
    play_card(card, @game)

    @game.color = "green"
    @game.save

    redirect_to @game
  end

#if the user plays a wild card and declare the color as red  
  def wild_red
    card = Card.find(params[:id])
    @game = Game.find(current_user[:game_id])
    
    play_card(card, @game)

    @game.color = "red"
    @game.save

    redirect_to @game
  end


#draw a card
  def draw_card
    @game = Game.find(current_user[:game_id])
    #get the top card with no owner, also random
    top_card = Card.where(game_id: @game.id, owner: 0).order("RANDOM()").first
    #if there are no more cards in deck
    if top_card == nil
      shuffle_discard!
      #draw a card again so that top_card is not nil
      top_card = Card.where(game_id: @game.id, owner: 0).order("RANDOM()").first
    end

    #give the card a owner
    top_card[:owner] = current_user.id
    top_card.save

    redirect_to @game
  end

  def shuffle_discard!
    #get all cards that are in the discard pile
    Card.where(game_id: @game.id, owner: -2).each do |card|
      card[:owner] = 0
      card.save
    end
  end

  #add cards into the database, has no owner but is part of current game
  def add_cards(cards)
    #cards need to be a 2d array of vale and color
    cards.each do |value, color|
      Card.create(game_id: @game.id, owner: 0, value: value, color: color )
    end
  end

  def new_deck
    #creates an array of 108 cards[value, color]
    cards = []
    colors = ["red", "blue", "green", "yellow"]
    colors.each do |color|

      c = [0, color]
      cards << c

      for i in 1..9
        c = [i.to_s, color]
        cards << c
        cards << c
      end

      c = ["draw2", color]
      cards << c
      cards << c


      c = ["reverse", color]
      cards << c
      cards << c

      c = ["skip", color]
      cards << c
      cards << c

      c = ["wild", "wild"]
      cards << c

      c = ["draw4", "wild"]
      cards << c
    end

    return cards
  end
  #end new_deck function return array of cardsz

=begin ------ not working yet
  def refresh
    respond_to do |format|
      format.js
    end
  end
=end

end
