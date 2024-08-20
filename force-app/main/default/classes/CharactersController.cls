public with sharing class CharactersController {


    @AuraEnabled(Cacheable=true)
    public static List<Personaje__c> getCharacters(){
            return [SELECT Id, ExtId__c, Name, Status__c, 
                    Species__c, Gender__c, ImageUrl__c, Image__c, Url__c 
                    FROM Personaje__c WITH SECURITY_ENFORCED ORDER BY ExtId__c ASC];
    }
}