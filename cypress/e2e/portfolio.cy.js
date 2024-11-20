describe("API Database Update Test", () => {
  const apiUrl = Cypress.env("API_URL");

  it("should increment the count in the database", () => {
    cy.request('GET', apiUrl).then((response) => {
      const initialCount = response.body.visitorCount;

      // Trigger the visitor count increment
      cy.visit("https://resume.iamatta.com");

      // Wait and verify the database is updated
      cy.request('GET', apiUrl).then((updatedResponse) => {
        const updatedCount = updatedResponse.body.visitorCount;
        expect(updatedCount).to.eq(initialCount + 1);
      });
    });
  });
});


