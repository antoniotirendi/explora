require_relative '../test_case'

class ExploraTest < Test::Unit::TestCase
  setup do
    permits_lines_are []
    work_times_lines_are []
  end

  def test_dailies_work_from_file
    Explora.any_instance.unstub(:read_times)
    assert_equal 3, Explora.new.business_days.count
  end

  def test_work_permits_from_file
    Explora.any_instance.unstub(:read_workpermits)
    assert_equal 6, Explora.new.business_days.count
  end

  def test_business_days_for_worked_hours
    work_times_lines_are ['MARTEDÌ 03/06/2014	 Aggiungi Timbratura',
                          'Timbrature:	E08:00 U13:00 E14:00 U17:30',
                          'MERCOLEDÌ 04/06/2014	 Aggiungi Timbratura',
                          'Timbrature:	E08:30 U13:01 E13:59 U17:30']
    first_day = BusinessDay.new(Date.parse('03/06/2014'))
    first_day.add_worked_hours(['08:00', '13:00', '14:00', '17:30'])
    second_day = BusinessDay.new(Date.parse('04/06/2014'))
    second_day.add_worked_hours(['08:30', '13:01', '13:59', '17:30'])
    assert_equal [first_day, second_day], Explora.new.business_days
  end

  def test_no_business_day
    work_times_lines_are ['SABATO 21/06/2014	 Aggiungi Timbratura',
                          'Timbrature:	 - ']
    assert_empty Explora.new.business_days
  end

  def test_business_day_not_worked
    work_times_lines_are ['VENERDÌ 20/06/2014	 Aggiungi Timbratura',
                          'Timbrature:	 - ']
    assert_equal [BusinessDay.new(Date.parse('20/06/2014'))],
                 Explora.new.business_days
  end

  def test_holiday_is_not_a_daily_work
    work_times_lines_are ['LUNEDÌ 02/06/2014	 Aggiungi Timbratura',
                          'Timbrature:	 -']
    assert_empty Explora.new.business_days
  end

  def test_business_days_for_partial_permit_hours
    permits_lines_are ['12/06/2014	RIDUZ. ORARIO',
                       '[Durata: 0100] [dal 10/06/2014 al 10/06/2014]',
                       'Approvata e Trasferita']
    day = BusinessDay.new(Date.parse('10/06/2014'))
    day.add_permit_minutes('RIDUZ. ORARIO', 60)
    assert_equal [day], Explora.new.business_days
  end

  def test_business_days_for_full_day_permit_hours
    permits_lines_are ['18/06/2014	FERIE',
                       '[Giornata intera] [dal 13/06/2014 al 17/06/2014]',
                       'Approvata e Trasferita']
    first_day = BusinessDay.new(Date.parse('13/06/2014'))
    second_day = BusinessDay.new(Date.parse('16/06/2014'))
    third_day = BusinessDay.new(Date.parse('17/06/2014'))
    first_day.add_permit_minutes('FERIE', 480)
    second_day.add_permit_minutes('FERIE', 480)
    third_day.add_permit_minutes('FERIE', 480)
    assert_equal [first_day, second_day, third_day], Explora.new.business_days
  end

  def test_business_days_with_work_and_permit
    work_times_lines_are ['MARTEDÌ 10/06/2014	 Aggiungi Timbratura',
                          'Timbrature:	E08:30 U13:00']
    permits_lines_are ['12/06/2014	RIDUZ. ORARIO',
                       '[Durata: 0330] [dal 10/06/2014 al 10/06/2014]',
                       'Approvata e Trasferita']
    day = BusinessDay.new(Date.parse('10/06/2014'))
    day.add_worked_hours(['08:30', '13:00'])
    day.add_permit_minutes('RIDUZ. ORARIO', 210)
    assert_equal [day], Explora.new.business_days
  end

  def test_business_day_transfer
    permits_lines_are ['07/07/2014	TRASFERTA',
                       '[Giornata intera] [dal 04/07/2014 al 04/07/2014]',
                       'In Attesa']
    day = BusinessDay.new(Date.parse('04/07/2014'))
    day.add_permit_minutes('TRASFERTA', 480)
    assert_equal [day], Explora.new.business_days
  end

  def test_overall_report_one_day
    work_times_lines_are ['MARTEDÌ 03/06/2014	 Aggiungi Timbratura',
                          'Timbrature:	E08:30 U13:00 E14:00 U17:30']
    assert_equal ['-------------------------------------------------------------------------',
                  'TUESDAY 03/06/2014 ore lavorate: 08h 00m ==',
                  '=========================================================================',
                  '1 Giorno lavorativo, ore lavorate: 08h 00m, permessi: -, ==',
                  '========================================================================='], Explora.new.overall_report
  end

  def test_overall_report_more_days
    work_times_lines_are ['MARTEDÌ 03/06/2014	 Aggiungi Timbratura',
                          'Timbrature:	E08:30 U13:00 E14:00 U17:30',
                          'MERCOLEDÌ 04/06/2014	 Aggiungi Timbratura',
                          'Timbrature:	E08:30 U13:01 E13:59 U17:30']
    assert_equal ['-------------------------------------------------------------------------',
                  'TUESDAY 03/06/2014 ore lavorate: 08h 00m ==',
                  '-------------------------------------------------------------------------',
                  'WEDNESDAY 04/06/2014 ore lavorate: 08h 02m +00h 02m',
                  '=========================================================================',
                  '2 Giorni lavorativi, ore lavorate: 16h 02m, permessi: -, +00h 02m',
                  '========================================================================='], Explora.new.overall_report
  end

  def test_overall_report_business_day_not_worked_without_permit
    work_times_lines_are ['MARTEDÌ 03/06/2014	 Aggiungi Timbratura',
                          'Timbrature:	 - ',]
    assert_equal ['-------------------------------------------------------------------------',
                  'TUESDAY 03/06/2014 ore lavorate: - -08h 00m',
                  '=========================================================================',
                  '1 Giorno lavorativo, ore lavorate: -, permessi: -, -08h 00m',
                  '========================================================================='], Explora.new.overall_report
  end

  def test_overall_report_with_permit_full_day
    work_times_lines_are ['MARTEDÌ 03/06/2014	 Aggiungi Timbratura',
                          'Timbrature:	 - ']
    permits_lines_are ['10/06/2014	FERIE',
                       '[Giornata intera] [dal 03/06/2014 al 03/06/2014]',
                       'Approvata e Trasferita']
    assert_equal ['-------------------------------------------------------------------------',
                  'TUESDAY 03/06/2014 ore lavorate: - -08h 00m',
                  'FERIE - 08h 00m',
                  'Totale giornaliero: 08h 00m ==',
                  '=========================================================================',
                  '1 Giorno lavorativo, ore lavorate: -, permessi: 08h 00m, ==',
                  '========================================================================='], Explora.new.overall_report
  end

  def test_print
    Explora.any_instance.unstub(:read_times)
    Explora.any_instance.unstub(:read_workpermits)
    Explora.new.print_overall_report
  end

  def work_times_lines_are(times_lines)
    Explora.any_instance.stubs(:read_times).returns(times_lines)
  end

  def permits_lines_are(permits_lines)
    Explora.any_instance.stubs(:read_workpermits).returns(permits_lines)
  end
end