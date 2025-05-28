@isTest
private class LeadAssignmentServiceTest {
    
    @isTest
    static void testLeadAssignment() {
        // Create test lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Industry = 'Technology',
            LeadSource = 'Web',
            NumberOfEmployees = 1000
        );
        
        // Create test users
        User techRep = new User(
            FirstName = 'Tech',
            LastName = 'Rep',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales User'].Id,
            Username = 'techrep@test.com',
            Email = 'techrep@test.com',
            Alias = 'techrep',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        
        User financeRep = new User(
            FirstName = 'Finance',
            LastName = 'Rep',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales User'].Id,
            Username = 'financerep@test.com',
            Email = 'financerep@test.com',
            Alias = 'financerep',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
            Company = 'Finance Company',
            Industry = 'Financial Services',
            Lead_Score__c = 85,
            Lead_Grade__c = 'A'
        );
        
        // Insert test leads
        List<Lead> testLeads = new List<Lead>{techLead, financeLead};
        insert testLeads;
        
        // Run as test users for proper assignment
        System.runAs(testUser1) {
            // Call the assignment service
            Test.startTest();
            LeadAssignmentService.assignLeads(testLeads);
            Test.stopTest();
            
            // Query the leads to verify assignment
            List<Lead> updatedLeads = [SELECT Id, Assigned_To__c, Assignment_Status__c FROM Lead WHERE Id IN :testLeads];
            
            // Verify assignments
            for(Lead l : updatedLeads) {
                System.assertNotEquals(null, l.Assigned_To__c, 'Lead should be assigned');
                System.assertEquals('Assigned', l.Assignment_Status__c, 'Assignment status should be set');
            }
            
            // Verify tasks were created
            List<Task> notifications = [SELECT Id, Subject, WhoId, OwnerId FROM Task WHERE WhoId IN :testLeads];
            System.assertEquals(2, notifications.size(), 'Notification tasks should be created for each lead');
        }
    }
}