class DailyWork
  include FormatTime
  MINUTES_TO_DO=480

  def initialize(date, times)
    @date, @times = date, times
  end

  def worked_minutes
    total_minutes = 0
    times_in_out = @times.each_slice(2).to_a
    times_in_out.each do |time_in, time_out|
      worked_seconds = Time.parse(time_out) - Time.parse(time_in)
      total_minutes += worked_seconds.to_i/60
    end
    total_minutes
  end

  def diff_minutes
    worked_minutes - MINUTES_TO_DO
  end

  def report
    "#{@date} - #{format_in_hours(worked_minutes)} #{formatted_difference_times(diff_minutes)}"
  end

  def ==(other)
    @date == other.instance_eval { @date } && @times == other.instance_eval { @times }
  end
end