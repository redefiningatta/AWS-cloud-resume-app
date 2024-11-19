function waitForUpdatedFrontendCount(expectedCount, retries = 10) {
  cy.log(`Checking if the frontend displays the expected count: ${expectedCount}`);
  
  cy.get("#visitor-count", { timeout: 10000 }) // Wait up to 10 seconds for the count to appear
    .should("be.visible")
    .invoke("text")
    .then((text) => {
      const displayedCount = parseInt(text.replace('Visitor Number: ', ''), 10);
      cy.log(`Displayed count: ${displayedCount}, Expected count: ${expectedCount}`);
      
      if (displayedCount !== expectedCount && retries > 0) {
        // Wait and retry if the count isn't updated yet
        cy.wait(2000);
        waitForUpdatedFrontendCount(expectedCount, retries - 1);
      } else {
        expect(displayedCount).to.eq(expectedCount);
      }
    });
}

describe("Visitor Counter Test with Actual Backend", () => {
  const apiUrl = Cypress.env("API_URL"); // Use Cypress environment variables to access your API URL

  it("should fetch and display the updated visitor count from DynamoDB", () => {
    expect(apiUrl).to.be.a("string").and.not.be.empty;

    // Visit the webpage, which should increment the visitor count
    cy.visit("https://resume.iamatta.com");

    // Fetch the current visitor count from the backend API
    cy.request('GET', apiUrl).then((response) => {
      const initialCount = response.body.visitorCount;
      const expectedCount = initialCount + 1; // Backend increments immediately after visit
      
      cy.log(`Initial backend count: ${initialCount}, Expected count: ${expectedCount}`);
      
      // Wait briefly to allow the backend to process the increment
      cy.wait(2000);

      // Verify that the frontend matches the expected count
      waitForUpdatedFrontendCount(expectedCount);
    });
  });
});

