@isTest
private class LiveCoding_UnitTest {

	//////////////////////////////////////
	// This unit test covers LiveCoding_Main Account trigger
	//////////////////////////////////////

	/**
	*   CHANGE  HISTORY
	*   =============================================================================
	*   Date    	Name             		Description
	*   20150708  	Andy Boettcher			Created
	*   =============================================================================
	*/
	
	@isTest static void LiveCodingAccountTrigger() {
		
		// Set your test data - NEVER use org data!!
		Account acct = new Account();
		acct.Name = 'Test Account';
		insert acct;

		Contact cont1 = new Contact();
		cont1.Lastname = 'Lastname1';
		cont1.AccountId = acct.id;
		insert cont1;

		Contact cont2 = new Contact();
		cont2.Lastname = 'Lastname2';
		cont2.AccountId = acct.id;
		insert cont2;

		// Start the test!
		test.startTest();

		// Update the Account
		update acct;

		// Poll all Contacts and verify the triggered change
		for(Contact con : [SELECT Id, Description FROM Contact WHERE AccountId = :acct.Id]) {
			System.Assert(con.Description == 'blah blah blah', 'The Contact did not get updated properly!');
		}

		// Stop the test!
		test.stopTest();

	}
	
}