import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal"];

  connect() {
    console.log("Delete User Stimulus Controller connected!");
  }

  deleteSelectedUsers() {
    const selectedUserIds = JSON.parse(this.element.dataset.selectedUserIds);

    fetch("/admins/dashboard/delete_users", {
      method: "DELETE",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute("content")
      },
      body: JSON.stringify({ user_ids: selectedUserIds })
    }).then(response => {
      if (response.ok) {
        window.location.reload();
      }
    });
  }
}

