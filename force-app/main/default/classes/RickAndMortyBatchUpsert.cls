public with sharing class RickAndMortyBatchUpsert implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    Integer succesfulUpserts = 0;
    Integer failedUpserts = 0;   
    Integer errorsFindingCharacter = 0; 
    Integer errorsAPICall = 0; 
    Integer firstCharacter;
    Integer amountOfCharactersToCall;
    final static String RICK_AND_MORTY_API = 'https://rickandmortyapi.com/api/character/';    
    final static Integer TOTAL_AMOUNT_OF_CHARACTERS = 826;
    final static Integer BATCH_SIZE = 100;
    final static Integer ORIGINAL_FIRST_CHARACTER = 1;


    
    //Constructor que mantiene el valor por defecto de la cantidad de personajes a llamar segun la funcionalidad inicial de llamar a todos los personajes que se saben que existen hasta ahora, es decir,  hasta el 826
    public RickAndMortyBatchUpsert() {
        this.firstCharacter = ORIGINAL_FIRST_CHARACTER;
        this.amountOfCharactersToCall = TOTAL_AMOUNT_OF_CHARACTERS;        
    }
    //Constructor para agregar funcionalidad para variar hasta que personaje llamar. 
    //Esto sirve en caso de que se quiera llamar a un numero menor de personajes 
    //o si se quieren llamar a mas personajes en un futuro en el cual se amplie la cantidad de personajes
    public RickAndMortyBatchUpsert(Integer numberOfCharactersToCall) {
        this.firstCharacter = ORIGINAL_FIRST_CHARACTER;
        this.amountOfCharactersToCall = numberOfCharactersToCall;        
    }

    //Constructor para agregar la funcionalidad de proveer el rango de personajes a llamar
    //Esto sirve para que si se quieren llamar un rango de personajes, por ejemplo de 100 a 500,
    //para por ejemplo solo actualizar estos
    public RickAndMortyBatchUpsert(Integer firstCharacter, Integer lastCharacter) {        
        this.firstCharacter = firstCharacter;
        this.amountOfCharactersToCall = lastCharacter;
    }

    /*Para correr la clase en Anonymous Window y que traiga a todos los personajes que se saben que existen hasta el momento:
    RickAndMortyBatchUpsert batch = new RickAndMortyBatchUpsert();
    Database.executeBatch(batch,100); 
    
    Si quiero que traiga hasta el personaje 100:
    RickAndMortyBatchUpsert batch = new RickAndMortyBatchUpsert(100);
    Database.executeBatch(batch,100);

    Si quiero que traiga del personaje 50 al 100:
    RickAndMortyBatchUpsert batch = new RickAndMortyBatchUpsert(50,100);
    Database.executeBatch(batch,100);
    
    O

    Uso los metodos estaticos runBatchWithFixedScope(), runBatchWithVariableScope(Integer numberOfCharacters),
    runBatchWithVariableScope(Integer fromCharacter, Integer toCharacter) 
    para ejecutar el batch con un tamaño fijo de lote de 100.
    En la ventana Anonymous Window escribo, por ejemplo:
    RickAndMortyBatchUpsert.runBatchWithFixedScope();
    RickAndMortyBatchUpsert.runBatchWithVariableScope(100); //inserta o actualiza hasta el 100
    RickAndMortyBatchUpsert.runBatchWithVariableScope(50,100); //inserta o actualiza desde el 50 hasta el 100
    */


    //Metodo para correr el batch con el metodo estatico para ejecutarlo en Anonymous Window
    //Y que trae a todos los personajes que se saben que existen hasta el momento (826)
    public static String runBatchWithFixedScope() {
        RickAndMortyBatchUpsert batch = new RickAndMortyBatchUpsert();    
        String staticExecution = Database.executeBatch(batch, BATCH_SIZE);
        return staticExecution;
    }
    
    //Metodo para correr el batch con el metodo estatico para ejecutarlo en Anonymous Window
    //Y que trae a todos los personajes hasta el que se pone de parametro en la funcion
    public static String runBatchWithVariableScope(Integer numberOfCharacters) {
        RickAndMortyBatchUpsert batch = new RickAndMortyBatchUpsert(numberOfCharacters);    
        String staticExecution = Database.executeBatch(batch, BATCH_SIZE);
        return staticExecution;
    }

    //Metodo sobrecargado para correr el batch con el metodo estatico para ejecutarlo en Anonymous Window
    //Y que trae a todos los personajes desde el personaje que uno indica en el primer parametro del metodo hasta el que se pone en el segundo parametro en la funcion
    public static String runBatchWithVariableScope(Integer fromCharacter, Integer toCharacter) {
        RickAndMortyBatchUpsert batch = new RickAndMortyBatchUpsert(fromCharacter, toCharacter);    
        String staticExecution = Database.executeBatch(batch, BATCH_SIZE);
        return staticExecution;
    }


        public Iterable<Personaje__c> start(Database.BatchableContext bc) {
        System.debug('start');
        //Tengo que crear una lista y llenarla con Personajes ya que si se retorna una lista vacia, el metodo execute no se ejecuta
        List<Personaje__c> charactersForScope = new List<Personaje__c>();
        //Para limitar el numero de personajes durante la prueba:
        Integer limitCharacters = amountOfCharactersToCall;
        if(Test.isRunningTest()){
           limitCharacters = BATCH_SIZE;
            }
        System.debug('limitCharacters : ' + limitCharacters);
        for (Integer characterId = firstCharacter; characterId <= limitCharacters; characterId++) {
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
            String endpoint = RICK_AND_MORTY_API + ch.ExtId__c;             
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
    
    public Integer getErrorsAPICall(){
        return this.errorsAPICall;
    }
    
    public Integer getSuccesfulUpserts(){
      return this.succesfulUpserts;  
    } 
    
    public Integer getFailedUpserts(){
        return this.failedUpserts;
    }   
    
    
}