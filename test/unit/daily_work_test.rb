require_relative '../test_case'

class DailyWorkTest < Test::Unit::TestCase
  def test_half_day
    assert_equal 270, DailyWork.new('VENERDÌ 23/05/2014', ['08:30', '13:00']).worked_minutes
  end

  def test_full_day
    assert_equal 480, DailyWork.new('VENERDÌ 23/05/2014', ['08:30', '13:00', '14:00', '17:30']).worked_minutes
  end

  def test_report_perfect_times
    expected_info = 'VENERDÌ 23/05/2014 - 08h 00m =='
    assert_equal expected_info, DailyWork.new('VENERDÌ 23/05/2014', ['08:30', '13:00', '14:00', '17:30']).report
  end

  def test_report_less_times
    expected_info = 'VENERDÌ 23/05/2014 - 07h 59m -00h 01m'
    assert_equal expected_info, DailyWork.new('VENERDÌ 23/05/2014', ['08:30', '13:00', '14:00', '17:29']).report
  end

  def test_report_more_times
    expected_info = 'VENERDÌ 23/05/2014 - 08h 01m +00h 01m'
    assert_equal expected_info, DailyWork.new('VENERDÌ 23/05/2014', ['08:30', '13:00', '14:00', '17:31']).report
  end

  def test_equality
    assert_equal DailyWork.new('VENERDÌ 23/05/2014', ['08:30', '13:00', '14:00', '17:30']), DailyWork.new('VENERDÌ 23/05/2014', ['08:30', '13:00', '14:00', '17:30'])
    assert_not_equal DailyWork.new('VENERDÌ 23/05/2014', ['08:30', '13:00', '14:00', '17:30']), DailyWork.new('GIOVEDÌ 23/05/2014', ['08:30', '13:00', '14:00', '17:30'])
    assert_not_equal DailyWork.new('VENERDÌ 23/05/2014', ['08:30', '13:00', '14:00', '17:30']), DailyWork.new('GIOVEDÌ 23/05/2014', ['08:29', '13:00', '14:00', '17:30'])
  end
end