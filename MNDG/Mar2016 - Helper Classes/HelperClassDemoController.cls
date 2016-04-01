public with sharing class HelperClassDemoController {
/**
*   {Purpose}  �  Controller for HelperClassDemo
*
*   {Contact}   - techman97@gmail.com
*                 www.andyboettcher.com             
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20160401  	Andy Boettcher			Created
*   =============================================================================
*/
	public String strSearchName {get;set;}
	public String strSearchIndustry {get;set;}
	public String strSearchAccountNumber {get;set;}
	//public hClsSearch clsSearch {get;set;}

	public List<Account> lstAccounts {get;set;}
	//public List<hClsResult> lstAccountHelpers {get;set;}

	public Map<Id, Account> mapSelectedAccounts {get;set;}
	public List<Opportunity> lstOpportunities {get;set;}

	public String strQuery {get;set;}

	///////////////////////////
	// Constructors
	///////////////////////////
	public HelperClassDemoController() { 
		
		// Standard sObject Lists
		lstAccounts = new List<Account>();
		mapSelectedAccounts = new Map<Id, Account>();
		lstOpportunities = new List<Opportunity>();

		// Helper Classes!
		//lstAccountHelpers = new List<hClsResult>();
		//clsSearch = new hClsSearch();
	}
	
	///////////////////////////
	// Action Methods
	///////////////////////////
	public void doSearch() {

		// STANDARD SOBJECT VERSION
		lstAccounts = new List<Account>();
		mapSelectedAccounts = new Map<Id, Account>();
		lstOpportunities = new List<Opportunity>();

		strQuery = 'SELECT Id, Name, Industry, AccountNumber, BillingState FROM Account WHERE ';
		strQuery+= 'Active__c = \'Yes\' ';
		if(strSearchName.length() > 0) {
			strQuery+= 'AND Name LIKE \'%' + String.escapeSingleQuotes(strSearchName.trim()) + '%\' ';
		}
		if(strSearchIndustry.length() > 0) {
			strQuery+= 'AND Industry LIKE \'%' + String.escapeSingleQuotes(strSearchIndustry.trim()) + '%\' ';
		}
		if(strSearchAccountNumber.length() > 0) {
			strQuery+= 'AND AccountNumber LIKE \'%' + String.escapeSingleQuotes(strSearchAccountNumber.trim()) + '%\' ';
		}

		lstAccounts = (List<Account>)Database.query(strQuery);

		// HELPER CLASS VERSION!
		//	lstAccountHelpers = new List<hClsResult>();
		//	mapSelectedAccounts = new Map<Id, Account>();
		//	lstOpportunities = new List<Opportunity>();

		//	strQuery = 'SELECT Id, Name, Industry, AccountNumber, BillingState FROM Account WHERE ';
		//	strQuery+= 'Active__c = \'Yes\' ';
		//	if(clsSearch.strSearchName.length() > 0) {
		//		strQuery+= 'AND Name LIKE \'%' + String.escapeSingleQuotes(clsSearch.strSearchName.trim()) + '%\' ';
		//	}
		//	if(clsSearch.strSearchIndustry.length() > 0) {
		//		strQuery+= 'AND Industry LIKE \'%' + String.escapeSingleQuotes(clsSearch.strSearchIndustry.trim()) + '%\' ';
		//	}
		//	if(clsSearch.strSearchAccountNumber.length() > 0) {
		//		strQuery+= 'AND AccountNumber LIKE \'%' + String.escapeSingleQuotes(clsSearch.strSearchAccountNumber.trim()) + '%\' ';
		//	}

		//	for(Account objAcct : (List<Account>)Database.query(strQuery)) {
		//		lstAccountHelpers.add(new hClsResult(objAcct));
		//	}

	}

	public void doAllTheThings() {

		//mapSelectedAccounts = new Map<Id, Account>();
		//lstOpportunities = new List<Opportunity>();

		//// Process Selected Accounts
		//for(hClsResult objResult : lstAccountHelpers) {
		//	if(objResult.bolSelected) {
		//		mapSelectedAccounts.put(objResult.soAcct.Id, objResult.soAcct);
		//	}
		//}

		//// Pull all Opps for Selected Accounts
		//lstOpportunities = [
		//					SELECT 
		//						Id, 
		//						Name, 
		//						Amount, 
		//						StageName, 
		//						CloseDate 
		//					FROM 
		//						Opportunity 
		//					WHERE
		//						AccountId IN :mapSelectedAccounts.keyset() 
		//					];

	}
	
	
	///////////////////////////
	// Inner / Helper Classes
	///////////////////////////
	//public class hClsResult {
	//	public Boolean bolSelected {get;set;}
	//	public Account soAcct {get;set;}

	//	public hClsResult(Account passAccount) {
	//		bolSelected = false;
	//		soAcct = passAccount;
	//	}
	//}

	//public class hClsSearch {
	//	public String strSearchName {get;set;}
	//	public String strSearchIndustry {get;set;}
	//	public String strSearchAccountNumber {get;set;}
	//}
}