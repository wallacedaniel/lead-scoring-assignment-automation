import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

// Lead fields
import LEAD_SCORE_FIELD from '@salesforce/schema/Lead.Lead_Score__c';
import LEAD_GRADE_FIELD from '@salesforce/schema/Lead.Lead_Grade__c';
import LEAD_SOURCE_FIELD from '@salesforce/schema/Lead.LeadSource';
import LEAD_SOURCE_SCORE_FIELD from '@salesforce/schema/Lead.Lead_Source_Score__c';
import INDUSTRY_FIELD from '@salesforce/schema/Lead.Industry';
import INDUSTRY_SCORE_FIELD from '@salesforce/schema/Lead.Industry_Score__c';
import EMPLOYEES_FIELD from '@salesforce/schema/Lead.NumberOfEmployees';
import COMPANY_SIZE_SCORE_FIELD from '@salesforce/schema/Lead.Company_Size_Score__c';
import ASSIGNED_TO_FIELD from '@salesforce/schema/Lead.Assigned_To__c';
import ASSIGNMENT_STATUS_FIELD from '@salesforce/schema/Lead.Assignment_Status__c';
import LAST_SCORED_DATE_FIELD from '@salesforce/schema/Lead.Last_Scored_Date__c';

// Assigned user fields
import USER_NAME_FIELD from '@salesforce/schema/User.Name';

export default class LeadScoreCard extends LightningElement {
    @api recordId;
    
    @wire(getRecord, { 
        recordId: '$recordId', 
        fields: [
            LEAD_SCORE_FIELD, 
            LEAD_GRADE_FIELD, 
            LEAD_SOURCE_FIELD,
            LEAD_SOURCE_SCORE_FIELD,
            INDUSTRY_FIELD,
            INDUSTRY_SCORE_FIELD,
            EMPLOYEES_FIELD,
            COMPANY_SIZE_SCORE_FIELD,
            ASSIGNED_TO_FIELD,
            ASSIGNMENT_STATUS_FIELD,
            LAST_SCORED_DATE_FIELD
        ]
    })
    leadRecord;
    
    // Wire to get assigned user's name if there is one
    @wire(getRecord, { 
        recordId: '$assignedToId', 
        fields: [USER_NAME_FIELD]
    })
    userRecord;
    
    get lead() {
        return this.leadRecord?.data;
    }
    
    get assignedToId() {
        return this.lead ? getFieldValue(this.lead, ASSIGNED_TO_FIELD) : null;
    }
    
    get assignedUserName() {
        return this.userRecord?.data ? getFieldValue(this.userRecord.data, USER_NAME_FIELD) : 'Loading...';
    }
    
    // Add CSS styling for the component
    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `
            .grade-badge {
                display: inline-block;
                padding: 0.25rem 0.5rem;
                border-radius: 0.25rem;
                font-weight: bold;
            }
            .grade-badge[data-grade="A"] {
                background-color: #4CAF50;
                color: white;
            }
            .grade-badge[data-grade="B"] {
                background-color: #2196F3;
                color: white;
            }
            .grade-badge[data-grade="C"] {
                background-color: #FF9800;
                color: white;
            }
            .grade-badge[data-grade="D"] {
                background-color: #F44336;
                color: white;
            }
            .progress-label {
                display: block;
                margin-bottom: 0.25rem;
                font-size: 0.75rem;
            }
        `;
        this.template.querySelector('lightning-card').appendChild(style);
    }
}