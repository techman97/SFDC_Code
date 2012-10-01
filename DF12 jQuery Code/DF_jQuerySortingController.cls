public with sharing class DF_jQuerySortingController {

	///////////////////////////////////////
	// This class supports the DF_jQuerySortingDemo VF page
	// for the Dreamforce 2012 jQuery presentation
	// Created 20120802AAB / Demand Chain Systems
	// email:  techman97@gmail.com
	///////////////////////////////////////
	
	public String strAccountId {get;set;}
	public String strAcctName {get;set;}
	public String strAcctWeb {get;set;}
	public String strAcctPhone {get;set;}
	public String strRedirectToAccount {get;set;}
	
	public Integer intRecordCount {get;set;}
	
	//////////////////////////////
	// Constructors
	//////////////////////////////
	
	public DF_jQuerySortingController() { 
		
		strRedirectToAccount = '';
		intRecordCount = 5;
		
	}
	
	//////////////////////////////
	// GETers
	//////////////////////////////
	
	public List<Account> getlstAccounts() {
		
		List<Account> lstAcct = new List<Account>([SELECT Id, Name, Website, Phone FROM Account ORDER BY LastModifiedDate DESC LIMIT :intRecordCount]);
		
		return lstAcct;
		
	}
	
	//////////////////////////////
	// Action Methods
	//////////////////////////////
	
	public void doNothing() { }
	
	public PageReference createAccount() {
		
		Account acctNew = new Account();
		acctNew.Name = strAcctName;
		acctNew.Website = strAcctWeb;
		acctNew.Phone = strAcctPhone;
		
		insert acctNew;
		
		if(strRedirectToAccount == 'on') {
			PageReference prRef = new PageReference('/' + acctNew.Id + '/e?retURL=/apex/DF_jQuerySortingDemo?sfdc.tabName=01rC00000004eCc');
			prRef.setRedirect(true);
			return prRef;
		}
		
		return null;
		
	}
	
	public void deleteAccount() {
		
		Account acctDel = new Account(Id=strAccountId);
		delete acctDel;
		
	}
	
	

}