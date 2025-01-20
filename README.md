# Cloud Resume Challenge

## Overview
The Cloud Resume Challenge (CRC) was a crucial part of my mentorship program at my current company, where I was mentored to develop my DevOps skills. This hands-on project helped me apply cloud computing concepts, automation, and infrastructure as code while receiving guidance from experienced professionals.

## Mentorship & Learning Experience
As part of the mentorship program, I worked on CRC to:
- Gain practical experience in deploying cloud-based applications.
- Understand best practices for Infrastructure as Code (IaC).
- Learn how to automate deployments using CI/CD pipelines.
- Troubleshoot real-world cloud infrastructure issues with the help of my mentor.

This project served as an excellent learning opportunity, bridging the gap between theoretical knowledge and real-world cloud deployments.

## Architecture
My project consists of the following components:

1. **Frontend** - A static resume website built with HTML, CSS, and JavaScript.
2. **Hosting** - Hosted on AWS S3 with static website hosting enabled.
3. **CDN** - Amazon CloudFront is used for content delivery with Origin Access Control (OAC) to securely access S3.
4. **Domain & SSL** - Cloudflare is used for domain registration and DNS management, with AWS Certificate Manager for SSL/TLS.
5. **Backend (API)** - AWS Lambda (written in Python) with API Gateway to serve dynamic content (e.g., visitor counter).
6. **Database** - AWS DynamoDB to store visitor counts.
7. **Infrastructure as Code (IaC)** - AWS CloudFormation was used to automate deployment.
8. **CI/CD Pipeline** - GitHub Actions with OIDC for automated deployment.
9. **End-to-End Testing** - Cypress was used for automated end-to-end testing.
10. **Deployment Automation** - Bash scripting was used for deployment automation.
11. **Monitoring & Logging** - AWS CloudWatch for logs and monitoring.

## Prerequisites
To complete this challenge, I needed:
- An AWS account
- Basic knowledge of HTML, CSS, JavaScript
- Familiarity with AWS services (S3, CloudFront, Lambda, API Gateway, DynamoDB, IAM, Cloudflare)
- Experience with Git and GitHub Actions (or similar CI/CD tools)
- Understanding of Infrastructure as Code (CloudFormation)
- Knowledge of Cypress for end-to-end testing
- Experience with Bash scripting for automation

## Steps to Deploy

1. **Create and Host the Frontend**
   - Built my resume in HTML, CSS, and JavaScript.
   - Uploaded the static website to an S3 bucket.
   - Configured S3 bucket policies for private access with OAC.

2. **Set Up CDN (CloudFront with OAC)**
   - Created a CloudFront distribution.
   - Configured Origin Access Control (OAC) to securely retrieve content from S3.

3. **Secure the Website**
   - Used AWS Certificate Manager (ACM) for an SSL certificate.
   - Updated CloudFront settings to enforce HTTPS.

4. **Setup a Custom Domain**
   - Registered a domain with Cloudflare.
   - Configured DNS records in Cloudflare to point to CloudFront.

5. **Implement Backend (Visitor Counter API)**
   - Developed an AWS Lambda function using Python.
   - Exposed it via API Gateway.
   - Stored visitor counts in DynamoDB.

6. **Infrastructure as Code (IaC)**
   - Automated the deployment using CloudFormation.

7. **Setup CI/CD**
   - Used GitHub Actions with OIDC for automated deployment.

8. **Implement End-to-End Testing**
   - Used Cypress to create and execute automated tests to validate frontend and backend functionality.

9. **Automate Deployment with Bash Scripts**
   - Wrote Bash scripts to streamline and automate deployment tasks.
   - Integrated scripts into CI/CD pipeline for efficiency.

## Challenges & Lessons Learned
- **CORS Issues**: One of the biggest challenges I faced was dealing with CORS restrictions when fetching data from the visitor counter API. With the help of my mentor, I learned how to properly configure API Gateway and include appropriate CORS headers to resolve this.
- **Visitor Counter Not Updating**: Initially, the visitor counter wasn’t displaying correctly on the frontend. Debugging showed issues with API Gateway responses and misconfigured IAM permissions for Lambda to access DynamoDB. My mentor guided me through troubleshooting steps to resolve the problem.
- **Configuring CloudFront with OAC**: Setting up OAC to restrict direct S3 access and route traffic securely through CloudFront required adjustments in bucket policies.
- **Using Cloudflare for DNS Management**: Learning how to properly configure Cloudflare’s DNS settings and integrate it with AWS services was a valuable experience.
- **Writing Python Code for Lambda**: Implementing the backend logic in Python for the Lambda function reinforced my understanding of AWS Lambda and API Gateway integrations.
- **Understanding IAM roles and permissions**: Setting up IAM roles correctly was crucial to ensure the Lambda function had the right permissions to interact with DynamoDB.
- **Configuring API Gateway properly with Lambda**: I had to fine-tune the integration between API Gateway and Lambda to ensure seamless communication.
- **Automating infrastructure setup with CloudFormation**: Writing CloudFormation templates required a learning curve, but it significantly improved deployment efficiency and taught me the importance of automation.
- **Implementing CI/CD for seamless updates**: Automating deployment with GitHub Actions and OIDC helped me understand how CI/CD pipelines streamline cloud operations.
- **Automated Testing with Cypress**: Implementing Cypress for end-to-end testing helped catch issues early and improved application reliability.
- **Deployment Automation with Bash Scripting**: Writing Bash scripts to automate deployment tasks made the CI/CD pipeline more efficient and reduced manual effort.

## Resources
- [Cloud Resume Challenge](https://cloudresumechallenge.dev/)
- [AWS Documentation](https://docs.aws.amazon.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [CloudFormation Documentation](https://docs.aws.amazon.com/cloudformation/)
- [Cloudflare Documentation](https://developers.cloudflare.com/)
- [Cypress Documentation](https://docs.cypress.io/)

## Conclusion
This project, completed as part of my mentorship program, was an excellent way to develop my DevOps skills. Working under the guidance of my mentor, I gained hands-on experience in cloud architecture, automation, and deployment. The CRC challenge played a key role in my professional growth and strengthened my confidence in working with cloud technologies.

---

### Author
*Atta*

