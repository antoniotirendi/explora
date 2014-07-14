class BusinessDay
  include FormatTime
  attr_reader :date
  MINUTES_TO_DO=480

  def initialize(date)
    @date = date
    @worked_times = []
    @permit_type = nil
    @permit_minutes = 0
  end

  def add_worked_hours(times)
    @worked_times |= times
  end

  def add_permit_minutes(type, minutes)
    @permit_type = type
    @permit_minutes += minutes
  end

  def worked_minutes
    total_minutes = 0
    times_in_out = @worked_times.each_slice(2).to_a
    times_in_out.each do |time_in, time_out|
      worked_seconds = Time.parse(time_out) - Time.parse(time_in)
      total_minutes += worked_seconds.to_i/60
    end
    total_minutes
  end

  def permit_minutes
    @permit_minutes
  end

  def report
    [report_work_times,
     *report_permit_minutes]
  end

  def report_work_times
    "#{@date.strftime('%^A %d/%m/%Y')} ore lavorate: #{format_in_hours(worked_minutes)} #{formatted_difference_times(diff_worked_minutes)}"
  end

  def report_permit_minutes
    ["#{@permit_type} - #{format_in_hours(@permit_minutes)}",
     "Totale giornaliero: #{format_in_hours(@permit_minutes + worked_minutes)} #{formatted_difference_times(total_diff_minutes)}"] if @permit_type
  end

  def diff_worked_minutes
    worked_minutes - MINUTES_TO_DO
  end

  def total_diff_minutes
    worked_minutes + @permit_minutes - MINUTES_TO_DO
  end

  def ==(other)
    @date == other.instance_eval { @date } && @worked_times == other.instance_eval { @worked_times }
  end
end