# frozen_string_literal: true

class Board
  class GameOver < StandardError; end

  NEIGHBORS_DIRECTIONS = [
    [-1, -1], [0, -1], [+1, -1],
    [-1,  0],          [+1,  0], # rubocop:disable Layout/ExtraSpacing
    [-1, +1], [0, +1], [+1, +1]
  ].freeze

  ESC_SEQ = {
    ED:  "\033[2J",   # Erase in Display
    CUP: "\033[1;1H", # Cursor Position (top left corner)
  }.freeze

  private attr_reader :grid, :cells

  def initialize(width: 9, height: 9, mine_count: 10)
    @cells = make_cells_with_mine(width:, height:, mine_count:)
    @grid = cells.each_slice(width).to_a
    set_neighbors_mine_count_to_all_of_cells
  end

  def open(x:, y:)
    cell = self[x:, y:]
    return unless cell&.openable?

    cell.open
    if cell.mine?
      raise GameOver
    elsif cell.neighbors_mine_count.zero?
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
    cells.all?(&:resolved?)
  end

  def show
    print ESC_SEQ.values_at(:ED, :CUP).join
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

  private def set_neighbors_mine_count_to_all_of_cells
    height.times do |y|
      width.times do |x|
        self[x:, y:].neighbors_mine_count = neighbors_cells_of(x:, y:).count(&:mine?)
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
  NUMBER_COLOR = [
    "\033[0m",  # 白(Reset or normal)
    "\033[94m", # 青(Bright Blue)
    "\033[32m", # 緑(Green)
    "\033[91m", # 赤(Bright Red)
    "\033[34m", # 紺(Blue)
    "\033[31m", # 茶(Red)
    "\033[36m", # シアン(Cyan)
    "\033[0m",  # 黒(Reset or normal)
    "\033[90m", # 灰(Gray)
  ].freeze
  BOLD = "\033[1m"
  COLOR_RESET = NUMBER_COLOR[0]

  attr_accessor :neighbors_mine_count

  private attr_accessor :mine, :opened, :flaged

  def initialize
    @mine = false
    @opened = false
    @flaged = false
    @neighbors_mine_count = nil
  end

  def mine? = mine
  def opened? = opened
  def flaged? = flaged
  def resolved? = opened? || (flaged? && mine?)
  def openable? = !(opened? || flaged?)

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
      '⚠️ '
    else
      '⬜ '
    end
  end

  def icon
    @icon ||= if mine?
                '💣 '
              elsif neighbors_mine_count.zero?
                '　 '
              else
                (NUMBER_COLOR[neighbors_mine_count] + BOLD +
                  (0xff10 + neighbors_mine_count).chr(Encoding::UTF_8)) <<
                  " #{COLOR_RESET}"
              end
  end
end

if __FILE__ == $0 # rubocop:disable Style/SpecialGlobalVars
  history = []
  history_count = 20
  prompt = '> '

  b = Board.new

  loop do
    b.show
    puts prompt
    history.first(history_count).each { puts "  #{it}" }

    print "\033[#{[history.size, history_count].min + 1}A" # Cursor Up
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
