trigger LeadScoringTrigger on Lead (before insert, before update, after insert, after update) {
    // Before events - calculate the score
    if(Trigger.isBefore) {
        List<Lead> leadsToScore = new List<Lead>();
        
        for(Lead lead : Trigger.new) {
            // Score new leads
            if(Trigger.isInsert) {
                leadsToScore.add(lead);
            }
            // Score updated leads where key fields changed
            else if(Trigger.isUpdate) {
                Lead oldLead = Trigger.oldMap.get(lead.Id);
                if(lead.LeadSource != oldLead.LeadSource || 
                   lead.Industry != oldLead.Industry ||
                   lead.NumberOfEmployees != oldLead.NumberOfEmployees) {
                    leadsToScore.add(lead);
                }
            }
        }
        
        // Score the leads
        if(!leadsToScore.isEmpty()) {
            LeadScoringService.scoreLeads(leadsToScore);
        }
    }
    
    // After events - handle assignment
    if(Trigger.isAfter) {
        List<Lead> leadsToAssign = new List<Lead>();
        
        for(Lead lead : Trigger.new) {
            // New leads that have been scored
            if(Trigger.isInsert && lead.Lead_Score__c != null && lead.Assigned_To__c == null) {
                leadsToAssign.add(lead);
            }
            // Updated leads where score changed and not yet assigned
            else if(Trigger.isUpdate) {
                Lead oldLead = Trigger.oldMap.get(lead.Id);
                if(lead.Lead_Score__c != oldLead.Lead_Score__c && lead.Assigned_To__c == null) {
                    leadsToAssign.add(lead);
                }
            }
        }
        
        // Assign the leads
        if(!leadsToAssign.isEmpty()) {
            LeadAssignmentService.assignLeads(leadsToAssign);
        }
    }
}