function checkUpdatedCount(expectedCount, apiUrl, retries = 5) {
  cy.request('GET', apiUrl).then((response) => {
    const currentCount = response.body.visitorCount;
    cy.log(`Current count: ${currentCount}, Expected count: ${expectedCount}`);
    
    if (currentCount === expectedCount) {
      cy.get("#visitor-count")
        .should("be.visible")
        .and("contain.text", `Visitor Number: ${expectedCount}`);
    } else if (retries > 0) {
      cy.wait(1000);
      checkUpdatedCount(expectedCount, retries - 1);
    } else {
      throw new Error("Visitor count mismatch after retries");
    }
  });
}

describe("Visitor Counter Test with Actual Backend", () => {
  const apiUrl = Cypress.env("API_URL");

  it("should fetch and display the updated visitor count from DynamoDB", () => {
    expect(apiUrl).to.be.a("string").and.not.be.empty;

    cy.visit("https://resume.iamatta.com");

    cy.request('GET', apiUrl).then((response) => {
      const initialCount = response.body.visitorCount;
      cy.wait(1000); // Wait for the increment
      checkUpdatedCount(initialCount + 1, apiUrl);
    });
  });
});
