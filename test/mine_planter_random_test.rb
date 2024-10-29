# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../minesweeper'

class MinePlanter
  class RandomTest < Minitest::Test
    def test_initialize
      assert_raises(ArgumentError) { MinePlanter::Random.new }
    end

    def test_3個のmineを埋める
      planter = MinePlanter::Random.new(3)

      cells = Array.new(2) { Cell.new }
      planter.plant_to(cells)
      assert_equal 2, cells.count(&:mine?)

      cells = Array.new(3) { Cell.new }
      planter.plant_to(cells)
      assert cells.all?(&:mine?)

      cells = Array.new(4) { Cell.new }
      planter.plant_to(cells)
      assert_equal 3, cells.count(&:mine?)
    end
  end
end
