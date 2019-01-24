public with sharing class ContactActorInfoController {


    public void B() {

    }


    public void A() {

    }


    public Contact contact { get; set; }
    public static List<Payment__c> Payments { get; set; }
    public List<PaymentTable> PaymentTable { get; set; }

    public ContactActorInfoController(ApexPages.StandardController std){
        contact = (Contact)std.getRecord();
        Payments = [
                SELECT Id,
                Amount__c,
                Contract__r.Movie__r.Name,
                Contract__r.Movie__r.Studio__r.Name,
                Contract__r.End_Date__c,
                Contract__r.Start_Date__c,
                Contract__r.Contact__c,
                Payment_Date__c
                FROM Payment__c
                WHERE Contract__r.Contact__c =: contact.Id
                AND Payment_Date__c != null
                ORDER BY Payment_Date__c
        ];

        //Get All Unique Dates
        Set<Integer> UniqueDates = new Set<Integer>();

        for (Payment__c payment : Payments){
            Integer ThisYear = payment.Payment_Date__c.year();
            UniqueDates.add(ThisYear);
        }

        List<Integer> sortedUniqueDates = new List<Integer>(UniqueDates);
        sortedUniqueDates.sort();

        PaymentTable = new List<PaymentTable>();
        for (Integer y : sortedUniqueDates){
            PaymentTable.add(new PaymentTable(y));
        }
    }

    public class PaymentTable{
        public Integer Year { get; set;}
        public Decimal TotalAmount { get; set;}
        public List<FormTable> YearInfo { get; set;}

        public PaymentTable(Integer oneYear) {
            Year = oneYear;
            TotalAmount = 0;
            YearInfo = new List<ContactActorInfoController.FormTable>();
            getYearInfo();
        }

        private void getYearInfo(){
            Set<Id> movieIdSet = new Set<Id>();

            for (Payment__c payment : Payments){
                if (movieIdSet.contains(payment.Contract__r.Movie__c)){
                    for (FormTable form : YearInfo){
                        form.Amount += payment.Amount__c;
                        TotalAmount += payment.Amount__c;
                    }
                } else if (payment.Payment_Date__c.year() == year){
                    YearInfo.add(new FormTable(payment));
                    movieIdSet.add(payment.Contract__r.Movie__c);
                    totalAmount += payment.Amount__c;
                }
            }
        }
    }

    public class FormTable{
        public Id IdMovie { get; set; }
        public String Movie { get; set; }
        public String Studio { get; set; }
        public Decimal Amount { get; set; }
        public Integer DateDifferent { get; set; }

        public FormTable(Payment__c payment){
            this.IdMovie = payment.Contract__r.Movie__c;
            this.Movie = payment.Contract__r.Movie__r.Name;
            this.Studio = payment.Contract__r.Movie__r.Studio__r.Name;
            this.Amount = payment.Amount__c;
            this.DateDifferent = payment.Contract__r.Start_Date__c.daysBetween(payment.Contract__r.End_Date__c);
        }
    }


}


