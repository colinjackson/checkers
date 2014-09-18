load './piece.rb'

class Board
  attr_reader :rows, :board_size

  def self.make_rows(board_size)
    Array.new(board_size) { Array.new(board_size) }
  end

  def initialize(set_pieces = true, board_size = 8)
    @board_size = board_size
    @rows = Board.make_rows(board_size)
    add_pieces if set_pieces
  end

  def [](square)
    row, col = square
    rows[row][col]
  end

  def []=(square, value)
    row, col = square
    rows[row][col] = value
  end

  def add_piece(piece, square)
    self[square] = piece
    piece.square = square
  end

  def add_pieces
    white_range, black_range = get_piece_ranges

    self.rows.each_with_index do |row, row_i|
      if white_range.include?(row_i)
        color = :white
      elsif black_range.include?(row_i)
        color = :black
      else
        next
      end

      set_row(row, row_i, color)
    end
  end

  def get_piece_ranges
    board_mid = self.rows.count / 2
    white_range = 0...(board_mid - 1)
    black_range = (board_mid + 1)...rows.count
    [white_range, black_range]
  end

  def set_row(row, row_i, color)
    row.count.times do |col_i|
      next unless (row_i + col_i).odd?

      square = [row_i, col_i]
      Piece.new(self, color, square)
    end
  end
end