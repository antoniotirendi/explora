module FormatTime
  def format_in_hours(minutes)
    hours=minutes/60
    minutes -= hours * 60

    "#{format_with_two_digits(hours)}h #{format_with_two_digits(minutes)}m"
  end

  def formatted_difference_times(minutes)
    return '==' if minutes == 0
    sign = minutes > 0 ? '+' : '-'
    "#{sign}#{format_in_hours(minutes.abs)}"
  end

  def format_with_two_digits(times)
    times < 10 ? "0#{times}" : times
  end
end