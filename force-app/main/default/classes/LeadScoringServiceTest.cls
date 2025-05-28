@isTest
public class LeadAssignmentServiceTest {
    
    @isTest
    static void testLeadAssignment() {
        // Create test users
        Profile salesProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User testUser1 = new User(
            FirstName = 'Test',
            LastName = 'User1',
            Email = 'testuser1@example.com',
            Username = 'testuser1@example.com' + System.currentTimeMillis(),
            Alias = 'tuser1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = salesProfile.Id,
            Industry_Specialty__c = 'Technology'
        );
        
        User testUser2 = new User(
            FirstName = 'Test',
            LastName = 'User2',
            Email = 'testuser2@example.com',
            Username = 'testuser2@example.com' + System.currentTimeMillis(),
            Alias = 'tuser2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = salesProfile.Id,
            Industry_Specialty__c = 'Financial Services'
        );
        
        // Insert test users
        List<User> testUsers = new List<User>{testUser1, testUser2};
        insert testUsers;
        
        // Create test leads with scores
        Lead techLead = new Lead(
            FirstName = 'Tech',
            LastName = 'Lead',
            Company = 'Tech Company',
            Industry = 'Technology',
            LeadSource = 'Web',
            NumberOfEmployees = 1000
        );
        
        Lead financeLead = new Lead(
            FirstName = 'Finance',
            LastName = 'Lead',
            Company = 'Finance Company',
            Industry = 'Financial Services',
            LeadSource = 'Web',
            NumberOfEmployees = 1000
        );
        
        // Calculate scores
        LeadScoringService.scoreLeads(new List<Lead>{techLead, financeLead});
        
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