import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["start", "end"];

  connect() {
    console.log("DateRange Stimulus Controller connected!");
  }

  update() {
    console.log("Update triggered!");
    const startDate = this.startTarget.value;
    const endDate = this.endTarget.value;
    const baseUrl = this.element.dataset.url;

    if (startDate && endDate) {
      const url = `${baseUrl}?start=${startDate}&end=${endDate}`;
      window.location.href = url;
    }
  }
}
