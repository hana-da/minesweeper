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

  def assert_cell_opened(x:, y:)
    assert cell(x:, y:).opened?
  end

  def assert_cell_closed(x:, y:)
    refute cell(x:, y:).opened?
  end

  def assert_cell_neighbors_mine_count(expect, x:, y:)
    assert expect, cell(x:, y:).neighbors_mine_count
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

    assert cell(x: 2, y: 1).flagged?
    assert cell(x: 5, y: 2).flagged?

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

    assert_cell_neighbors_mine_count 8, x:  1, y: 1
    assert_cell_neighbors_mine_count 7, x:  3, y: 1
    assert_cell_neighbors_mine_count 6, x:  5, y: 1
    assert_cell_neighbors_mine_count 5, x:  7, y: 1
    assert_cell_neighbors_mine_count 4, x:  9, y: 1
    assert_cell_neighbors_mine_count 3, x: 11, y: 1
    assert_cell_neighbors_mine_count 2, x: 13, y: 1
    assert_cell_neighbors_mine_count 1, x: 15, y: 1
    assert_cell_neighbors_mine_count 0, x: 17, y: 1
  end

  def test_openメソッドで何もないCellを開く
    b = Board.new(grid_with_map('-'))

    b.open(x: 0, y: 0)
    assert_cell_opened(x: 0, y: 0)
  end

  def test_openメソッドでmineが埋まっているCellを開く
    b = Board.new(grid_with_map('x'))

    assert_raises(Board::GameOver) { b.open(x: 0, y: 0) }
  end

  def test_openメソッドでCellがない所を開いても何も起きない
    b = Board.new(grid_with_map('-'))

    b.open(x: 1, y: 1)
    assert_cell_closed(x: 0, y: 0)
  end

  def test_openメソッドで旗が立っている所は開けない
    b = Board.new(grid_with_map('-'))

    b.flag(x: 0, y: 0)
    assert_cell_closed(x: 0, y: 0)
  end

  def test_openメソッドでCellを開いたところが0だったら回りを連鎖的に開く
    b = Board.new(grid_with_map(<<~MAP))
      ??1-
      ?x1-
      111-
      ----
    MAP

    b.open(x: 3, y: 2)
    assert_cell_closed(x: 0, y: 0)
    assert_cell_closed(x: 1, y: 0)
    assert_cell_opened(x: 2, y: 0)
    assert_cell_opened(x: 3, y: 0)

    assert_cell_closed(x: 0, y: 1)
    assert_cell_closed(x: 1, y: 1)
    assert_cell_opened(x: 2, y: 1)
    assert_cell_opened(x: 3, y: 1)

    assert_cell_opened(x: 0, y: 2)
    assert_cell_opened(x: 1, y: 2)
    assert_cell_opened(x: 2, y: 2)
    assert_cell_opened(x: 3, y: 2)

    assert_cell_opened(x: 0, y: 3)
    assert_cell_opened(x: 1, y: 3)
    assert_cell_opened(x: 2, y: 3)
    assert_cell_opened(x: 3, y: 3)
  end

  def test_openメソッドでchordingして開いたら成功した
    b = Board.new(grid_with_map(<<~MAP))
      ----
      -x--
      --1-
      ----
    MAP

    b.flag(x: 1, y: 1)
    b.open(x: 2, y: 2)

    assert_cell_closed(x: 1, y: 1)
    assert_cell_closed(x: 2, y: 1)
    assert_cell_closed(x: 3, y: 1)

    assert_cell_closed(x: 1, y: 2)
    assert_cell_opened(x: 2, y: 2)
    assert_cell_closed(x: 3, y: 2)

    assert_cell_closed(x: 1, y: 3)
    assert_cell_closed(x: 2, y: 3)
    assert_cell_closed(x: 3, y: 3)

    b.open(x: 2, y: 2)

    assert_cell_closed(x: 1, y: 1)
    assert_cell_opened(x: 2, y: 1)
    assert_cell_opened(x: 3, y: 1)

    assert_cell_opened(x: 1, y: 2)
    assert_cell_opened(x: 2, y: 2)
    assert_cell_opened(x: 3, y: 2)

    assert_cell_opened(x: 1, y: 3)
    assert_cell_opened(x: 2, y: 3)
    assert_cell_opened(x: 3, y: 3)
  end

  def test_openメソッドでchordingする時、旗が立ってないと発動しない
    b = Board.new(grid_with_map(<<~MAP))
      ----
      -x--
      --1-
      ----
    MAP

    b.open(x: 2, y: 2)

    assert_cell_closed(x: 1, y: 1)
    assert_cell_closed(x: 2, y: 1)
    assert_cell_closed(x: 3, y: 1)

    assert_cell_closed(x: 1, y: 2)
    assert_cell_opened(x: 2, y: 2)
    assert_cell_closed(x: 3, y: 2)

    assert_cell_closed(x: 1, y: 3)
    assert_cell_closed(x: 2, y: 3)
    assert_cell_closed(x: 3, y: 3)

    b.open(x: 2, y: 2)

    assert_cell_closed(x: 1, y: 1)
    assert_cell_closed(x: 2, y: 1)
    assert_cell_closed(x: 3, y: 1)

    assert_cell_closed(x: 1, y: 2)
    assert_cell_opened(x: 2, y: 2)
    assert_cell_closed(x: 3, y: 2)

    assert_cell_closed(x: 1, y: 3)
    assert_cell_closed(x: 2, y: 3)
    assert_cell_closed(x: 3, y: 3)
  end

  def test_openメソッドでchordingする時、旗を立て間違えていると失敗
    b = Board.new(grid_with_map(<<~MAP))
      ----
      -xF-
      --1-
      ----
    MAP

    b.open(x: 2, y: 2)
    b.flag(x: 2, y: 1)

    assert_cell_closed(x: 1, y: 1)
    assert_cell_closed(x: 2, y: 1)
    assert_cell_closed(x: 3, y: 1)

    assert_cell_closed(x: 1, y: 2)
    assert_cell_opened(x: 2, y: 2)
    assert_cell_closed(x: 3, y: 2)

    assert_cell_closed(x: 1, y: 3)
    assert_cell_closed(x: 2, y: 3)
    assert_cell_closed(x: 3, y: 3)

    assert_raises(Board::GameOver) { b.open(x: 2, y: 2) }
  end

  def test_flagメソッドで旗を立てたり取ったりする
    b = Board.new(grid_with_map('-'))

    assert_cell_closed(x: 0, y: 0)
    refute cell(x: 0, y: 0).flagged?

    b.flag(x: 0, y: 0)
    assert_cell_closed(x: 0, y: 0)
    assert cell(x: 0, y: 0).flagged?

    b.flag(x: 0, y: 0)
    assert_cell_closed(x: 0, y: 0)
    refute cell(x: 0, y: 0).flagged?
  end

  def test_flagメソッドで枠外を指定
    b = Board.new(grid_with_map('-'))

    b.flag(x: 10, y: 10)
    refute cell(x: 10, y: 10)
    refute cell(x: 0, y: 0).flagged?
  end

  def test_mineでないすべてのCellがopenされていればゲーム終了
    b = Board.new(grid_with_map('-x-'))

    refute b.finished?
    b.open(x: 0, y: 0)
    b.flag(x: 1, y: 0)
    b.open(x: 2, y: 0)

    assert b.finished?
  end

  def test_ゲーム終了の条件に旗は関係ない
    b = Board.new(grid_with_map('-x-'))

    refute b.finished?
    b.open(x: 0, y: 0)
    b.open(x: 2, y: 0)

    assert b.finished?
  end

  class DummyCell < Cell
    def to_s
      'C'
    end
  end

  def test_show
    b = Board.new(Array.new(12) { DummyCell.new }.each_slice(4).to_a)
    stdout, = capture_io { b.show }
    assert_equal <<~TEXT, stdout
      \e[2J\e[1;1H \\x|
      y \\| 0  1  2  3
      ---+------------
        0|CCCC
        1|CCCC
        2|CCCC
      ---+------------
    TEXT
  end

  def test_to_s
    b = Board.new(Array.new(12) { DummyCell.new }.each_slice(4).to_a)
    assert_equal <<~TEXT, b.to_s
       \\x|
      y \\| 0  1  2  3
      ---+------------
        0|CCCC
        1|CCCC
        2|CCCC
      ---+------------
    TEXT
  end
end
