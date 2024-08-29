public with sharing class RickAndMortyBatchUpsertScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {        
        /*Forma de programar el batch a traves de la Anonymous Window para las 19:00 horas de lunes a viernes:
        String cronExp = '0 0 19 ? * MON-FRI';
        System.schedule('RickAndMortyBatchUpsert Job', cronExp, new RickAndMortyBatchUpsertScheduler());
        */
       	RickAndMortyBatchUpsert batch = new RickAndMortyBatchUpsert();
        Database.executeBatch(batch,100);
    }
}