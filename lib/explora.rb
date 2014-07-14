class Explora
  include FormatTime

  def initialize
    @lines_for_times=read_times
    @lines_for_workpermits=read_workpermits
    @business_days = business_days
  end

  def read_times
    read_file 'times.txt'
  end

  def read_workpermits
    read_file 'workpermits.txt'
  end

  def read_file(filename)
    File.readlines(File.join(File.dirname(__FILE__), '..', 'local_data', filename))
  end

  def business_days
    worked_days=set_worked_times
    set_permit_times(worked_days)
  end

  def set_worked_times
    days = []
    @lines_for_times.each_slice(2) do |first_line, second_line|
      date = Date.parse(first_line.split("\t")[0].split(' ')[1])
      if date.workday?
        day = BusinessDay.new(date)
        day.add_worked_hours(times_for_day(second_line))
        days << day
      end
    end
    days
  end

  def set_permit_times(worked_days)
    permits_days=[]
    @lines_for_workpermits.each_slice(3) do |first_line, second_line, third_line|
      permits_type = first_line.split("\t")[1].strip
      period_info = second_line.match(/\[(.*)\] \[(.*)\]/)
      minutes=permit_minutes_for(period_info[1])
      dates_range = period_info[2]
      business_dates_for(dates_range).each do |business_date|
        day = business_day_for(business_date, worked_days)
        day.add_permit_minutes(permits_type, minutes)
        permits_days << day
      end
    end
    worked_days | permits_days
  end

  def permit_minutes_for(duration)
    if duration == 'Giornata intera'
      60*8
    else
      format_duration=duration.split(':')[1].strip
      hours=format_duration[0..1].to_i
      minutes=format_duration[2..3].to_i
      minutes+hours*60
    end
  end

  def business_dates_for(period)
    matched_period=period.match(/dal (.*) al (.*)/)
    from=matched_period[1]
    to=matched_period[2]
    Date.parse(from).business_days_until(Date.parse(to))
  end

  def business_day_for(business_date, worked_days)
    existent_day = worked_days.detect { |d| d.date == business_date }
    existent_day || BusinessDay.new(business_date)
  end

  def times_for_day(line)
    worked_times=line.split(/\t/)[1].split('E')
    worked_times.shift
    worked_times.map { |worked_time| worked_time.strip.split(' U') }.flatten
  end

  def overall_report
    infos = []
    @business_days.each do |business_day|
      infos << '-------------------------------------------------------------------------'
      business_day.report.each do |line|
        infos << line
      end
    end
    infos << '========================================================================='
    infos << total_report
    infos << '========================================================================='
  end

  def total_report
    "#{total_business_days}, ore lavorate: #{total_worked_hours}, permessi: #{total_permits_hours}, #{formatted_total_diff_minutes}"
  end

  def total_worked_hours
    format_in_hours(total_minutes_for(:worked_minutes))
  end

  def total_permits_hours
    format_in_hours(total_minutes_for(:permit_minutes))
  end

  def formatted_total_diff_minutes
    formatted_difference_times(total_minutes_for(:total_diff_minutes))
  end

  def total_business_days
    label = @business_days.count == 1 ? 'Giorno lavorativo' : 'Giorni lavorativi'
    "#{@business_days.count} #{label}"
  end

  def total_minutes_for(attribute)
    @business_days.inject(0) { |sum, business_day| sum + business_day.send(attribute) }
  end

  def print_overall_report
    overall_report.each { |line| p line }
  end
end