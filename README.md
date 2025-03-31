# Lead Scoring and Assignment Automation

## Overview
This Salesforce application automates the process of scoring and assigning leads based on customizable criteria. It helps sales teams prioritize high-value prospects, ensures fair distribution of leads among representatives, and increases overall efficiency by eliminating manual lead assignment steps.

## Features
- **Automated Lead Scoring**: Score incoming leads based on multiple criteria including lead source, industry, and company size
- **Intelligent Lead Assignment**: Assign leads to appropriate sales representatives based on their specialty, capacity, and current workload
- **Notification System**: Create automatic task notifications for newly assigned leads
- **Approval Workflows**: High-value leads are automatically submitted for approval to ensure proper handling
- **Visual Dashboard**: Monitor lead scores, assignment status, and performance metrics through custom Lightning components
- **Customizable Rules**: Easily modify scoring rules and assignment logic to adapt to changing business needs

## Components

### Custom Fields
The application adds the following custom fields to the Lead object:
- `Lead_Score__c` (Number): The total score calculated for the lead
- `Lead_Grade__c` (Picklist: A, B, C, D): Grade assigned based on score thresholds
- `Lead_Source_Score__c` (Number): Score component based on lead source
- `Company_Size_Score__c` (Number): Score component based on company size
- `Industry_Score__c` (Number): Score component based on industry
- `Last_Scored_Date__c` (Date/Time): When the lead was last scored
- `Assigned_To__c` (Lookup to User): The sales rep assigned to the lead
- `Assignment_Status__c` (Picklist): Current assignment status (New, Assigned, In Progress, etc.)

### Apex Classes
- **LeadScoringService**: Calculates lead scores based on source, industry, and company size
- **LeadAssignmentService**: Assigns leads to sales reps based on capacity and specialty
- **Test Classes**: Comprehensive test coverage for all Apex code

### Lightning Components
- **leadScoreCard**: Displays lead scoring information and assignment details on the lead record page

### Process Automation
- **LeadScoringTrigger**: Trigger to initiate scoring and assignment processes
- **Lead_Assignment_Approval**: Approval process for high-value leads
- **Lead_Scoring_Assignment_Flow**: Flow to manually trigger scoring and assignment

## Technical Architecture
The application follows a service-oriented architecture with clear separation of concerns:

1. **Trigger Layer**: Handles event detection and delegates to service classes
2. **Service Layer**: Contains business logic for scoring and assignment
3. **User Interface Layer**: Displays information and allows interaction through Lightning components
4. **Automation Layer**: Manages approval processes and notifications

## Installation

### Prerequisites
- Salesforce organization with API access
- System Administrator profile or sufficient permissions to create custom fields, Apex classes, and Lightning components
- "Sales User" profile must exist or be created in the org

### Deployment Options

#### Option 1: Deploy with SFDX
1. Clone this repository
2. Authenticate with your Salesforce org:
   ```bash
   sfdx auth:web:login -a YourOrgAlias
   ```
3. Deploy the components:
   ```bash
   sfdx force:source:deploy -p force-app -u YourOrgAlias
   ```

#### Option 2: Deploy with Metadata API
1. Use Salesforce Workbench or similar tool
2. Navigate to Migration > Deploy
3. Select the `package.xml` file and the components directory
4. Deploy to your org

#### Option 3: Manual Setup
Follow these steps if you prefer to configure the system manually:

1. Create the custom fields on the Lead object as described in the "Custom Fields" section
2. Create the Apex classes: LeadScoringService, LeadAssignmentService, and the Trigger
3. Create the approval process for high-value leads
4. Create the Lightning component and add it to the Lead record page
5. Create the custom list views and reports
6. Set up permissions

### Post-Installation Steps
1. Add the `Industry_Specialty__c` field to the User object if it doesn't exist
2. Set up industry specialties for your sales users
3. Add the Lead Score Card component to your Lead page layouts
4. Create the permission set and assign it to users
5. Create the custom list view for high-value leads
6. Set up and share the Lead Scoring Dashboard

## Configuration

### Modifying Scoring Rules
To modify the lead scoring rules, update the following methods in the `LeadScoringService` class:
- `calculateSourceScore`: Adjust scores for different lead sources
- `calculateIndustryScore`: Adjust scores for different industries
- `calculateCompanySizeScore`: Adjust scores based on company size thresholds
- `calculateGrade`: Adjust the thresholds for each grade level

### Adjusting Assignment Logic
To modify the lead assignment logic, update the following methods in the `LeadAssignmentService` class:
- `findBestRep`: Adjust the algorithm for finding the best sales rep
- `getRepCapacity`: Modify how capacity is calculated for each rep

## Usage Guide

### For Sales Representatives
- View lead scores and grades on the Lead Score Card
- Check assignment notifications in your task list
- Update the assignment status as you work on leads

### For Sales Managers
- Use the Lead Scoring Dashboard to monitor lead quality and assignment metrics
- Review and approve high-value leads through the approval process
- Analyze lead scoring components to identify trends and opportunities

### For Administrators
- Adjust scoring rules as business priorities change
- Monitor system performance and assignment effectiveness
- Provide training and support to users

## Troubleshooting
- **Lead not being scored**: Verify that essential fields (LeadSource, Industry, NumberOfEmployees) are populated
- **Lead not being assigned**: Check available capacity of sales reps and ensure specialty fields are properly set
- **Approval process not triggering**: Verify that leads have a grade of "A" and that the approval process is active

## Additional Resources
- [Apex Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/)
- [Lightning Web Components Developer Guide](https://developer.salesforce.com/docs/component-library/documentation/lwc)
- [Salesforce Flow Designer Guide](https://help.salesforce.com/articleView?id=flow.htm)

## License
This project is licensed under the MIT License - see the LICENSE.md file for details

## Contributors
- Your Name/Company
- Additional contributors

## Version History
- 1.0.0: Initial release with core scoring and assignment functionality
- 1.1.0: Added Lightning component visualization
- 1.2.0: Enhanced assignment algorithm with specialty matching