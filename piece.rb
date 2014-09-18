class Piece
  attr_reader :board, :color
  attr_writer :pos

  def initialize(board, color, pos)
    @board, @color = board, color
    board.add_piece(self, pos)

    @king = false
  end

  def king?
    @king
  end

  def king_me
    @king = true
  end

  def inspect
    (king? ? ?K : ?n).inspect
  end

end