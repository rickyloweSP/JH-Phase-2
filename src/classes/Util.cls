public with sharing class Util {
	/**
     * @description Truncates a string to the required length. Used for shortening text to the field length
     * @return sting - the truncated sting 
     **/
    public static string ConcatanateStringLength(string stringIn, integer length){
        if(stringIn != null && stringIn.length() > length){
            return stringIn.left(length);
        }
        else{
            return stringIn;
        }
    }

    /**
     * @description Returns a random string
     * @return the random string 
     **/
    public static string returnRandomString(integer length){
        return ConcatanateStringLength(String.ValueOf(Math.random()).subString(2), length);
    }

    /**
     * @description increments a number. Treat null as a 0
     * @return the random string 
     **/
    public static integer incrementNumber(integer numberToIncrement){
        integer newNumber;
        if(numberToIncrement == null){
            newNumber = 1;
            return newNumber;
        }
        else{
            newNumber = numberToIncrement + 1;
            return newNumber;
        }
    }
}