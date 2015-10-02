@RestResource(urlMapping='/webprocessor/*')
global with sharing class WS_WebProcessor {

/**
*   {Purpose}  	-  	REST Webservice for other systems to consume
*
*	{Input}		- 	JSON, strict to wsRequest class
*
*	{Output}	-	JSON, strict from wsResponse class - no other outputs are
*					sent.
*
*   {Contact}   - 	techman97@gmail.com
*                 	andyboettcher.com
*					Twitter @andyboettcher                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   20150827    Andy Boettcher		    Created
*   =============================================================================
*/
	global static RestResponse resp;
	global static wsRequest reqBody;
	global static Boolean bolProcessedAction = false;
	global static String strMessageDetail = '';

	///////////////////////////////
	// HTTP ACTIONS
	///////////////////////////////
	@HttpPost
	global static void actionRouter() {

		RestRequest req = RestContext.request;
		resp = RestContext.response;
		resp.statusCode = 200;
		resp.addHeader('Content-Type', 'application/json');

		// Process Request Body
		try {
			reqBody = (WS_WebProcessor.wsRequest)JSON.deserializeStrict(RestContext.request.requestBody.toString(), 
				WS_WebProcessor.wsRequest.class);

			// Route Actions
			System.Debug('actionRouter - REQUESTED ACTION = ' + reqBody.actionName);

			// Because Salesforce does not yet handle REST OPTIONS, we employ a manual router based on ACTION
			if(reqBody.actionName == 'createAccount') { createAccount(); }
			if(reqBody.actionName == 'updateAccount') { updateAccount(); }

			// Process a positive result
			if(bolProcessedAction) {
				processResponse(true, 0, reqBody.actionName, strMessageDetail);
			}

		} catch(JSONException exJSON) {
			processResponse(false, 1000, null, exJSON.getMessage());
		} catch(Exception ex) {
			processResponse(false, 9999, null, ex.getMessage());
		}

	}

	///////////////////////////////
	// Worker Methods
	///////////////////////////////
	private static void createAccount() {

		// Check Required Data
		if(reqBody.objAccount == null) {
			processResponse(false, 1002, reqBody.actionName, null);
			return;
		}

		// Insert Account
		try {
			// Bring in variable
			Account objAccount = reqBody.objAccount;

			// Attempt DML
			insert objAccount;

			// Take Id and return to the requestor
			strMessageDetail = objAccount.Id;

			// Result is good, proceed.
			bolProcessedAction = true;

		} catch(Exception ex) {
			processResponse(false, 9999, reqBody.actionName, ex.getMessage());
		}
	}

	private static void updateAccount() {

		// Check Required Data
		if(reqBody.objAccount == null) {
			processResponse(false, 1002, reqBody.actionName, null);
			return;
		}

		// Insert Account
		try {
			// Bring in variable
			Account objAccount = reqBody.objAccount;

			// Attempt DML
			update objAccount;

			// Take Id and return to the requestor
			strMessageDetail = objAccount.Id;

			// Result is good, proceed.
			bolProcessedAction = true;
			
		} catch(Exception ex) {
			processResponse(false, 9999, reqBody.actionName, ex.getMessage());
		}
	}

	////////////////////////////////
	// Helper Methods
	////////////////////////////////

	private static void processResponse(Boolean bolSuccess, Integer intErrorCode, String strActionName, String strDetail) {

		System.Debug('PROCESS RESPONSE - Code = ' + intErrorCode + ', Success = ' + bolSuccess + ', Message = ' + strDetail);

		resp.responseBody = blob.valueOf(JSON.serialize(new wsResponse(bolSuccess, intErrorCode, strActionName, strDetail)));
		bolProcessedAction = bolSuccess;
	}

	private static Map<Integer, String> STATUS_RESTSERVICE() {
        Map<Integer, String> mapStatusCodes = new Map<Integer, String>();
        mapStatusCodes.put(0, 'OPERATION_COMPLETED_SUCCESSFULLY');
        // Data and Processing Errors
        mapStatusCodes.put(1000, 'INPUT_JSON_STRUCTURE_ERROR_FOR_THIS_ACTION');
        mapStatusCodes.put(1001, 'MISSING_REQUIRED_ACTION');
        mapStatusCodes.put(1002, 'MISSING_REQUIRED_DATA');
        mapStatusCodes.put(1003, 'INVALID_ACTION');
        mapStatusCodes.put(1004, 'INVALID_OR_INCORRECTLY_STRUCTURED_REQUIRED_DATA');
        mapStatusCodes.put(1005, 'INVALID_OR_INCORRECTLY_STRUCTURED_OPTIONAL_DATA');
        // Exceptions and Acts of Flying Spaghetti Monster
        mapStatusCodes.put(9999, 'CAUGHT_EXCEPTION_IN_WEBPROCESSOR_CONTACT_ADMINISTRATOR');
        return mapStatusCodes;
    }

	////////////////////////////////
	// Inner Classes / Input-Output
	// Definitions
	////////////////////////////////
	global class wsResponse {

		public Boolean status {get;set;}
		public string errorCode {get;set;}
		public string message {get;set;}
		public string messageDetail {get;set;}
		public string requestedAction {get;set;}

		public wsResponse(Boolean passStatus, Integer passErrorCode, String passAction, String passMessageDetail) {
			Map<Integer, String> mapStatusCodes = STATUS_RESTSERVICE();
			status = passStatus;
			errorCode = string.valueOf(passErrorCode);
			message = mapStatusCodes.get(passErrorCode);
			requestedAction = passAction;
			messageDetail = passMessageDetail;
		}

   	}

   	global class wsRequest {

		public string actionName {get;set;}
		public Account objAccount {get;set;}

		public wsRequest() { }

	}
}