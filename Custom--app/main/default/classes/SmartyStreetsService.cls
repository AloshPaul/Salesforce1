public without sharing class SmartyStreetsService {

    public static String END_POINT = 'https://api.smartystreets.com/street-address';
    //Inner class to hold the validate address request object
    public class ValidateAddressRequest {

        //properties
        public Id recordId;
        public String street;
        public String city;
        public String state;
        public String zipcode;

        //Constructor
        public ValidateAddressRequest(Id recordId, String street, String city, String state, String zipcode) {

            //Assign into properties
            this.recordId = recordId;
            this.street = street;
            this.city = city;
            this.state = state;
            this.zipcode = zipcode;
        }
    }

    //Inner class to hold the validate address request object
    public class ValidateAddressResponse {

        //properties
        public Id recordId;
        public Boolean validateSuccess;
        public String errorMessage;
        public String street;
        public String city;
        public String state;
        public String zip;
        public String zipPlus4;
        public Double latitude;
        public Double longitude;
        public String county;
    }

    //Method for HTTP Request for getting response from SmartyStreet Side
    public static List<ValidateAddressResponse> doValidate(List<ValidateAddressRequest> requests) {

        //Create a list of Response to hold
        List<ValidateAddressResponse> response = new ValidateAddressResponse[requests.size()];


        //Get Custom Setting data
        SmartyStreets_Configuration__c config = Constants.SMARTY_STREETS_CONFIGURATION;

        //Create a HTTP request and set the desired values
        HttpRequest request = new HttpRequest();
        //Sekar - details
        //request.setEndPoint(END_POINT + '?auth-id=5bd24ddf-56c3-fcc6-e946-4627f4e12b93&auth-token=3d3ICV6LwofdjnkWFzfQ');
        //Deepish - details q
        //request.setEndPoint(END_POINT + '?auth-id=67abc345-db77-15a7-e72e-590754e60355&auth-token=Ly52MrMp6Eg5jDs6ZfV7');
        request.setEndPoint(END_POINT + '?auth-id=' + config.Auth_Id__c + '&auth-token=' + config.Auth_Token__c);
        request.setMethod('POST');
        request.setBody(JSON.serialize(requests));
        System.debug('Request looks like ' + request);

        //HTTP class instance
        Http http = new Http();
        HTTPResponse httpResponse = http.send(request);
        if(httpResponse.getStatusCode() == 200){
            //Getting body of Response
            String body = httpResponse.getBody();
            System.debug('The response body looks like ' + body);
            //Invoke JSON Parser
            List<SmartyStreetResponse> deserializedList = (List<SmartyStreetResponse>)JSON.deserialize(body, List<SmartyStreetResponse>.class);

            //Create a set to hold the list of validate address Index
            Set<Integer> validatedIndex = new Set<Integer>();

            //Loop thorugh the validated address
            for(SmartyStreetResponse sSR : deserializedList) {

                //Create a new instance of response
                ValidateAddressResponse res = new ValidateAddressResponse();

                //Get the Index
                Integer input_index = sSR.input_index;
                validatedIndex.add(input_index);

                //Populate response
                res.recordId = requests[input_index].recordId;
                res.validateSuccess = true;
                res.errorMessage = '';
                res.street = prepareStreetData(sSR.Components);
                res.city = sSR.Components.city_name;
                res.state = sSR.Components.state_abbreviation;
                res.zip = sSR.Components.zipcode;
                res.zipPlus4 = sSR.Components.plus4_code;
                res.latitude = sSR.Metadata.latitude != null? Double.valueOf(sSR.Metadata.latitude):null;
                res.longitude = sSR.Metadata.longitude != null? Double.valueOf(sSR.Metadata.longitude):null;
                res.county  = sSR.Metadata.county_name;

                //Add recoponse in list to be returned
                response[input_index] = res;
            }

            //Loop though the remaing request record
            for(Integer i = 0; i < requests.size(); i++) {

                //Check if address has not been validated for i request
                if(!validatedIndex.contains(i)) {

                    //Add in response with failure response
                    //Create a new instance of response
                    ValidateAddressResponse res = new ValidateAddressResponse();

                    //Populate response
                    res.recordId = requests[i].recordId;
                    res.validateSuccess = false;
                    res.errorMessage = Label.ERROR_ADDRESS_NOT_FOUND;

                    //Add recoponse in list to be returned
                    response[i] = res;
                }
            }
        }

        //return response
        return response;
    }
/*
    //This method is to parse response of SmartyStreets and if this is sandbox simply return the request address as validated address
    public List<ValidateAddressResponse> doValidateForSandbox(List<ValidateAddressRequest> requests) {

        //Create a list of Response to hold
        List<ValidateAddressResponse> response = new ValidateAddressResponse[requests.size()];

        //Loop though the remaing request record
        for(Integer i = 0; i < requests.size(); i++) {

            //Add in response with failure response
            //Create a new instance of response
            ValidateAddressResponse res = new ValidateAddressResponse();

            //Populate response
            res.recordId = requests[i].recordId;
            res.validateSuccess = true;
            res.errorMessage = '';
            res.street = requests[i].street;
            res.city = requests[i].city;
            res.state = requests[i].state;
            res.zip = requests[i].zipcode;

            //Add recoponse in list to be returned
            response[i] = res;
        }

        //return response
        return response;
    }

*/

    //This class is to hold the Samrty Street response
    public class SmartyStreetResponse {

        //Variables
        public Integer input_index;
        public SmartyStreetsService.Components Components;
        public SmartyStreetsService.MetaData MetaData;
        public SmartyStreetsService.Analysis Analysis;
    }

    //Class for holding variable for Components (START_ELEMENT)
    public class Components {
        public String primary_number {get; set;}
        public String street_preDirection {get; set;}
        public String street_name {get; set;}
        public String street_suffix {get; set;}
        public String city_name {get; set;}
        public String state_abbreviation {get; set;}
        public String zipcode {get; set;}
        public String plus4_code {get; set;}
        public String delievery_point {get; set;}
        public String delivery_point_check_digit {get; set;}
    }

    //Class for holding variable for Metadata (START_ELEMENT)
    public class MetaData {
        public String record_type {get; set;}
        public String county_name {get; set;}
        public String carrier_route {get; set;}
        public String congressional_district {get; set;}
        public String rdi {get; set;}
        public String latitude {get; set;}
        public String longitude {get; set;}
        public String precision {get; set;}
    }

    //Class for holding variable for Analysis (START_ELEMENT)
    public class Analysis {
        public String dpv_match_code {get; set;}
        public String dpv_footnotes {get; set;}
        public String dpv_cmra {get; set;}
        public String dpv_vacant {get; set;}
        public String active {get; set;}
        public String footnotes {get; set;}
    }

    //This method is to prepare stree data based on the Smarty Street response
    public static String prepareStreetData(Components components) {

        //Check for the Street Value
        String street = '';

        //Process Samrty street response and prepare
        if(components.primary_number != null)
            street += components.primary_number + ' ';
        if(components.street_preDirection != null)
            street += components.street_preDirection + ' ';
        if(components.street_name != null)
            street += components.street_name + ' ';
        if(components.street_suffix != null)
            street += components.street_suffix + ' ';

        return street;
    }

}