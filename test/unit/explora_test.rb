require_relative '../test_case'

class ExploraTest < Test::Unit::TestCase
  def test_worked_hours_more_days
    File.stubs(:readlines).returns(['MARTEDÌ 03/06/2014	 Aggiungi Timbratura',
                                    'Timbrature:	E08:00 U13:00 E14:00 U17:30',
                                    'MERCOLEDÌ 04/06/2014	 Aggiungi Timbratura',
                                    'Timbrature:	E08:30 U13:01 E13:59 U17:30',
                                    'GIOVEDÌ 05/06/2014	 Aggiungi Timbratura',
                                    'Timbrature:	E08:00 U13:00 E14:00 U17:30'])
    assert_equal '25h 02m', Explora.new.total_worked_hours
  end

  def test_worked_hours_from_file
    assert_equal '24h 29m', Explora.new.total_worked_hours
  end

  def test_dailies_work
    File.stubs(:readlines).returns(['MARTEDÌ 03/06/2014	 Aggiungi Timbratura',
                                    'Timbrature:	E08:00 U13:00 E14:00 U17:30',
                                    'MERCOLEDÌ 04/06/2014	 Aggiungi Timbratura',
                                    'Timbrature:	E08:30 U13:01 E13:59 U17:30'])
    assert_equal [DailyWork.new('MARTEDÌ 03/06/2014', ['08:00', '13:00', '14:00', '17:30']),
                  DailyWork.new('MERCOLEDÌ 04/06/2014', ['08:30', '13:01', '13:59', '17:30'])],
                 Explora.new.dailies_work
  end

  def test_no_daily_work
    File.stubs(:readlines).returns(['SABATO 21/06/2014	 Aggiungi Timbratura',
                                    'Timbrature:	 - '])
    assert_empty Explora.new.dailies_work
  end

  def test_overall_report_one_day
    File.stubs(:readlines).returns(['MARTEDÌ 03/06/2014	 Aggiungi Timbratura',
                                    'Timbrature:	E08:30 U13:00 E14:00 U17:30'])
    assert_equal ['MARTEDÌ 03/06/2014 - 08h 00m ==',
                  '1 Giorno lavorativo - 08h 00m =='], Explora.new.overall_report
  end

  def test_overall_report_more_days
    File.stubs(:readlines).returns(['MARTEDÌ 03/06/2014	 Aggiungi Timbratura',
                                    'Timbrature:	E08:30 U13:00 E14:00 U17:30',
                                    'MERCOLEDÌ 04/06/2014	 Aggiungi Timbratura',
                                    'Timbrature:	E08:30 U13:01 E13:59 U17:30'])
    assert_equal ['MARTEDÌ 03/06/2014 - 08h 00m ==',
                  'MERCOLEDÌ 04/06/2014 - 08h 02m +00h 02m',
                  '2 Giorni lavorativi - 16h 02m +00h 02m'], Explora.new.overall_report
  end

  def test_print
    Explora.new.print_overall_report
  end
end