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

  def grid_with_map(map)
    width = map.lines.first.chomp.length
    map = map.delete("\n")

    cells = Array.new(map.size) { Cell.new }
    map.each_char.with_index { |c, i| c == 'x' && cells[i].plant_mine }

    @grid = cells.each_slice(width).to_a
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
    b = Board.new(grid_with_map(<<~MAP))
      --------
      --x-----
      -----x--
      --------
    MAP

    assert_equal 4 + 4, b.show
    refute b.finished?

    b.flag(x: 2, y: 1)
    b.flag(x: 5, y: 2)

    assert cell(x: 2, y: 1).flaged?
    assert cell(x: 5, y: 2).flaged?

    8.times do |x|
      4.times do |y|
        next if [x, y] in [2, 1] | [5, 2]

        b.open(x:, y:)
      end
    end

    assert b.finished?
  end

  def test_flagメソッドで旗を立てたり取ったりする
    b = Board.new(grid_with_map('-'))

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
    b = Board.new(grid_with_map('-'))

    b.flag(x: 10, y: 10)
    refute cell(x: 10, y: 10)
    refute cell(x: 0, y: 0).flaged?
  end
end
