@isTest
private class CharactersControllerTest {
	
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
    static void getCharactersSuccess(){
        List<Personaje__c> charactersToGet = CharactersController.getCharacters();
        System.assertEquals(charactersToGet.size(), 5, 'La lista debia contener 5 personajes ya que fueron insertados 5 en el setup');
    }      
    
    @isTest
    static void getCharactersNoData(){
        delete [SELECT Id FROM Personaje__c];
        List<Personaje__c> charactersToGet = CharactersController.getCharacters();
        System.assertEquals(charactersToGet.size(), 0, 'La lista debia estar vacia ya que se eliminaron los personajes');

    }
    
     @isTest
    static void getCharactersWithLargeData() {
        // Configurar el entorno con una gran cantidad de registros
        List<Personaje__c> characters = new List<Personaje__c>();
        Integer numRecords = 1000; 
        for (Integer i = 1; i <= numRecords; i++) {
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
        
        // Ejecutar la prueba con una gran cantidad de datos
        List<Personaje__c> charactersToGet = CharactersController.getCharacters();
        System.assertEquals(numRecords, charactersToGet.size(), 'La lista debia contener ' + numRecords);
    }
}