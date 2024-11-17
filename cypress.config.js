const { defineConfig } = require("cypress");

module.exports = defineConfig({
  e2e: {
    setupNodeEvents(on, config) {

      const Url = process.env.API_URL;

      config.env.API_URL = Url;

      return config;

    },
      
    },
  },
);

