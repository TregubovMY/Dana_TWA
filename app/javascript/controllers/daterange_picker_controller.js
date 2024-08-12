import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="daterange-picker"
export default class extends Controller {
  connect() {
    const ranges = {
      Today: [moment(), moment()],
      Yesterday: [moment().subtract('days', 1), moment().subtract('days', 1)],
      'Last 7 Days': [moment().subtract('days', 6), moment()],
      'Last 30 Days': [moment().subtract('days', 29), moment()],
      'This Month': [moment().startOf('month'), moment().endOf('month')],
      'Last Month': [moment().subtract('month', 1).startOf('month'), moment().subtract('month', 1).endOf('month')],
      'Last 365 Days': [moment().subtract('days', 364), moment()],
    }

    new DateRangePicker(this.element, {
      startDate: moment().startOf('month'),
      endDate: moment().endOf('month'),
      alwaysShowCalendars: true,
      autoApply: true,
      showWeekNumbers: true,
      ranges: ranges
    });
  }
}
