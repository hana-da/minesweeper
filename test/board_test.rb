# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../minesweeper'

class MinePlanter
  class Preset < MinePlanter
    attr_reader :mine_positions

    def initialize(mine_positions)
      super()
      @mine_positions = mine_positions.chars
    end

    def plant_to(cells)
      mine_positions.each_with_index do |mark, i|
        mark == 'x' && cells[i].plant_mine
      end
    end
  end
end

class BoardTest < Minitest::Test
  def setup
    $stdout = File.open('/dev/null', 'w')
  end

  def teardown
    $stdout.close
    $stdout = STDOUT
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

  def test_PresetMinePlanterを使ったBoard
    b = Board.new(planter: MinePlanter::Preset.new(<<~MAP))
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
end
