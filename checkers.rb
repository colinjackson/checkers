load './board.rb'

class NoPieceError < RuntimeError
end

class WrongPlayerError < RuntimeError
end

class Checkers
  COLOR_SWITCH = { black: :white, white: :black }

  attr_reader :board

  def initialize(p1_name, p2_name, board_size)
    @board = Board.new(board_size)
    @move_sets = []
    make_players(p1_name, p2_name)
  end

  def run
    @color = :black
    board.draw

    until board.over?
      board.draw
      player = @players[@color]

      piece = get_piece(player)
      board.draw(piece.square)
      move_piece(piece, player)

      @color = COLOR_SWITCH[@color]
    end

    recap
  end

  def get_piece(player)
    from_square = player.choose_piece
    piece = board[from_square]
    raise NoPieceError if piece.nil?
    raise WrongPlayerError if piece.color != @color

    piece
  rescue NoPieceError
    puts "There's no piece there!"
    retry
  rescue WrongPlayerError
    puts "That isn't your piece!"
    retry
  end

  def move_piece(piece, player)
    squares = player.choose_moves
    piece.perform_moves(squares)
  rescue InvalidMoveError
    puts "That piece can't go there!"
    retry
  end

  def make_players(p1_name, p2_name)
    p1 = HumanPlayer.new(p1_name, self)
    p2 = HumanPlayer.new(p2_name, self)
    @players = { black: p1, white: p2 }
  end

  def recap
  end

end

class InputError < RuntimeError
end

class HumanPlayer

  LOCATION_TABLE = {
    ?a => 0,
    ?b => 1,
    ?c => 2,
    ?d => 3,
    ?e => 4,
    ?f => 5,
    ?g => 6,
    ?h => 7,
    ?i => 8,
    ?j => 9,
    ?k => 10,
    ?l => 11
  }

  def initialize(name, checkers)
    @name, @checkers = name, checkers
  end

  def choose_piece
    message = "#{@name}, select a piece"
    error_message = "Sorry, I don't understand. Try again"
    piece_square = prompt(message, error_message) do |input|
      input.downcase.strip =~ /^[a-l][1-9][0-2]?$/
    end.downcase.strip

    parse_square_input(piece_square)
  end

  def choose_moves
    message = "Tell that piece what to do"
    error_message = "Sorry, I don't understand. Try again"
    squares = prompt(message, error_message) do |input|
      input.downcase.strip =~ /^([a-l][1-9][0-2]?,\s)*([a-l][1-9][0-2]?)$/
    end.downcase.strip

    squares.split(", ").map { |square| parse_square_input(square) }
  end

  def parse_square_input(input)
    col_input, row_input = input.split('')
    row = @checkers.board.board_size - row_input.to_i
    col = LOCATION_TABLE[col_input]

    [row, col]
  end

  def prompt(message, error_message, &prc)
    print "#{message}: "
    begin
      input = gets.chomp
      raise InputError unless prc.call(input)
    rescue InputError
      print "#{error_message}: "
      retry
    end

    input
  end

end

if __FILE__ == $PROGRAM_NAME
  checkers = Checkers.new("Colin", "Other guy", 12)
  checkers.run
end