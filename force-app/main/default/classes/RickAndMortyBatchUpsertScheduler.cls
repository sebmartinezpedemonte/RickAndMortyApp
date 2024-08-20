public with sharing class RickAndMortyBatchUpsertScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        RickAndMortyBatchUpsert batch = new RickAndMortyBatchUpsert();
        Database.executeBatch(batch,100);
    }
}