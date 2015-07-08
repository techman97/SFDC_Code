trigger LiveCoding_Main on Account (after update) {

	//////////////////////////////////////
	// This trigger updates all Contacts when an Account is updated
	//////////////////////////////////////

	/**
	*   CHANGE  HISTORY
	*   =============================================================================
	*   Date    	Name             		Description
	*   20150708  	Andy Boettcher			Created
	*   =============================================================================
	*/

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

}