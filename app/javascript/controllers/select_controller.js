import { Controller } from "@hotwired/stimulus"
import SlimSelect from "slim-select"

// Connects to data-controller="select"
export default class extends Controller {
  connect() {
    new SlimSelect({
      select: this.element
    })
  }
}
