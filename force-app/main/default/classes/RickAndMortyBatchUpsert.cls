public with sharing class RickAndMortyBatchUpsert implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    Integer succesfulUpserts = 0;
    public Integer failedUpserts = 0;
    public Integer errorsFindingCharacter = 0;
    public Integer errorsAPICall = 0;
    final static Integer TOTAL_AMOUNT_OF_CHARACTERS = 826;
    final static Integer BATCH_SIZE = 100;
    /*Para correr la clase:
    RickAndMortyBatchUpsert batch = new RickAndMortyBatchUpsert();
    Database.executeBatch(batch,100); 
    O
    Uso el metodo estatico runBatchWithFixedScope() para ejecutar el batch con un tamaño fijo de lote de 100
    En la ventana Anonymous Window escribo:
    RickAndMortyBatchUpsert.runBatchWithFixedScope();
    */

    public static String runBatchWithFixedScope() {
        RickAndMortyBatchUpsert batch = new RickAndMortyBatchUpsert();    
        String staticExecution = Database.executeBatch(batch, BATCH_SIZE);
        return staticExecution;
    }
        public Iterable<Personaje__c> start(Database.BatchableContext bc) {
        System.debug('start');
        //Tengo que crear una lista y llenarla con Personajes ya que si se retorna una lista vacia, el metodo execute no se ejecuta
        List<Personaje__c> charactersForScope = new List<Personaje__c>();
        //Para limitar el numero de personajes durante la prueba:
        Integer limitCharacters = TOTAL_AMOUNT_OF_CHARACTERS;
        if(Test.isRunningTest()){
           limitCharacters = BATCH_SIZE;
            }
        System.debug('limitCharacters : ' + limitCharacters);
        for (Integer characterId = 1; characterId <= limitCharacters; characterId++) {
            charactersForScope.add(new Personaje__c(ExtId__c = characterId));
            System.debug('characterId: ' + characterId);
        }
        System.debug('characterIds size: ' + charactersForScope.size());
        return charactersForScope;
    }

    public void execute(Database.BatchableContext bc, List<Personaje__c> scope) {    
        System.debug('execute');
        List<Personaje__c> charactersToUpsert = new List<Personaje__c>(); 
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        System.debug('scope.size():' + scope.size());
        for (Personaje__c ch : scope) {
            String endpoint = 'https://rickandmortyapi.com/api/character/' + ch.ExtId__c;             
            System.debug('characterId: ' + ch.ExtId__c);
            request.setEndpoint(endpoint);
            try {
                HttpResponse response = http.send(request);
                System.debug('response: ' + response.getStatus());
                if (response.getStatusCode() == 200) {
                    Map<String, Object> characterData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    System.debug(characterData);
                    if (!characterData.isEmpty()) {
                        System.debug(characterData.get('name'));
                        Personaje__c character = new Personaje__c();
                        character.ExtId__c = (Integer) characterData.get('id');
                        character.Name = (String) characterData.get('name');                        
                        character.Status__c = (String) characterData.get('status');
                        character.Species__c = (String) characterData.get('species');
                        character.Gender__c = (String) characterData.get('gender');
                        character.ImageUrl__c = (String) characterData.get('image');
                        character.Url__c = (String) characterData.get('url');
                        System.debug('personaje: '+ character);
                        charactersToUpsert.add(character);                      
                    }
                }else{
                    System.debug('No se encontro el personaje con ID ' + ch.ExtId__c);
                    errorsFindingCharacter++;
                }

            } catch (Exception e) {
                System.debug('Error en la llamada API para el personaje con ID ' + ch.ExtId__c + ': ' + e.getMessage());
                errorsAPICall++;
            }
        }
        System.debug('Cantidad de personajes por insertar o actualizar: ' + charactersToUpsert.size());
        if (!charactersToUpsert.isEmpty()) {
            upsertCharacters(charactersToUpsert);            
        }
    }

    private void upsertCharacters(List<Personaje__c> charactersUpsert){
        System.debug('Database upsert');
        Database.UpsertResult[] srList = Database.upsert(charactersUpsert, Personaje__c.ExtId__c, false);
        for(Database.UpsertResult sr : srList){
            if(sr.isSuccess()){
                System.debug('Personaje insertado o actualizado con ID: ' + sr.getId());
                succesfulUpserts++;
            }else{
                for(Database.Error err : sr.getErrors()){
                    System.debug('Error al insertar o actualizar el personaje: ' + err.getMessage());
                    System.debug('Campo en el que ocurrio el error: ' + err.getFields());
                    failedUpserts++;
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Personajes insertados o actualizados: ' + succesfulUpserts);
        System.debug('Personajes con error ' + failedUpserts);
    }
}