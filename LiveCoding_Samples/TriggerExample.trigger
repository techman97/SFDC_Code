trigger TriggerExample on Account (after update) {

    //////////////////////////////////////////////
    // Use Case:  Need to update all Contacts when an Account is updated
    //////////////////////////////////////////////

    /***********************************
    *
    * BAD EXAMPLE
    * Violates two common governor limits:
    *   - SOQL queries issued
    *   - DML statements issued
    *
    ***********************************/

    // For Loop to iterate through all incoming Account records
    for(Account acct : trigger.new) {

        // VIOLATION #1 - SOQL WITHIN A LOOP!
        List<Contact> lstContacts = [SELECT Id, Name FROM Contact WHERE AccountId = :acct.Id];

        for(Contact cont : lstContacts) {
            cont.description = 'blah blah blah';

            // VIOLATION #2:  DML WITHIN A LOOP!
            update cont;
        }

    }

    /***********************************
    *
    * OK EXAMPLE
    * Addresses two common governor limits:
    *   - SOQL queries issued
    *   - DML statements issued
    *
    * Introduces possible new violations:
    *   - Script CPU time
    *   - Heap Size
    *
    ***********************************/

    // Get all Contacts for Accounts in Scope
    List<Contact> lstContacts = [SELECT Id, Name, Description, AccountId FROM Contact WHERE AccountId IN :trigger.newMap.keySet()];
    
    // Create seperate empty list to put Contacts to be updated in
    List<Contact> lstContactsToUpdate = new List<Contact>();

    // For Loop to iterate through all incoming Account records
    for(Account acct : trigger.new) {

        // REMEDIED VIOLATION #1 - SOQL WITHIN A LOOP!
        // List<Contact> lstContacts = [SELECT Id, Name FROM Contact WHERE AccountId = :acct.Id];

        for(Contact cont : lstContacts) {
            if(cont.AccountId == acct.Id) {
                cont.description = 'blah blah blah';
                lstContactsToUpdate.add(cont);
            }

            // REMEDIED VIOLATION #2:  DML WITHIN A LOOP!
            //update cont;
        }

    }

    if(lstContactsToUpdate.size() > 0) {
        update lstContactsToUpdate;
    }

    /***********************************
    *
    * BETTER EXAMPLE
    * Addresses two common governor limits:
    *   - SOQL queries issued
    *   - DML statements issued
    *
    * Addresses new violation:
    *   - Script CPU time
    *
    * Does not address:
    *   - Heap Size
    *
    ***********************************/

    // Get all Contacts for Accounts in Scope
    List<Account> lstAccounts = [SELECT Id, Name, (SELECT Id, Name, Description FROM Contacts) FROM Account WHERE Id IN :trigger.newMap.keySet()];
    
    // Create seperate empty list to put Contacts to be updated in
    List<Contact> lstRelContactsToUpdate = new List<Contact>();

    // For Loop to iterate through all incoming Account records
    for(Account acct : lstAccounts) {

        for(Contact cont : acct.Contacts) {
            cont.description = 'blah blah blah';
            lstRelContactsToUpdate.add(cont);
        }
    }

    if(lstRelContactsToUpdate.size() > 0) {
        update lstRelContactsToUpdate;
    }

    /***********************************
    *
    * EVEN BETTER EXAMPLE
    * Addresses two common governor limits:
    *   - SOQL queries issued
    *   - DML statements issued
    *
    * Addresses new violations:
    *   - Script CPU time
    *   - Heap Size
    *
    ***********************************/
    
    // Create seperate empty list to put Contacts to be updated in
    List<Contact> lstHeapContactsToUpdate = new List<Contact>();

    // For Loop to iterate through all incoming Account records
    for(Account acct : [SELECT Id, Name, (SELECT Id, Name, Description FROM Contacts) FROM Account WHERE Id IN :trigger.newMap.keySet()]) {

        for(Contact cont : acct.Contacts) {
            cont.description = 'blah blah blah';
            lstHeapContactsToUpdate.add(cont);
        }
    }

    if(lstHeapContactsToUpdate.size() > 0) {
        update lstHeapContactsToUpdate;
    }

}