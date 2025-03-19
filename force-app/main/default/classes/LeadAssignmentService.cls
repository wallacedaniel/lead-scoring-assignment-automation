public class LeadAssignmentService {
    
    // Main method to assign leads
    public static void assignLeads(List<Lead> scoredLeads) {
        // Get available sales reps and their capacity/specialties
        Map<Id, User> availableReps = getAvailableSalesReps();
        Map<Id, String> repSpecialties = getRepSpecialties();
        Map<Id, Integer> repCapacity = getRepCapacity();
        
        // Leads that need assignment
        List<Lead> leadsToUpdate = new List<Lead>();
        List<Task> tasksToCreate = new List<Task>();
        List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();
        
        for(Lead lead : scoredLeads) {
            // Skip if already assigned
            if(lead.Assigned_To__c != null) continue;
            
            // Find best rep based on scoring and availability
            User assignedRep = findBestRep(lead, availableReps, repSpecialties, repCapacity);
            
            if(assignedRep != null) {
                lead.Assigned_To__c = assignedRep.Id;
                lead.Assignment_Status__c = 'Assigned';
                leadsToUpdate.add(lead);
                
                // Create notification task
                Task notification = createNotificationTask(lead, assignedRep);
                tasksToCreate.add(notification);
                
                // Decrease rep capacity
                if(repCapacity.containsKey(assignedRep.Id)) {
                    repCapacity.put(assignedRep.Id, repCapacity.get(assignedRep.Id) - 1);
                }
                
                // Submit high-value leads for approval
                if(lead.Lead_Grade__c == 'A') {
                    Approval.ProcessSubmitRequest req = createApprovalRequest(lead);
                    approvalRequests.add(req);
                }
            }
        }
        
        // Update leads
        if(!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
        
        // Create notification tasks
        if(!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
        }
        
        // Submit approval requests
        if(!approvalRequests.isEmpty()) {
            List<Approval.ProcessResult> results = Approval.process(approvalRequests);
        }
    }
    
    // Get available sales reps
    private static Map<Id, User> getAvailableSalesReps() {
        Map<Id, User> reps = new Map<Id, User>();
        for(User u : [SELECT Id, Name, Title, Department, Email 
                      FROM User 
                      WHERE IsActive = true 
                      AND Profile.Name = 'Sales User'
                      ORDER BY Name]) {
            reps.put(u.Id, u);
        }
        return reps;
    }
    
    // Get rep specialties (industry expertise)
    private static Map<Id, String> getRepSpecialties() {
        Map<Id, String> specialties = new Map<Id, String>();
        // In a real implementation, this would come from a custom object or field
        // For this example, we'll hardcode some values
        
        // Query all sales users
        for(User u : [SELECT Id, Industry_Specialty__c FROM User WHERE IsActive = true AND Profile.Name = 'Sales User']) {
            if(u.Industry_Specialty__c != null) {
                specialties.put(u.Id, u.Industry_Specialty__c);
            }
        }
        
        return specialties;
    }
    
    // Get current capacity of reps
    private static Map<Id, Integer> getRepCapacity() {
        Map<Id, Integer> capacityMap = new Map<Id, Integer>();
        
        // Get rep IDs
        List<Id> repIds = new List<Id>();
        for(User u : [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'Sales User']) {
            repIds.add(u.Id);
            // Default max capacity is 10 leads per rep
            capacityMap.put(u.Id, 10); 
        }
        
        // Count current leads assigned to each rep
        AggregateResult[] results = [SELECT Assigned_To__c, COUNT(Id) leadCount 
                                     FROM Lead 
                                     WHERE Assigned_To__c IN :repIds 
                                     AND Assignment_Status__c IN ('Assigned', 'In Progress')
                                     GROUP BY Assigned_To__c];
        
        for(AggregateResult ar : results) {
            Id repId = (Id)ar.get('Assigned_To__c');
            Integer currentLeadCount = (Integer)ar.get('leadCount');
            // Remaining capacity
            capacityMap.put(repId, capacityMap.get(repId) - currentLeadCount);
        }
        
        return capacityMap;
    }
    
    // Find best rep for a lead
    private static User findBestRep(Lead lead, Map<Id, User> reps, Map<Id, String> specialties, Map<Id, Integer> capacity) {
        // Priority:
        // 1. Reps with matching industry specialty and capacity
        // 2. Reps with capacity sorted by current workload
        
        // First pass: industry match with capacity
        for(Id repId : reps.keySet()) {
            // Check capacity
            if(!capacity.containsKey(repId) || capacity.get(repId) <= 0) {
                continue;
            }
            
            // Check industry specialty
            if(specialties.containsKey(repId) && lead.Industry != null && 
               specialties.get(repId).equalsIgnoreCase(lead.Industry)) {
                return reps.get(repId);
            }
        }
        
        // Second pass: just find someone with capacity
        Id bestRepId = null;
        Integer highestCapacity = 0;
        
        for(Id repId : capacity.keySet()) {
            Integer repCapacity = capacity.get(repId);
            if(repCapacity > highestCapacity) {
                highestCapacity = repCapacity;
                bestRepId = repId;
            }
        }
        
        return bestRepId != null ? reps.get(bestRepId) : null;
    }
    
    // Create notification task for the rep
    private static Task createNotificationTask(Lead lead, User rep) {
        Task t = new Task();
        t.Subject = 'New Lead Assigned: ' + lead.Company;
        t.Description = 'A new ' + lead.Lead_Grade__c + ' grade lead has been assigned to you.';
        t.Priority = lead.Lead_Grade__c == 'A' ? 'High' : 'Normal';
        t.Status = 'Not Started';
        t.WhoId = lead.Id;
        t.OwnerId = rep.Id;
        t.ActivityDate = Date.today();
        return t;
    }
    
    // Create approval request for high-value leads
    private static Approval.ProcessSubmitRequest createApprovalRequest(Lead lead) {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(lead.Id);
        req.setProcessDefinitionNameOrId('Lead_Assignment_Approval');
        req.setSubmitterIds(new Id[] {UserInfo.getUserId()});
        req.setComments('Automatic submission for high-value lead');
        return req;
    }
}