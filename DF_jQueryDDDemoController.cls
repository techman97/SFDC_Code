public with sharing class DF_jQueryDDDemoController {

	///////////////////////////////////////
	// This class supports the DF_jQueryDDDemo VF page
	// for the Dreamforce 2012 jQuery presentation
	// Created 20120805AAB / Demand Chain Systems
	// email:  techman97@gmail.com
	///////////////////////////////////////	
	public Id idOpportunity {get;set;}
	public Id idActionOLI {get;set;}
	public Id idActionPBE {get;set;}
	public String strProductFamily {get;set;}
	public Decimal decActionPBEPrice {get;set;}
	public Decimal decOLIQuantity {get;set;}
	public List<OpportunityLineItem> lstOLIs {get;set;}
	public Set<String> setProductFamilies {get;set;}
	public List<SelectOption> lstProductFamily {get;set;}
	
	//////////////////////
	// Controllers
	//////////////////////
	
	public DF_jQueryDDDemoController() { 
	
		lstOLIs = new List<OpportunityLineItem>();
		lstProductFamily = new List<SelectOption>();
		strProductFamily = null;
		
		setProductFamilies = new Set<String>();
		for(Product2 pdt : [SELECT Family FROM Product2 ORDER BY Family ASC]) {
			if(strProductFamily == null) { strProductFamily = pdt.Family; }
			setProductFamilies.add(pdt.Family);
		}
		
		for(String str : setProductFamilies) { lstProductFamily.add(new SelectOption(str, str)); }

	}

	//////////////////////
	// GETers
	//////////////////////
	public List<Opportunity> getLstOpps() {
		
		List<Opportunity> lstTemp = [SELECT Id, Amount, Name, StageName, ExpectedRevenue, LastModifiedDate, TotalOpportunityQuantity 
										FROM Opportunity ORDER BY LastModifiedDate DESC LIMIT 5];
		
		return lstTemp;
		
	}
	
	public List<hClsProduct> lstProducts {
		
		get {
		
			lstProducts = new List<hClsProduct>();
			
			// Get all Product2 in a Map
			Map<Id, Product2> mapProducts = new Map<Id, Product2>([SELECT Id, Name, Family FROM Product2 WHERE IsActive = true]);
			
			for(PricebookEntry p : [Select Id, Product2Id, Pricebook2.Name, UnitPrice From PricebookEntry WHERE Pricebook2.Name = 'Standard Price Book' AND Product2.Family = :strProductFamily ORDER BY Product2.Family, Product2.Name]) {
				
				lstProducts.add(new hClsProduct(p, mapProducts.get(p.Product2Id)));
				
			}

			return lstProducts;

		}
		private set;
		
	}

	//////////////////////
	// Action methods
	//////////////////////
	public void doNothing() { }
	
	public void deleteOpportunity() {
		
		Opportunity opp = new Opportunity(Id=idOpportunity);
		delete opp;
		
	}
	
	public void chooseOpportunity() {
		
		retrieveOLIs();
		
	}
	
	public void addProduct() {
		
		OpportunityLineItem oli = new OpportunityLineItem();
		oli.OpportunityId = idOpportunity;
		oli.PricebookEntryId = idActionPBE;
		oli.Quantity = 1;
		oli.TotalPrice = decActionPBEPrice;
		
		System.Debug('TEST - ' + oli);
		
		insert oli;
		
		retrieveOLIs();
		
	}
	
	public void deleteProduct() {
		
		//for(hClsOLI c : lstOLIs) {
		//	if(c.oli.Id == idActionOLI) {
		for(OpportunityLineItem oli : lstOLIs) {
			if(oli.Id == idActionOLI) {
				delete oli;
				break;
			}
		}
		
		retrieveOLIs();
	
	}
	
	public void saveProducts() {
			
		//for(hClsOLI c : lstOLIs) {
		//	if(c.oli.Id == idActionOLI) {
		for(OpportunityLineItem oli : lstOLIs) {
			if(oli.Id == idActionOLI) {
				oli.TotalPrice = oli.UnitPrice * oli.Quantity;
				update oli;
				break;
			}
		}
		
		retrieveOLIs();
	
	}
	
	public void saveAllProducts() {
		
		update lstOLIs;
		
		retrieveOLIs();
		
	}
	
	public void retrieveOLIs() {
		
		lstOLIs.clear();
		
		lstOLIs = [SELECT Id, Quantity, PricebookEntry.Product2.Name, TotalPrice, UnitPrice FROM OpportunityLineItem WHERE OpportunityId = :idOpportunity];

	}
	
	///////////////////////
	// Helper Classes
	///////////////////////
	public class hClsProduct {
		
		public PricebookEntry pbe {get;set;}
		public Product2 pdt {get;set;}
		
		public hClsProduct(PricebookEntry passPBE, Product2 passPDT) {
			pbe = passPBE;
			pdt = passPDT;
		}
		
	}
	
	public class hClsOLI {
		
		public Decimal decQuantity {get;set;}
		public OpportunityLineItem oli {get;set;}
		
		public hClsOLI(OpportunityLineItem passOLI) {
			
			oli = passOLI;
			decQuantity = oli.Quantity;
			
		}
	}

}