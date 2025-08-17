# AWS Cloud Resume Challenge
This repository contains my implementation of the AWS Cloud Resume Challenge, where I built a serverless resume website hosted on AWS. The project showcases my skills in cloud computing, web development, and infrastructure as code (IaC) using Terraform.

## Table of Contents
1. Technologies Used
2. Project Features
3. Architecture
4. Usage
5. Deployment
6. CI/CD Pipeline
7. Testing
8. Challenges Faced
9. Conclusion


## Technologies Used
- **Frontend:** HTML, CSS
- **Backend:** AWS Lambda (Python)
- **Database:** Amazon DynamoDB
- **Infrastructure as Code:** Terraform
- **Hosting:** Amazon S3, Amazon CloudFront
- **CI/CD:** GitHub Actions


## Project Features
- A static resume website hosted on AWS S3.
- A visitor counter that tracks the number of views using AWS Lambda and DynamoDB.
- Secure HTTPS connection using AWS Certificate Manager and CloudFront.


## Architecture
Below is an architecture diagram illustrating the flow of data and the components used (to be updated). 

![Architecture Diagram](/resume-website/images/architecture.drawio.png)



## Usage
Visit my live resume website [here](https://www.michellenkomo.co.za).

The visitor counter will update automatically every time someone visits the site! :)


## Deployment
The project is set up with a CI/CD pipeline using GitHub Actions. Changes pushed to the main branch will automatically deploy updates to the AWS infrastructure and frontend.


## CI/CD Pipeline
The CI/CD pipeline is defined in the .github/workflows directory and includes workflows for both the frontend and backend.


### Frontend Pipeline
Deploys the static website to S3.


### Backend Pipeline
Deploys the Lambda functions and updates the DynamoDB table.


## Testing
The backend Lambda functions are tested using pytest.


## Challenges Faced
Throughout the challenge, I encountered several obstacles:

**IAM Permissions:** Misconfigurations led to failed Lambda executions. I learned the importance of setting up correct IAM roles and policies.

**Terraform Conflicts:** I faced issues with resource conflicts due to existing AWS resources. Learning how to use data sources in Terraform was key to overcoming these challenges.


## Conclusion
The AWS Cloud Resume Challenge was an invaluable experience that enhanced my understanding of cloud architecture, serverless solutions, and CI/CD practices. I encourage others to take on this challenge to gain practical experience and showcase their skills.


## Acknowledgments
Forrest Brazeal

AWS documentation
