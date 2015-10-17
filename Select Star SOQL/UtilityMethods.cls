public with sharing class UtilityMethods {

	public static String G_SORT_ASCENDING = 'ASC';
	public static String G_SORT_DESCENDING = 'DESC';
	
	///////////////////////////
	// GET / SET
	///////////////////////////
	public static Set<String> setAuditFields {
		get {
			setAuditFields = new Set<String>();
			setAuditFields.add('OWNERID');
			setAuditFields.add('ISDELETED');
			setAuditFields.add('CURRENCYISOCODE');
			setAuditFields.add('RECORDTYPEID');
			setAuditFields.add('CREATEDDATE');
			setAuditFields.add('CREATEDBYID');
			setAuditFields.add('LASTMODIFIEDDATE');
			setAuditFields.add('LASTMODIFIEDBYID');
			setAuditFields.add('SYSTEMMODSTAMP');
			setAuditFields.add('LASTVIEWEDDATE');
			setAuditFields.add('LASTREFERENCEDDATE');
			return setAuditFields;
		}
	}

	public static Map<String, Schema.SObjectField> mapFieldsInObject(String strObjectName) {
		return Schema.getGlobalDescribe().get(strObjectName).getDescribe().fields.getMap();
	}

	public static Map<Id, SObject> objRecordData(String strObjectName, Set<Id> setRecordIds, Set<String> setBlockedFields, Map<String, String> mapSort) {

		try {
			String strQuery = 'SELECT ';

			// Construct Dynamic SOQL Fields
			for(String strField : mapFieldsInObject(strObjectName).keyset()) {
				if(!setBlockedFields.contains(strField.toUpperCase())) {
					strQuery+= strField + ', ';
				}
			}
			strQuery = strQuery.substring(0,strQuery.length()-2);

			strQuery+= ' FROM ' + strObjectName;
			
			if(setRecordIds != null) {
				strQuery+= ' WHERE Id IN :setRecordIds';
			}
			
			if(mapSort.size() > 0) {
				strQuery+= ' ORDER BY ';
				for(String strKey : mapSort.keySet()) {
					strQuery+= strKey + ' ' + mapSort.get(strKey) + ', ';
				}
				strQuery = strQuery.substring(0,strQuery.length()-2);
			}

			if(setRecordIds == null) {
				strQuery+= ' LIMIT 50';
			}

			return new Map<Id, sObject>((List<sObject>)Database.query(strQuery));	
		} catch(Exception ex) {
			System.Debug(ex);
			return new Map<Id, sObject>();
		}
		

	}
	
	///////////////////////////
	// Action Methods
	///////////////////////////
	
	
	///////////////////////////
	// Inner / Helper Classes
	///////////////////////////
}