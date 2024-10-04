# frozen_string_literal: true

class Board
  class GameOver < StandardError; end

  NEIGHBORS_DIRECTIONS = [
    [-1, -1], [0, -1], [+1, -1],
    [-1,  0],          [+1,  0], # rubocop:disable Layout/ExtraSpacing
    [-1, +1], [0, +1], [+1, +1]
  ].freeze

  ESC_SEQ = {
    clear: "\033[2J",
    home:  "\033[1;1H",
  }.freeze

  private attr_reader :grid, :cells

  def initialize(width: 9, height: 9, mine_count: 10)
    @cells = make_cells_with_mine(width:, height:, mine_count:)
    @grid = cells.each_slice(width).to_a
    set_mine_count_to_all_of_cells
  end

  def open(x:, y:)
    cell = self[x:, y:]
    return if cell.nil? || cell.opened?

    cell.open
    if cell.mine?
      raise GameOver
    elsif cell.count.zero?
      neighbors_coordinates_of(x:, y:).each { self.open(x: _1, y: _2) }
    end

    cell
  end
  alias o open

  def flag(x:, y:)
    self[x:, y:]&.toggle_flag
  end
  alias f flag

  def finished?
    cells.all? { it.correct? }
  end

  def show
    print ESC_SEQ.values_at(:clear, :home).join
    print 'y\x|', Array.new(width) { format('%2d', it) }.join(' '), "\n"
    puts "---+#{'---' * width}"
    puts self
    puts "---+#{'---' * width}"
  end

  def to_s
    grid.map.with_index { |row, y| format('%<y>3d|%<row>s', y:, row: row.join) }.join("\n")
  end

  private def width = grid.first.size
  private def height = grid.size

  private def make_cells_with_mine(width:, height:, mine_count:)
    Array.new(width * height) { Cell.new }.tap do |cells|
      cells.sample(mine_count).each(&:plant_mine)
    end
  end

  private def set_mine_count_to_all_of_cells
    height.times do |y|
      width.times do |x|
        self[x:, y:].count = neighbors_cells_of(x:, y:).count(&:mine?)
      end
    end
  end

  private def [](x:, y:)
    grid.at(y)&.at(x)
  end

  private def neighbors_cells_of(x:, y:)
    neighbors_coordinates_of(x:, y:).filter_map { self[x: _1, y: _2] }
  end

  private def neighbors_coordinates_of(x:, y:)
    NEIGHBORS_DIRECTIONS.filter_map do |dx, dy|
      nx = x + dx
      ny = y + dy
      next if [nx, ny].min.negative?

      [nx, ny]
    end
  end
end

class Cell
  attr_accessor :count

  private attr_accessor :mine, :opened, :flaged

  def initialize
    @mine = false
    @opened = false
    @flaged = false
    @count = nil
  end

  def mine? = mine
  def opened? = opened
  def flaged? = flaged
  def correct? = opened? || (flaged? && mine?)

  def plant_mine
    tap { self.mine = true }
  end

  def open
    tap { self.opened = true }
  end

  def toggle_flag
    tap { self.flaged = !flaged }
  end

  def to_s
    if opened?
      icon
    elsif flaged?
      "⚠️\u200B"
    else
      "⬜️\u200B"
    end
  end

  def icon
    @icon ||= if mine?
                "💣\u200B"
              elsif count.zero?
                "　\u200B"
              else
                (0xff10 + count).chr(Encoding::UTF_8) << "\u200B"
              end
  end
end

if __FILE__ == $0 # rubocop:disable Style/SpecialGlobalVars
  history = []
  prompt = '> '

  b = Board.new

  loop do
    b.show
    puts prompt
    history.each { puts "  #{it}" }

    print "\033[#{history.size + 1}A"
    print prompt
    history.unshift(gets.chomp)

    b.instance_eval(history.first) # 雑でごめん

    break if b.finished?
  rescue NameError, ArgumentError, SyntaxError => e
    history.unshift(*e.message.lines)
  rescue Board::GameOver
    break
  end
  b.show
end
