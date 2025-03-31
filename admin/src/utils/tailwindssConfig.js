/** @type {import('tailwindcss').Config} */
export default {
    content: [
      "./index.html",
      "./src/**/*.{js,ts,jsx,tsx}",
    ],
    theme: {
      extend: {
        fontFamily: {
          poppins: ['Poppins', 'sans-serif'],
        },
      },
      screens: {
        xsm: "480px",
        sm: "640px",
        md: "768px",
        lg: "1024px",
        xl: "1280px",
        "2xl": "1536px",
      },
      colors: {
        "card-bg": "#ffdabd",
        "card2-bg": "#bbd8fa",
        "input-hover": "#ff6801",
      },
      boxShadow: {
        custom: "2px 2px 8px #e0e0e0 ",
      },
    },
    plugins: [],
  }