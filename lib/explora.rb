class Explora
  include FormatTime

  def initialize
    @lines=File.readlines(File.join(File.dirname(__FILE__), '..', 'local_data', 'times.txt'))
    @dailies_work = dailies_work
  end

  def dailies_work
    days = []
    @lines.each_slice(2) do |first_line, second_line|
      day_info = first_line.split("\t")[0]
      worked_times=second_line.split(/\t/)[1].split('E')
      worked_times.shift
      if worked_times.any?
        times = worked_times.map { |worked_time| worked_time.strip.split(' U') }.flatten
        days << DailyWork.new(day_info, times)
      end
    end
    days
  end

  def total_worked_hours
    daily_minutes = 0
    @dailies_work.each do |daily_work|
      daily_minutes += daily_work.worked_minutes
    end
    format_in_hours(daily_minutes)
  end

  def overall_report
    infos = []
    @dailies_work.each do |daily_work|
      infos << daily_work.report
    end
    infos << total_report
  end

  def formatted_total_diff_minutes
    total_diff_minutes = 0
    @dailies_work.each do |daily_work|
      total_diff_minutes += daily_work.diff_minutes
    end
    formatted_difference_times(total_diff_minutes)
  end

  def total_report
    "#{worked_days} - #{total_worked_hours} #{formatted_total_diff_minutes}"
  end

  def worked_days
    label = @dailies_work.count == 1 ? 'Giorno lavorativo' : 'Giorni lavorativi'
    "#{@dailies_work.count} #{label}"
  end

  def print_overall_report
    overall_report.each { |line| p line }
  end
end