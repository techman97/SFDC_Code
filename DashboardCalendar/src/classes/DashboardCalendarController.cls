public with sharing class DashboardCalendarController {
/**
*   {Purpose}	-  	Controller for Dashboard Calendar
*
*   {Contact}	- 	techman97@gmail.com / @andyboettcher         
*	
*	{Open Source}	This code has been released to benefit the Salesforce.com
*					Developer Community.  If you use this source code, please
*					reference my name in the source as contributor and please
*					"pay it forward" by either forking and contributing to this
*					or contributing your own creation to the community.
*					Thank you!
*
*
*	{CalendarSource__c}
*		Name = Name to appear in the Legend
*		Active = Active/Deactivated for view
*		Background Color = HEX color for background (#FFFFFF)
*		Text Color = HEX color for text color (#000000)
*		Start Field = API Field for date
*		End Field = API field for date (use same as Start if all-day)
*		Subject Field = API field to appear in calendar item box
*		Legend Order = Ordering for Sources
*		SOQL Select = API field names to go in SELECT (all have to be here)
*		Object = API sObject name
*		SOQL Where = API field names and criteria for WHERE statement
*	
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20131112  	Andy Boettcher 			Created
*	20140116	Andy Boettcher			Added support to Custom Setting (SOQL Support)
*   20140809  	Andy Boettcher 			Generalized for Open Source Release
*   =============================================================================
*/


	///////////////////////////
	// Constructors
	///////////////////////////
	public DashboardCalendarController() { }	
	
	///////////////////////////
	// Utility Methods
	///////////////////////////
	private static Map<String, String> fieldLabelsForNames(String strObjectName) {

        Map<String, String> fieldLabelsForNames = new Map<String, String>();

        List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{strObjectName});
        Map<String, Schema.SObjectField> allFields = describeSobjectsResult[0].fields.getMap();
        for(String str : allFields.keySet()) {
            fieldLabelsForNames.put(str, allFields.get(str).getDescribe().getLabel());
        }

        return fieldLabelsForNames;
    }

	///////////////////////////
	// Action Methods
	///////////////////////////
	@RemoteAction
	public static List<hClsSource> lstCalendarEvents() {

		List<hClsSource> lstReturn = new List<hClsSource>();
		Date dtePast = System.Today().addMonths(-3);
		Date dteFuture = System.Today().addMonths(3);

		// Get Sources
		List<CalendarSources__c> lstCSSources = [SELECT Id, Name, IsActive__c, Background_Color__c, End_Field__c, 
													Legend_Order__c, Object__c, SOQL_Select__c, SOQL_Where__c, 
													Start_Field__c, Subject_Field__c, Text_Color__c 
													FROM CalendarSources__c
													WHERE IsActive__c = true
													ORDER BY Legend_Order__c ASC];

		for(CalendarSources__c cs : lstCSSources) {

			List<hClsEvent> lstEvents = new List<hClsEvent>();
			hClsSource clsSource = new hClsSource();
			clsSource.strName = cs.Name;
			clsSource.strSourceId = cs.Id;

			Map<String, String> mapLabels = fieldLabelsForNames(cs.Object__c);

			String strQuery = 'SELECT ' + cs.SOQL_Select__c + ' FROM ' + cs.Object__c;
			strQuery+= ' WHERE ' + cs.Start_Field__c + ' > :dtePast ';

			if(cs.End_Field__c != null) {
				strQuery+= ' AND ' + cs.End_Field__c + ' < :dteFuture ';
			}
							
			// TODO:  Talk to Matt about parsing this stuff out for complicated WHERE statements
			if(cs.SOQL_Where__c != null) {
				strQuery+= ' AND ' + cs.SOQL_Where__c;
			}

			for(sObject so : Database.Query(strQuery)) {

				Map<String,Object> fieldsMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(so));
				System.Debug(fieldsMap);

				hClsEvent clsE = new hClsEvent();
				clsE.dtmStart = (Datetime)so.get(cs.Start_Field__c);
				clsE.dtmEnd = (Datetime)so.get(cs.End_Field__c);
				clsE.strId = (String)so.get('Id');
				clsE.strTitle = (String)so.get(cs.Subject_Field__c);

				clsSource.strBGCOLOR = cs.Background_Color__c;
				clsSource.strCOLOR = cs.Text_Color__c;

				List<hClsEventDetail> lstDetail = new List<hClsEventDetail>();
				for(String str : cs.SOQL_Select__c.split(',')) {
					String strName = str.trim();
					if(mapLabels.containsKey(strName.toLowerCase()) && strName.toLowerCase() != 'id') {
						lstDetail.add(
							new hClsEventDetail(mapLabels.get(strName.toLowerCase()), so.get(strName))
						);
					}
				}

				clsE.lstData = lstDetail;
				lstEvents.add(clsE);
			}

			// Add Event List to Source Wrapper
			clsSource.lstEvents = lstEvents;
			lstReturn.add(clsSource);
		}

		return lstReturn;

	}
	
	///////////////////////////
	// Inner / Helper Classes
	///////////////////////////
	public class hClsSource {
		public String strSourceId {get;set;}
		public String strName {get;set;}
		public String strBGCOLOR {get;set;}
		public String strCOLOR {get;set;}
		public List<hClsEvent> lstEvents {get;set;}
	}

	public class hClsEvent {
		public Datetime dtmStart {get;set;}
		public Datetime dtmEnd {get;set;}
		public String strId {get;set;}
		public String strTitle {get;set;}
		public List<hClsEventDetail> lstData {get;set;}
		public hClsEvent() { }
	}

	public class hClsEventDetail {
		public String strField {get;set;}
		public Object strData {get;set;}
		public hClsEventDetail(String passField, Object passData) {
			strField = passField;
			strData = passData;
		}
	}
}