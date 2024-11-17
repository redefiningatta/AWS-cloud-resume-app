describe("Visitor Counter Test with Actual Backend", () => {
  const apiUrl = Cypress.env("API_URL"); // Use Cypress environment variables to access your API URL

  it("should fetch and display the updated visitor count from DynamoDB", () => {
    // Check if the API URL is set correctly
    expect(apiUrl).to.be.a("string").and.not.be.empty;

    // Visit the webpage causing the page to increment
    cy.visit("https://resume.iamatta.com");

    // Fetch the visitor count from the actual backend API
    cy.request('GET', apiUrl).then((response) => {
      let initialCount = response.body.visitorCount;

      // Wait for 1 second to allow backend update (to simulate the increment delay)
      cy.wait(1000);

      // Retry mechanism to fetch updated count
      function checkUpdatedCount(retries = 5) {
        cy.request('GET', apiUrl).then((updatedResponse) => {
          let updatedCount = updatedResponse.body.visitorCount;

          // Check if the updated count is correct
          if (updatedCount === initialCount + 1) {
            // Assert that the visitor count has incremented by 1
            expect(updatedCount).to.eq(initialCount + 1);

            // Ensure the visitor count element is visible and contains the correct updated count
            cy.get("#visitor-count")
              .should("be.visible")
              .and("contain.text", `Visitor Number: ${updatedCount}`);
          } else if (retries > 0) {
            // Retry if the count hasn't updated yet
            cy.wait(1000); // wait 1 second before retrying
            checkUpdatedCount(retries - 1);
          } else {
            // Fail the test if the count doesn't update in the retries
            throw new Error('Visitor count update failed after retries');
          }
        });
      }

      // Start the retry mechanism
      checkUpdatedCount();
    });
  });
});
