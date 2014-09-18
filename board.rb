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

  def add_pieces
    color_piece_rows.each do |color, piece_rows|
      piece_rows.each_with_index do |row, index|
        offset = (index + (color == :black ? 0 : 1)) % 2
        set_row(row, offset)
      end
    end
  end

  def color_piece_rows
    mid = rows.count / 2
    top_rows = rows[0...(mid - 1)]
    bottom_rows = rows[(mid + 1)...rows.count].reverse

    { white: top_rows, black: bottom_rows }
  end

  def set_row(row, offset)
    rows.count.times do |col|
      row[col] = "PC" if (col + offset).even?
    end
  end
end