describe("Visitor Counter Test with Actual Backend", () => {
  const apiUrl = Cypress.env("API_URL"); // Use Cypress environment variables to access your API URL

  it("should fetch and display the updated visitor count from DynamoDB", () => {
    // Check if the API URL is set correctly
    expect(apiUrl).to.be.a("string").and.not.be.empty;

    // Visit the webpage causing the page to increment
    cy.visit("https://resume.iamatta.com");

    // Fetch the visitor count from the actual backend API
    cy.request(apiUrl).then((response) => {
      // Check the response status
      expect(response.status).to.eq(200);

      // Verify the response body structure and visitor count
      expect(response.body).to.have.property("visitorCount");
      const visitorCount = response.body.visitorCount;

      // Ensure the visitor count element is visible and contains the correct count
      cy.get("#visitor-count")
        .should("be.visible")
        .and("contain.text", `Visitor Number: ${visitorCount}`);
    });
  });
});
