/**
 *   Description  :  Class contianing methods to create signature services for IH Integration
 *
 *   Created By Shrinath
 *
 *   Created Date:  07/11/2013
 *
 *   Revision Logs:  V1.0 - Created
 **/
public with sharing class IHSignatureService {

    //create signature
    public static String getCloudbeesSignature(String endPointUrl, String secret){

        String algorithmName = 'HMacSHA1';
        Blob mac = Crypto.generateMac(algorithmName,  Blob.valueOf(endPointUrl),Blob.valueOf(secret));
        String macUrl = EncodingUtil.base64Encode(mac);
        return macUrl;
    }

    //create signature
    public static String getS3Signature(String stringToSign, String secret){

        String algorithmName = 'HMacSHA1';
        Blob mac = Crypto.generateMac( algorithmName,  Blob.valueOf(stringToSign), Blob.valueOf(secret) );
        String signature = EncodingUtil.base64Encode(mac);
        return signature;

    }
}