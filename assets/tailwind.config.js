// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

let plugin = require('tailwindcss/plugin')

module.exports = {
  darkMode: 'class',
  content: [
    '../lib/**/*.html.eex',
    '../lib/**/*.heex',
  ],
  theme: {
    extend: {},
  },
  safelist: [
    {
      pattern: /.*/,
    }
  ],
  plugins: [
    require('@tailwindcss/typography'),
  ]
}
