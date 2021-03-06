class InvalidMoveError < RuntimeError
end

class Piece
  UP_SLIDES, DOWN_SLIDES = [[-1, -1], [-1, 1]], [[1, -1], [1, 1]]
  ICONS = ['✬', '✪']

  attr_reader :board, :color
  attr_accessor :square

  def initialize(board, color, square)
    @board, @color = board, color
    board.add_piece(self, square)

    @king = false
  end

  def perform_moves(squares)
    raise InvalidMoveError unless valid_moves?(squares)
    perform_moves!(squares)
  end

  def perform_moves!(squares)
    squares.each do |to_square|
      if squares.count == 1 && reachable_squares(slides).include?(to_square)
        perform_slide(to_square)
      elsif reachable_squares(jumps).include?(to_square)
        perform_jump(to_square)
      else
        raise InvalidMoveError
      end
    end

    king_me! if !king? && back_row?
  end

  def perform_slide(to_square)
    raise InvalidMoveError unless valid_move?(to_square)

    update_position(to_square)
    true
  end

  def perform_jump(to_square)
    return InvalidMoveError unless valid_move?(to_square)

    jumped = jumped_square(to_square)
    board[jumped] = nil
    update_position(to_square)
    sleep 0.5
    true
  end

  def update_position(to_square)
    board[self.square] = nil
    board.add_piece(self, to_square)
    board.draw
  end

  def slides
    return UP_SLIDES + DOWN_SLIDES if king?
    color == :black ? UP_SLIDES : DOWN_SLIDES
  end

  def jumps
    slides.map do |slide|
      slide.map { |dir| dir * 2 }
    end
  end

  def valid_move?(to_square)
    return false unless board[to_square].nil?

    if reachable_squares(slides).include?(to_square)
      true
    elsif reachable_squares(jumps).include?(to_square)
      jumped = jumped_square(to_square)
      board[jumped] && board[jumped].color != self.color
    else
      false
    end
  end

  def valid_moves?(squares)
    test_board = board.dup
    test_piece = test_board[self.square]
    begin
      test_piece.perform_moves!(squares)
    rescue InvalidMoveError
      false
    else
      true
    end
  end

  def reachable_squares(moves)
    reachable_squares = []

    row_i, col_i = self.square
    moves.each do |move|
      d_row, d_col = move
      square = [row_i + d_row, col_i + d_col]
      next unless square.all? { |i| i.between?(0, board.board_size - 1) }

      reachable_squares << square
    end

    reachable_squares
  end

  def jumped_square(to_square)
    from_row, from_col = self.square
    to_row, to_col = to_square

    mid_row = (from_row + to_row) / 2
    mid_col = (from_col + to_col) / 2
    [mid_row, mid_col]
  end

  def king?
    @king
  end

  def king_me!
    @king = true
  end

  def back_row?
    square[0] == (color == :black ? 0 : board.board_size - 1 )
  end

  def icon
    icon = king? ? ICONS[1] : ICONS[0]
    color == :black ? icon : icon.red
  end

end