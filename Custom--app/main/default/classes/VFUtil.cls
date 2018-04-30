/*
 * Got tired of typing in the long version so created these shortcuts
 * In VF page, add "VFUtil.AddErrorMessage( 'This is your error');"
 *      instead of "ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'This is your error'));"
 *
 * Modifiy by Abhinav Sharma on 6/29/2013 as per SIR - D-00005899
 *  
 */
public abstract class VFUtil {
    public static void AddInfoMessage( String s) {
        ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.INFO, s));
    }

    public static void AddWarningMessage( String s) {
        ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.WARNING, s));
    }

    public static void AddConfirmMessage( String s) {
        ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.CONFIRM, s));
    }

    public static void AddErrorMessage( String s) {
        ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.ERROR, s));
    }

    public static void AddFatalMessage( String s) {
        ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.FATAL, s));
    }

    // Utility method to check for specifc page message in apex pages
    public static Boolean hasMessage( String pageMessage) {
        if ( ApexPages.hasMessages() ) {
            for ( ApexPages.Message msg : ApexPages.getMessages()) {
                if ( msg.getDetail().contains( pageMessage)) {
                    return true;
                }
            }
        }

        return false;
    }
    
    // Returns the Page parameter if present.
    public static String getPageParameter(String param) {
      if (ApexPages.currentPage().getParameters().containsKey(param)) {
        return escapeSingleQuotes(ApexPages.CurrentPage().getParameters().get(param));  //.replace('%2F', '')
      }
      return null;
    }

    public static String escapeSingleQuotes(String param) {
    String stringToReturn;
      if (param != null) stringToReturn = String.escapeSingleQuotes(param);
      return stringToReturn;
    }
}