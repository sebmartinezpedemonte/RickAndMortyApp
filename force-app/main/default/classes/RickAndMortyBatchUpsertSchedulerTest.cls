@isTest
private class RickAndMortyBatchUpsertSchedulerTest {

    @isTest
    static void testSchedulerExecution() {
        List<Personaje__c> characters = new List<Personaje__c>();
        for (Integer i = 1; i <= 5; i++) {
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
  
        Test.setMock(HttpCalloutMock.class, new RickAndMortyApiCalloutMock());
        List<CronTrigger> existingJobs = [SELECT Id, CronJobDetail.Name, State FROM CronTrigger WHERE CronJobDetail.Name = 'RickAndMortyBatchUpsert Job'];
        for (CronTrigger job : existingJobs) {
            System.abortJob(job.Id);
        }
        String cronExp = '0 0 19 ? * MON-FRI'; // A las 19:00 horas de lunes a viernes
        System.schedule('RickAndMortyBatchUpsert Job', cronExp, new RickAndMortyBatchUpsertScheduler());
        Test.startTest();
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name, State FROM CronTrigger WHERE CronJobDetail.Name = 'RickAndMortyBatchUpsert Job'];
        Test.stopTest(); 
        List<Personaje__c> charactersUpserted = [SELECT Id, Name FROM Personaje__c];
        System.assertEquals(5, charactersUpserted.size(), 'Se esperaban 5 personajes despues de la ejecucion del batch');
    }
}