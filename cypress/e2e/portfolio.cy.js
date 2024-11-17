function checkUpdatedCount(expectedCount, apiUrl, retries = 10) {
  cy.log(`Checking updated count, expected: ${expectedCount}`);
  
  // Retry mechanism to check if the frontend has updated its count
  cy.get("#visitor-count", { timeout: 10000 }) // Wait up to 10 seconds
    .should("be.visible")
    .invoke("text")
    .then((text) => {
      const displayedCount = parseInt(text.replace('Visitor Number: ', ''), 10);
      cy.log(`Displayed count: ${displayedCount}, Expected count: ${expectedCount}`);
      
      if (displayedCount !== expectedCount && retries > 0) {
        // Wait for 1 second and retry
        cy.wait(1000);
        checkUpdatedCount(expectedCount, apiUrl, retries - 1);
      } else {
        expect(displayedCount).to.eq(expectedCount);
      }
    });
}

describe("Visitor Counter Test with Actual Backend", () => {
  const apiUrl = Cypress.env("API_URL"); // Use Cypress environment variables to access your API URL

  it("should fetch and display the updated visitor count from DynamoDB", () => {
    expect(apiUrl).to.be.a("string").and.not.be.empty;

    // Visit the webpage causing the page to increment the count
    cy.visit("https://resume.iamatta.com");

    // Fetch the initial visitor count from the actual backend API
    cy.request('GET', apiUrl).then((response) => {
      const initialCount = response.body.visitorCount;
      cy.log(`Initial backend count: ${initialCount}`);
      
      // Allow some time for the backend update to propagate
      cy.wait(2000); 

      // Check the updated count on the frontend
      checkUpdatedCount(initialCount, apiUrl);
    });
  });
});
