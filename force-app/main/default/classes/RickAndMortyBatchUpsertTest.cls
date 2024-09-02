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
        List<Personaje__c> upsertedCharacters = [SELECT Id, Name, Status__c FROM Personaje__c];
        System.assertEquals(5, upsertedCharacters.size(), 'Se deberian haber insertado 5 personajes');
        System.assertEquals('Rick Sanchez', upsertedCharacters[0].Name, 'El nombre del primer personaje deberia ser Rick Sanchez');        

        
  }

        @isTest
    static void testBatchExecutionSuccessVariableScope1() {
        Test.setMock(HttpCalloutMock.class, new RickAndMortyApiCalloutMock());	
        Test.startTest();
		RickAndMortyBatchUpsert.runBatchWithVariableScope(3);        
        Test.stopTest();
        List<Personaje__c> upsertedCharacters = [SELECT Id, Name, Status__c FROM Personaje__c];
        System.assertEquals('Rick Sanchez', upsertedCharacters[0].Name, 'El nombre del primer personaje deberia ser Rick Sanchez');       
  }
    
            @isTest
    		static void testBatchExecutionSuccessVariableScope2() {
                Test.setMock(HttpCalloutMock.class, new RickAndMortyApiCalloutMock());        
                Test.startTest();
                RickAndMortyBatchUpsert.runBatchWithVariableScope(2,3);
                Test.stopTest();
                List<Personaje__c> upsertedCharacters = [SELECT Id, Name, Status__c FROM Personaje__c];
                System.assertEquals('Rick Sanchez', upsertedCharacters[0].Name, 'El nombre del primer personaje deberia ser Rick Sanchez');          
  		}
    
    @isTest
    static void testBatchExecutionApiError() {
        Test.setMock(HttpCalloutMock.class, new RickAndMortyApiCalloutMockWithError());
        Test.startTest();
        RickAndMortyBatchUpsert batch = new RickAndMortyBatchUpsert();
		Database.executeBatch(batch, 100);         
        Test.stopTest();        
        System.assertEquals(0, batch.getSuccesfulUpserts(), 'No deberia haberse insertado o actualizado ningun personaje debido al error de la API');
    }
    
    
    @isTest
    static void testHandleApiCalloutException(){
        Test.setMock(HttpCalloutMock.class, new RickAndMortyMockHttpErrorResponse());
		RickAndMortyBatchUpsert batch = new RickAndMortyBatchUpsert();        
        List<Personaje__c> scope = [SELECT Id, ExtId__c FROM Personaje__c];        
        Test.startTest();
        batch.execute(null, scope);        
        Test.stopTest();        
        System.assertEquals(5, batch.getErrorsAPICall(), 'Se esperaba que la cantidad de errores sea 5 por la excepcion simulada');
    }
    
    @isTest
    static void performanceTest() {
        List<Personaje__c> characters = new List<Personaje__c>();
        Integer numRecords = 9000;         
        for(Integer i = 1; i <= numRecords; i++) {
            characters.add(new Personaje__c(
                ExtId__c = i,
                Name = 'Character ' + i,
                Status__c = 'Alive',
                Species__c = 'Human',
                Gender__c = 'Male',
            	ImageUrl__c = 'https://rickandmortyapi.com/api/character/avatar/'+ i + '.jpeg',
            	Url__c = 'https://rickandmortyapi.com/api/character/' + i 
            ));
        }        
        Database.upsert(characters, Personaje__c.ExtId__c, false);
        Test.setMock(HttpCalloutMock.class, new RickAndMortyApiCalloutMock());
		RickAndMortyBatchUpsert batch = new RickAndMortyBatchUpsert();
        Test.startTest();        
        Database.executeBatch(batch, 100);
        Test.stopTest();
        List<Personaje__c> charactersUpserted = [SELECT Id, Name FROM Personaje__c];
        System.assertEquals(characters.size(), charactersUpserted.size(), 'Se esperaba que se introduzcan personajes');
        System.assertEquals(0, batch.getFailedUpserts(), 'Se esperaba que no haya habido errores al introducir o actualizar');
    }
    
    
        
}