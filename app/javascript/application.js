// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// import "@hotwired/turbo-rails"
import "controllers"
import 'flowbite';

document.addEventListener("DOMContentLoaded", setupPasswordToggles);
function setupPasswordToggles() {
  const passwordFields = document.querySelectorAll(".password-field");
  const toggleButtons = document.querySelectorAll(".toggle-password");

  toggleButtons.forEach((toggleButton, index) => {
    toggleButton.addEventListener("click", function () {
      const passwordField = passwordFields[index];
      if (passwordField.type === "password") {
        passwordField.type = "text";
        toggleButton.src = "/assets/svg/password-show.svg";
      } else {
        passwordField.type = "password";
        toggleButton.src = "/assets/svg/Eye-icon.svg";
      }
    });
  });
}
