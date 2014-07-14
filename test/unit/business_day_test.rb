require_relative '../test_case'

class BusinessDayTest < Test::Unit::TestCase
  setup do
    @day=BusinessDay.new(Date.new(2014, 05, 23))
  end

  def test_add_worked_hours_half_day
    @day.add_worked_hours(['08:30', '13:00'])
    assert_equal 270, @day.worked_minutes
  end

  def test_add_worked_hours_full_day
    @day.add_worked_hours(['08:30', '13:00', '14:00', '17:30'])
    assert_equal 480, @day.worked_minutes
  end

  def test_add_permit_hours_partial
    @day.add_permit_minutes('RIDUZ. ORARIO', 60)
    @day.add_permit_minutes('RIDUZ. ORARIO', 60)
    assert_equal 120, @day.permit_minutes
  end

  def test_add_permit_hours_full_day
    @day.add_permit_minutes('FERIE', 480)
    assert_equal 480, @day.permit_minutes
  end

  def test_report_8_hours_worked
    @day.add_worked_hours(['08:30', '13:00', '14:00', '17:30'])
    assert_equal ['FRIDAY 23/05/2014 ore lavorate: 08h 00m =='], @day.report
  end

  def test_report_less_than_8_hours_worked
    @day.add_worked_hours(['08:31', '13:00', '14:00', '17:30'])
    assert_equal ['FRIDAY 23/05/2014 ore lavorate: 07h 59m -00h 01m'], @day.report
  end

  def test_report_more_than_8_hours_worked
    @day.add_worked_hours(['08:29', '13:00', '14:00', '17:30'])
    assert_equal ['FRIDAY 23/05/2014 ore lavorate: 08h 01m +00h 01m'], @day.report
  end

  def test_report_permit_full_day
    @day.add_permit_minutes('FERIE', 480)
    assert_equal ['FRIDAY 23/05/2014 ore lavorate: - -08h 00m',
                  'FERIE - 08h 00m',
                  'Totale giornaliero: 08h 00m =='], @day.report
  end

  def test_report_partial_permit
    @day.add_worked_hours(['08:30','13:00'])
    @day.add_permit_minutes('RIDUZ. ORARIO', 240)
    assert_equal ['FRIDAY 23/05/2014 ore lavorate: 04h 30m -03h 30m',
                  'RIDUZ. ORARIO - 04h 00m',
                  'Totale giornaliero: 08h 30m +00h 30m'], @day.report
  end

  def test_report_transfer
    @day.add_permit_minutes('TRASFERTA', 480)
    assert_equal ['FRIDAY 23/05/2014 ore lavorate: - -08h 00m',
                  'TRASFERTA - 08h 00m',
                  'Totale giornaliero: 08h 00m =='], @day.report
  end

  def test_equality
    a_day = BusinessDay.new(Date.parse('23/05/2014'))
    a_day.add_worked_hours(['08:30', '13:00', '14:00', '17:30'])

    same_day = BusinessDay.new(Date.parse('23/05/2014'))
    same_day.add_worked_hours(['08:30', '13:00', '14:00', '17:30'])

    another_day = BusinessDay.new(Date.parse('22/05/2014'))
    another_day.add_worked_hours(['08:30', '13:00', '14:00', '17:30'])

    another_day_too = BusinessDay.new(Date.parse('23/05/2014'))
    another_day_too.add_worked_hours(['08:22', '13:00', '14:00', '17:30'])

    assert_equal a_day, same_day
    assert_not_equal a_day, another_day
    assert_not_equal a_day, another_day_too
  end
end