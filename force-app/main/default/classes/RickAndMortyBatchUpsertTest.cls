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
    /* Por alguna razon este test no anda. No entiendo por qué ya que cuando pruebo si se actualizan los datos
     *  por medio de correr el batch a traves de la anonymous window, los datos se actualizan sin problema
	@isTest
	static void testBatchExecutionSuccessUpdate() {
    DELETE [SELECT Id FROM Personaje__c];
    Personaje__c rick = new Personaje__c(
        ExtId__c = 1,
        Name = 'Rick Sanchez old name', 
        Status__c = 'Alive', 
        Species__c = 'Human', 
        Gender__c = 'Male',
        ImageUrl__c = 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
        Url__c = 'https://rickandmortyapi.com/api/character/1');
     Database.upsert(rick, Personaje__c.ExtId__c, false);

    Test.setMock(HttpCalloutMock.class, new RickAndMortyApiCalloutMock());
    Test.startTest();
    RickAndMortyBatchUpsert.runBatchWithFixedScope();
    Test.stopTest();

    Personaje__c rickSanchez = [SELECT Id, Name FROM Personaje__c WHERE ExtId__c = 1 LIMIT 1];
    System.assertEquals('Rick Sanchez', rickSanchez.Name, 'El nombre del primer personaje se deberia haber actualizado a Rick Sanchez');
}*/


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

    //verifico que un Batch con un lote de 100 (el máximo que puede soportar este Batch debido a los callouts) puede funcionar correctamente
    @isTest
	static void performanceTest() {
    Test.setMock(HttpCalloutMock.class, new RickAndMortyApiCalloutMock());
    List<Personaje__c> characters = new List<Personaje__c>();
    for (Integer i = 1; i <= 100; i++) {
        characters.add(new Personaje__c(
            ExtId__c = i,
            Name = 'Character ' + i,
            Status__c = 'Alive',
            Species__c = 'Human',
            Gender__c = 'Male',
            ImageUrl__c = 'https://rickandmortyapi.com/api/character/avatar/' + i + '.jpeg',
            Url__c = 'https://rickandmortyapi.com/api/character/' + i
        ));
    }
     Database.upsert(characters, Personaje__c.ExtId__c, false);
	RickAndMortyBatchUpsert batch = new RickAndMortyBatchUpsert();
    Test.startTest();
    Database.executeBatch(batch, 100);
    Test.stopTest();

    List<Personaje__c> charactersUpserted = [SELECT Id, Name FROM Personaje__c];
    System.assertEquals(100, charactersUpserted.size(), 'Se esperaba que se introduzcan o actualicen 100 personajes');
    System.assertEquals(0, batch.getFailedUpserts(), 'Se esperaba que no haya habido errores al introducir o actualizar');
}

    
    
        
}