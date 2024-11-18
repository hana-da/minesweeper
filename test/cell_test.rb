# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../minesweeper'

class CellTest < Minitest::Test
  def test_Cellの初期状態
    cell = Cell.new

    refute cell.mine?
    refute cell.opened?
    refute cell.flaged?
    refute cell.resolved?
    assert_nil cell.neighbors_mine_count

    assert_equal '⬜ ', cell.to_s
  end

  def test_Cellにmineを埋める
    cell = Cell.new
    assert_equal cell, cell.plant_mine

    assert cell.mine?
    refute cell.opened?
    refute cell.flaged?
    assert cell.resolved?
    assert_nil cell.neighbors_mine_count

    assert_equal '⬜ ', cell.to_s
  end

  def test_mineが埋まっていないCellを開く
    cell = Cell.new
    assert_equal cell, cell.open

    refute cell.mine?
    assert cell.opened?
    refute cell.flaged?
    assert cell.resolved?
    assert_nil cell.neighbors_mine_count

    assert_raises(NoMethodError) { cell.to_s }
  end

  def test_mineが埋まっているCellを開く
    cell = Cell.new
    assert_equal cell, cell.plant_mine
    assert_equal cell, cell.open

    assert cell.mine?
    assert cell.opened?
    refute cell.flaged?
    assert cell.resolved?
    assert_nil cell.neighbors_mine_count

    assert_equal '💣 ', cell.to_s
  end

  def test_旗を立てる
    cell = Cell.new
    assert_equal cell, cell.toggle_flag

    refute cell.mine?
    refute cell.opened?
    assert cell.flaged?
    refute cell.resolved?
    assert_nil cell.neighbors_mine_count

    assert_equal '🚩 ', cell.to_s
  end

  def test_旗を取る
    cell = Cell.new.toggle_flag
    assert_equal cell, cell.toggle_flag

    refute cell.mine?
    refute cell.opened?
    refute cell.flaged?
    refute cell.resolved?
    assert_nil cell.neighbors_mine_count

    assert_equal '⬜ ', cell.to_s
  end

  def test_周辺のmine数が設定されたCellが開かれている時のto_s
    cell = Cell.new.open

    cell.neighbors_mine_count = 0
    assert_equal '　 ', cell.to_s

    cell.neighbors_mine_count = 1
    assert_equal "#{Cell::NUMBER_COLOR[1]}#{Cell::BOLD}１ #{Cell::COLOR_RESET}", cell.to_s

    cell.neighbors_mine_count = 2
    assert_equal "#{Cell::NUMBER_COLOR[2]}#{Cell::BOLD}２ #{Cell::COLOR_RESET}", cell.to_s

    cell.neighbors_mine_count = 3
    assert_equal "#{Cell::NUMBER_COLOR[3]}#{Cell::BOLD}３ #{Cell::COLOR_RESET}", cell.to_s

    cell.neighbors_mine_count = 4
    assert_equal "#{Cell::NUMBER_COLOR[4]}#{Cell::BOLD}４ #{Cell::COLOR_RESET}", cell.to_s

    cell.neighbors_mine_count = 5
    assert_equal "#{Cell::NUMBER_COLOR[5]}#{Cell::BOLD}５ #{Cell::COLOR_RESET}", cell.to_s

    cell.neighbors_mine_count = 6
    assert_equal "#{Cell::NUMBER_COLOR[6]}#{Cell::BOLD}６ #{Cell::COLOR_RESET}", cell.to_s

    cell.neighbors_mine_count = 7
    assert_equal "#{Cell::NUMBER_COLOR[7]}#{Cell::BOLD}７ #{Cell::COLOR_RESET}", cell.to_s

    cell.neighbors_mine_count = 8
    assert_equal "#{Cell::NUMBER_COLOR[8]}#{Cell::BOLD}８ #{Cell::COLOR_RESET}", cell.to_s
  end

  def test_9x9でmineが10個のCell配列を生成する
    cells = Cell.grid_with_mine.flatten

    assert(cells.all? { it.instance_of?(Cell) })
    assert_equal 9 * 9, cells.size
    assert_equal 10, cells.count(&:mine?)
  end
end
