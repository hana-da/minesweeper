# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../minesweeper'

class BoardTest < Minitest::Test
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

    capture_io do
      assert_equal 9 + 4, b.show
      refute b.finished?
    end

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

    capture_io do
      assert_equal 4 + 4, b.show
      refute b.finished?
    end

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

  def test_BoardにCellを渡すと近隣のmine数がセットされる
    grid_with_map(<<~MAP)
      xxxx--x------------
      x8x7x6x5-4x3-2-1-0-
      xxxxxxxxxxxx-xx----
    MAP

    assert(@grid.flatten.all? { it.neighbors_mine_count.nil? })

    Board.new(@grid)
    assert(@grid.flatten.none? { it.neighbors_mine_count.nil? })

    assert_equal 8, cell(x:  1, y: 1).neighbors_mine_count
    assert_equal 7, cell(x:  3, y: 1).neighbors_mine_count
    assert_equal 6, cell(x:  5, y: 1).neighbors_mine_count
    assert_equal 5, cell(x:  7, y: 1).neighbors_mine_count
    assert_equal 4, cell(x:  9, y: 1).neighbors_mine_count
    assert_equal 3, cell(x: 11, y: 1).neighbors_mine_count
    assert_equal 2, cell(x: 13, y: 1).neighbors_mine_count
    assert_equal 1, cell(x: 15, y: 1).neighbors_mine_count
    assert_equal 0, cell(x: 17, y: 1).neighbors_mine_count
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
