public class LeadScoringService {
    
    // Main method to calculate lead score
    public static void scoreLeads(List<Lead> leads) {
        for(Lead lead : leads) {
            // Calculate individual scores
            Integer sourceScore = calculateSourceScore(lead.LeadSource);
            Integer industryScore = calculateIndustryScore(lead.Industry);
            Integer companySizeScore = calculateCompanySizeScore(lead.NumberOfEmployees);
            
            // Store component scores for reporting
            lead.Lead_Source_Score__c = sourceScore;
            lead.Industry_Score__c = industryScore;
            lead.Company_Size_Score__c = companySizeScore;
            
            // Calculate total score
            Integer totalScore = sourceScore + industryScore + companySizeScore;
            lead.Lead_Score__c = totalScore;
            
            // Determine grade based on score
            lead.Lead_Grade__c = calculateGrade(totalScore);
            
            // Update scoring timestamp
            lead.Last_Scored_Date__c = System.now();
        }
    }
    
    // Calculate score based on lead source
    private static Integer calculateSourceScore(String leadSource) {
        Map<String, Integer> sourceScores = new Map<String, Integer>{
            'Web' => 20,
            'Phone Inquiry' => 30,
            'Partner Referral' => 40,
            'Purchased List' => 10,
            'Event' => 35,
            'Social Media' => 15
        };
        
        return sourceScores.containsKey(leadSource) ? sourceScores.get(leadSource) : 5;
    }
    
    // Calculate score based on industry
    private static Integer calculateIndustryScore(String industry) {
        Map<String, Integer> industryScores = new Map<String, Integer>{
            'Financial Services' => 40,
            'Healthcare' => 35,
            'Manufacturing' => 30,
            'Retail' => 25,
            'Technology' => 45,
            'Education' => 20
        };
        
        return industryScores.containsKey(industry) ? industryScores.get(industry) : 15;
    }
    
    // Calculate score based on company size
    private static Integer calculateCompanySizeScore(Integer numberOfEmployees) {
        if(numberOfEmployees == null) return 5;
        
        if(numberOfEmployees > 1000) return 40;
        if(numberOfEmployees > 500) return 35;
        if(numberOfEmployees > 100) return 30;
        if(numberOfEmployees > 50) return 20;
        if(numberOfEmployees > 10) return 15;
        return 10;
    }
    
    // Determine lead grade based on total score
    private static String calculateGrade(Integer score) {
        if(score >= 80) return 'A';
        if(score >= 60) return 'B';
        if(score >= 40) return 'C';
        return 'D';
    }
}