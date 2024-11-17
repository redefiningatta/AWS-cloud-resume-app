const { defineConfig } = require("cypress");

module.exports = defineConfig({
  e2e: {
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
    // baseUrl: "https://resume.iamatta.com",
    env: {
      API_URL: '{{API_URL}}' // This will be replaced by the shell script
    },
  },
});

