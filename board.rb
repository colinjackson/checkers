load './piece.rb'

class Board
  attr_reader :rows

  def self.make_rows(board_size)
    Array.new(board_size) { Array.new(board_size) }
  end

  def initialize(set_pieces = true, board_size = 8)
    @rows = Board.make_rows(board_size)
    add_pieces if set_pieces
  end

  def [](pos)
    row, col = pos
    rows[row][col]
  end

  def []=(pos, value)
    row, col = pos
    rows[row][col] = value
  end

  def add_piece(piece, pos)
    self[pos] = piece
    piece.pos = pos
  end

  def add_pieces
    ranges = get_piece_ranges
    white_range = ranges[0]

    self.rows.each_with_index do |row, row_i|
      next unless ranges.any? { |range| range.include?(row_i) }

      color = white_range.include?(row_i) ? :white : :black
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

      pos = [row_i, col_i]
      self[pos] = (color.to_s)[0]
    end
  end
end