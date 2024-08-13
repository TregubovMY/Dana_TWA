import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="user-payments"
export default class extends Controller {
  static targets = ["dateField"];

  connect() {
    console.log(this.dateFieldTarget);
  }
  submitWithDate(event) {
    event.preventDefault();

    const url = event.target.href;
    const date = this.dateFieldTarget.value;
    const token = document.querySelector('meta[name="csrf-token"]').content;

    fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token,
      },
      body: JSON.stringify({ start_date_between: date }),
    })
    .then(response => response.text())
    .then(html => {
      // Замена текущей страницы на полученный HTML
      document.body.innerHTML = html;
    })
    .catch((error) => {
      console.error("Error:", error);
    });
  }
}
