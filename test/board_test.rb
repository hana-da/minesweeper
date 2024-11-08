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

    cells.each_slice(width).to_a
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

    8.times do |x|
      4.times do |y|
        next if [x, y] in [2, 1] | [5, 2]

        b.open(x:, y:)
      end
    end

    assert b.finished?
  end
end
