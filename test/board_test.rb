# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../minesweeper'

class BoardTest < Minitest::Test
  def setup
    $stdout = File.open('/dev/null', 'w')
  end

  def teardown
    $stdout.close
    $stdout = STDOUT
  end

  def replace_cells_with_map(board, map) # rubocop:disable Metrics/AbcSize
    width = map.lines.first.chomp.length
    cells = Array.new(map.delete("\n").size) { Cell.new }
    map.each_char.with_index { |c, i| c == 'x' && cells[i].plant_mine }

    @cells = board.instance_variable_set(:@cells, cells)
    @grid = board.instance_variable_set(:@grid, cells.each_slice(width).to_a)
    board.send(:set_neighbors_mine_count_to_all_of_cells)
  end

  def cell(x:, y:)
    @grid.dig(y, x)
  end

  def test_デフォルトのBoard
    b = Board.new
    assert_equal 9 + 4, b.show
    refute b.finished?

    assert_raises(Board::GameOver) do
      9.times do |x|
        9.times do |y|
          b.open(x:, y:)
        end
      end
    end
  end

  def test_test用のmine位置を指定したBoard
    b = Board.new
    replace_cells_with_map(b, <<~MAP)
      ---------
      ---------
      ---------
      ---------
      ---------
      ---------
      ---------
      ---------
      ---------
    MAP

    assert_equal 9 + 4, b.show
    refute b.finished?

    9.times do |x|
      9.times do |y|
        b.open(x:, y:)
      end
    end

    assert b.finished?
  end

  def test_flagメソッドで旗を立てたり取ったりする
    b = Board.new

    replace_cells_with_map(b, '-')
    refute cell(x: 0, y: 0).opened?
    refute cell(x: 0, y: 0).flaged?

    b.flag(x: 0, y: 0)
    refute cell(x: 0, y: 0).opened?
    assert cell(x: 0, y: 0).flaged?

    b.flag(x: 0, y: 0)
    refute cell(x: 0, y: 0).opened?
    refute cell(x: 0, y: 0).flaged?
  end

  def test_flagメソッドで枠外を指定
    b = Board.new
    replace_cells_with_map(b, '-')

    b.flag(x: 10, y: 10)
    refute cell(x: 10, y: 10)
    refute cell(x: 0, y: 0).flaged?
  end
end
