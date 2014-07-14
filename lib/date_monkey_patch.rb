class Date
  def number_of_business_days_until(to_date)
    business_days_until(to_date).size
  end

  def business_days_until(to_date)
    (self..to_date).select { |day| day.workday? }
  end
end