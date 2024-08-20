@isTest
private class RickAndMortyBatchUpsertTest {

    @TestSetup
    static void setup() {
        List<Personaje__c> characters = new List<Personaje__c>();
        for(Integer i = 1 ; i <= 5 ; i++){
            characters.add(new Personaje__c(
            ExtId__c = i,
            Name='Rick Sanchez', 
            Status__c='Alive', 
            Species__c='Human', 
            Gender__c = 'Male',
            ImageUrl__c = 'https://rickandmortyapi.com/api/character/avatar/'+ i + '.jpeg',
            Url__c = 'https://rickandmortyapi.com/api/character/' + i    
            ));
        }               
        Database.upsert(characters, Personaje__c.ExtId__c, false);
    }

    @isTest
    static void testBatchExecutionSuccess() {
        Test.setMock(HttpCalloutMock.class, new RickAndMortyApiCalloutMock());
        Test.startTest();
		RickAndMortyBatchUpsert.runBatchWithFixedScope();
        Test.stopTest();
        List<Personaje__c> upsertedCharacters = [SELECT Id, Name, Status__c FROM Personaje__c WHERE ExtId__c = 1];
        System.assertEquals(1, upsertedCharacters.size(), 'Se deberia haber insertado un personaje con ExtId = 1');
        System.assertEquals('Rick Sanchez', upsertedCharacters[0].Name, 'El nombre del personaje deberia ser Rick Sanchez');
    }

    @isTest
    static void testBatchExecutionApiError() {
        Test.setMock(HttpCalloutMock.class, new RickAndMortyApiCalloutMockWithError());
        Test.startTest();
        RickAndMortyBatchUpsert.runBatchWithFixedScope();
        Test.stopTest();
        List<Personaje__c> errorCharacters = [SELECT Id, Name FROM Personaje__c WHERE ExtId__c = 9999];
        System.assertEquals(0, errorCharacters.size(), 'No deberia haberse insertado o actualizado ningun personaje debido al error de la API');
    }
    
    
    @isTest
    static void testHandleApiCalloutException(){
        Test.setMock(HttpCalloutMock.class, new RickAndMortyMockHttpErrorResponse());
		RickAndMortyBatchUpsert batch = new RickAndMortyBatchUpsert();        
        List<Personaje__c> scope = [SELECT Id, ExtId__c FROM Personaje__c];
        
        Test.startTest();
        batch.execute(null, scope);        
        Test.stopTest();
        
        System.assertEquals(5, batch.errors, 'Se esperaba que la cantidad de errores sea 5 por la excepcion simulada');
    }
        
}