@isTest
public class LeadScoringServiceTest {
    
    @isTest
    static void testLeadScoring() {
        // Create test data
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'User',
            Company = 'Test Company',
            LeadSource = 'Web',
            Industry = 'Technology',
            NumberOfEmployees = 200
        );
        
        // Call the scoring service
        Test.startTest();
        List<Lead> leads = new List<Lead>{testLead};
        LeadScoringService.scoreLeads(leads);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(20, testLead.Lead_Source_Score__c, 'Lead source score should be 20 for Web');
        System.assertEquals(45, testLead.Industry_Score__c, 'Industry score should be 45 for Technology');
        System.assertEquals(30, testLead.Company_Size_Score__c, 'Company size score should be 30 for 200 employees');
        System.assertEquals(95, testLead.Lead_Score__c, 'Total lead score should be 95');
        System.assertEquals('A', testLead.Lead_Grade__c, 'Lead grade should be A');
        System.assertNotEquals(null, testLead.Last_Scored_Date__c, 'Last scored date should be set');
    }
    
    @isTest
    static void testLeadScoringWithNullValues() {
        // Create test data with null values
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'User',
            Company = 'Test Company'
        );
        
        // Call the scoring service
        Test.startTest();
        List<Lead> leads = new List<Lead>{testLead};
        LeadScoringService.scoreLeads(leads);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(5, testLead.Lead_Source_Score__c, 'Lead source score should be 5 for null source');
        System.assertEquals(15, testLead.Industry_Score__c, 'Industry score should be 15 for null industry');
        System.assertEquals(5, testLead.Company_Size_Score__c, 'Company size score should be 5 for null employees');
        System.assertEquals(25, testLead.Lead_Score__c, 'Total lead score should be 25');
        System.assertEquals('D', testLead.Lead_Grade__c, 'Lead grade should be D');
    }
}