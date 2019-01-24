public with sharing class StudioPageController {
    private final Studio__c con;
    public StudioPageController(ApexPages.StandardController stdController) {
        this.con = (Studio__c)stdController.getRecord();
    }

    public List<Movie__c> AllMovies{get;set;}

    public List<Movie__c> getMovies() {
        Studio__c ThisStudio = [SELECT Id, Name FROM Studio__c WHERE Id =: ApexPages.currentPage().getParameters().get('id') LIMIT 1];
        AllMovies = [SELECT Id, Name, Status__c, Studio__c FROM Movie__c WHERE Status__c = 'In Process' AND Studio__c =: ThisStudio.Id ];
        return AllMovies;
    }

    public void MovieFinish(){
        Id MovieId = ApexPages.currentPage().getParameters().get('idMovie');
        Movie__c MovieForUpdate = [SELECT Id, Name, Status__c, Studio__c FROM Movie__c WHERE Id =: MovieId LIMIT 1];
        MovieForUpdate.Status__c = 'Finished';
        try{
            update MovieForUpdate;
        } catch (Exception e){
            e.getMessage();
        }

    }
}