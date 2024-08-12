class DateFilterService
  def self.prepare_date_filter_params(start_date_between)
    if start_date_between
      starts, ends = start_date_between.split(" - ")
      date_start = Date.strptime(starts, "%m/%d/%Y")
      date_end = Date.strptime(ends, "%m/%d/%Y")
      { date: { date_start:, date_end: } }
    end
  end
end
