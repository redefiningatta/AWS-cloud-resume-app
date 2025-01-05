describe("API Database Update Test", () => {
  // Define the API URL for the backend
  const apiUrl = Cypress.env("API_URL");

  it("should increment the count in the database and display correct visitor count", () => {
    // Step 1: Get the initial visitor count from the API
    cy.request('GET', apiUrl).then((response) => {
      const initialCount = response.body.visitorCount;
      cy.log(`Initial count: ${initialCount}`);
      
      // Step 2: Visit the webpage to trigger the count increment
      cy.visit("https://www.iamatta.com");

      // Step 3: Wait to ensure the visitor count is incremented (simulate the delay for count update)
      cy.wait(1000); // Adjust wait time if necessary

      // Step 4: Fetch the updated visitor count from the API after visiting the page
      cy.request('GET', apiUrl).then((updatedResponse) => {
        const updatedCount = updatedResponse.body.visitorCount;
        cy.log(`Updated count: ${updatedCount}`);

        // Step 5: Assert that the visitor count increased by 2 after the visit 
        expect(updatedCount).to.eq(initialCount + 2); 

        cy.visit("https://www.iamatta.com");

        // Step 6: Ensure the visitor count element is visible and contains the correct count
        cy.get("#visitor-count")
          .should("be.visible")
          .and("contain.text", `Visitor Number: ${updatedCount + 1}`);
      });
    });
  });
});
