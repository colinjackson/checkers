require 'colorize'
load './piece.rb'

class Board
  attr_reader :rows, :board_size

  def self.make_rows(board_size)
    Array.new(board_size) { Array.new(board_size) }
  end

  def initialize(board_size = 8, set_pieces = true)
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

  def dup
    dup_board = Board.new(board_size, false)
    dup_board.rows = self.rows.map do |row|
      row.map do |piece|
        next unless piece
        new_piece = Piece.new(dup_board, piece.color, piece.square.dup)
        new_piece.king_me! if piece.king?
        new_piece
      end
    end

    dup_board
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

  def draw(selected = nil)
    render = render_board(selected)
    add_sides(render)
    add_top_and_bottom(render)
    add_padding(render)

    system('clear')
    print "\n" * 5
    puts render
  end

  def render_board(selected)
    render = []
    board_size.times do |row_i|
      row_render = ""

      board_size.times do |col_i|
        square = [row_i, col_i]
        icon = self[square] ? self[square].icon : " "
        next row_render += " #{icon} ".on_green if square == selected
        row_render += (row_i + col_i).odd? ? " #{icon} " : " #{icon} ".on_white
      end
      render << row_render
    end

    render
  end

  def add_sides(render)
    render.map!.with_index do |line, index|
      row = board_size - index
      row_str = row < 10 ? " #{row}" : "#{row}"
      edge = " ║ "

      "#{row_str}#{edge}#{line}#{edge.reverse}#{row_str}"
    end
  end

  def add_top_and_bottom(render)
    vertical = "═" * 3 * board_size
    top_bound = "   ╔═" + vertical + "═╗   "
    bottom_bound = "   ╚═" + vertical + "═╝   "
    render.unshift(top_bound)
    render.push(bottom_bound)

    alpha_line = " " * 5
    ('A'..'L').each_with_index do |letter, index|
      next unless index < board_size
      alpha_line += " #{letter} "
    end
    render.unshift(alpha_line)
    render.push(alpha_line)
  end

  def add_padding(render)
    win_width = `tput cols`.to_i
    render_width = board_size * 3 + 10
    return if render_width > win_width
    padding_length = (win_width - render_width) / 2
    padding = ' ' * padding_length

    render.map! { |line| padding + line }
  end

  def over?
    [:white, :black].any? { |color| lost?(color) }
  end

  def won?(color)
    other_color = color == :black ? :white : :black
    lost?(other_color)
  end

  def lost?(color)
    rows.flatten.compact.none? { |piece| piece.color == color }
  end

  protected
  attr_writer :rows

end