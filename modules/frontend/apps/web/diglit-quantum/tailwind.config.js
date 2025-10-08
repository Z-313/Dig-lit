/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./app/**/*.{ts,tsx,js,jsx}', './components/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        quantum: {
          cyan: '#00f5ff',
          purple: '#7b2cbf',
          pink: '#ff006e',
          dark: '#0a0e27',
        },
      },
      animation: {
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      },
    },
  },
  plugins: [],
};
