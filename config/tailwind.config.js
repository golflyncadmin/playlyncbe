const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
  ],
  theme: {
    extend: {
      colors: {
        primary: "#0980D0",
        secondary: "#9597A7",
        "sky-blue": "#E8F6FF",
        "dark-blue": "#0967A6",
        typo: "#0D0423",
        gray: {
          DEFAULT: "#626262",
          2: "#DADADA",
          3: "#F6F6F6",
          4: "#898989",
          5: "#EFEFEF",
        },
      },
      boxShadow: {
        btn: "0px 0px 12px 0px rgba(0, 0, 0, 0.12)",
      },
      fontFamily: {
        sans: ["Poppins", ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [require("flowbite/plugin"), require("tailwindcss")],
};
