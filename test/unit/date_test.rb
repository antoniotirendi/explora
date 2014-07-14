require_relative '../test_case'

class DateTest < Test::Unit::TestCase
  def test_business_days_until
    assert_equal [Date.parse('13/06/2014'), Date.parse('16/06/2014'), Date.parse('17/06/2014')],
                 Date.parse('13/06/2014').business_days_until(Date.parse('17/06/2014'))
  end
end