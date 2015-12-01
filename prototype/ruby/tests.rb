require 'minitest/autorun'
require_relative 'level_zero'
require_relative 'level_one'
# require_relative 'level_two'

class TestLevelZero < Minitest::Test
  def test_reject_package_markings_l0
    level_one_package = Level0Parser.new('../../examples/level-one-package.json')
    assert_equal "Unable to process package markings", level_one_package.errors.first.first
    refute level_one_package.parsed?

    level_one_override = Level0Parser.new('../../examples/level-one-override.json')
    assert_equal "Unable to process package markings", level_one_override.errors.first.first
    refute level_one_package.parsed?
  end

  def test_reject_marked_objects_l0
    level_one_objects = Level0Parser.new('../../examples/level-one-object.json')
    assert level_one_objects.parsed?
    assert_equal 1, level_one_objects.indicators.length
    assert_equal 2, level_one_objects.errors.length # For the two indicators it couldn't parse
  end

  def test_reject_level_two_package_markings_l0
    level_two_package = Level0Parser.new('../../examples/level-two-package.json')
    refute level_two_package.parsed?
  end

  def test_reject_level_two_object_markings_l0
    level_two_overrides = Level0Parser.new('../../examples/level-two-fields.json')
    assert level_two_overrides.parsed?
    assert_equal 0, level_two_overrides.indicators.length
    assert_equal 1, level_two_overrides.errors.length # For the indicator it couldn't parse
  end
end

class TestLevelOne < Minitest::Test
  def test_mark_package_l1
    level_one_package = Level1Parser.new('../../examples/level-one-package.json')
    assert level_one_package.parsed?
    assert_equal 1, level_one_package.markings.length
    assert_equal "GREEN", level_one_package.markings.first['tlp']
    assert_equal 3, level_one_package.indicators.length
    assert_equal "GREEN", level_one_package.indicators.first.markings.first['tlp']
  end

  def test_mark_objects_l1
    level_one_object = Level1Parser.new('../../examples/level-one-object.json')
    assert level_one_object.parsed?
    assert_equal [], level_one_object.markings
    assert_equal "RED", level_one_object.indicators[0].markings.first['tlp']
    assert_equal "GREEN", level_one_object.indicators[1].markings.first['tlp']
  end

  def test_override_package_markings_l1
    level_one_override = Level1Parser.new('../../examples/level-one-override.json')
    assert level_one_override.parsed?
    assert_equal "GREEN", level_one_override.markings.first['tlp']
    assert_equal 1, level_one_override.indicators[0].markings.length
    assert_equal "RED", level_one_override.indicators[0].markings.first['tlp']
    assert_equal 1, level_one_override.indicators[1].markings.length
    assert_equal "GREEN", level_one_override.indicators[1].markings.first['tlp']
  end

  def test_reject_level_two_package_markings_l1
    level_two_package = Level1Parser.new('../../examples/level-two-package.json')
    refute level_two_package.parsed?
  end

  def test_reject_level_two_object_markings_l1
    level_two_overrides = Level1Parser.new('../../examples/level-two-fields.json')
    assert level_two_overrides.parsed?
    assert_equal 0, level_two_overrides.indicators.length
    assert_equal 1, level_two_overrides.errors.length # For the indicator it couldn't parse
  end

  def test_reject_level_two_overrides_l1
    level_two_overrides = Level1Parser.new('../../examples/level-two-overrides.json')
    assert level_two_overrides.parsed?
    assert_equal 1, level_two_overrides.indicators.length
    assert_equal "GREEN", level_two_overrides.markings.first['tlp']
    assert_equal "GREEN", level_two_overrides.indicators.first.markings.first['tlp']
    assert_equal 1, level_two_overrides.errors.length # For the indicator it couldn't parse
  end
end
