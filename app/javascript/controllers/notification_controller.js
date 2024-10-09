import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("Send Notification Stimulus Controller connected!");
  }

  sendNotification() {
    const selectedCheckboxes = document.querySelectorAll('.user-checkbox:checked');
    const selectedUserIds = Array.from(selectedCheckboxes).map(checkbox => checkbox.dataset.id);

    if (selectedUserIds.length === 0) {
      return;
    }

    const messageTextarea = document.getElementById("message");
    const message = messageTextarea.value.trim();

    if (!message) {
      return;
    }

    fetch("/admins/dashboard/send_notifications", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute("content")
      },
      body: JSON.stringify({ user_ids: selectedUserIds, message: message })
    }).then(response => {
      if (response.ok) {
        messageTextarea.value = '';
        window.location.reload();
      }
    });
  }
}
