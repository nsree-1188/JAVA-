public class StringMethods {
    public static void main(String[] args) {
        String str = "Hello, World!";

    
        int length = str.length();
        System.out.println(length); 
        
        char charAtIndex = str.charAt(0);
        System.out.println(charAtIndex); 

        String substring = str.substring(7, 12);
        System.out.println(substring);

        
        String upperCase = str.toUpperCase();
        System.out.println(upperCase); 

    
        String lowerCase = str.toLowerCase();
        System.out.println("Lowercase: " + lowerCase); 

        int indexOfComma = str.indexOf(',');
        System.out.println(indexOfComma); 

        int lastIndexOfL = str.lastIndexOf('l');
        System.out.println(lastIndexOfL);
      
        
        String str2 = " How are you?";
        String concatenatedString = str.concat(str2);
        System.out.println(concatenatedString); 

        
        boolean isEqual = str.equals("Hello, World!");
        System.out.println(isEqual); 

       
        boolean isEqualIgnoreCase = str.equalsIgnoreCase("hello, world!");
        System.out.println(isEqualIgnoreCase);

        boolean startsWithHello = str.startsWith("Hello");
        System.out.println(startsWithHello); 

       
        boolean endsWithExclamation = str.endsWith("!");
        System.out.println("Ends with '!'? " + endsWithExclamation); 

       
        String replacedString = str.replace('o', 'x');
        System.out.println("Replaced 'o' with 'x': " + replacedString); 

       
        String stringWithWhitespace = "   Hello   ";
        String trimmedString = stringWithWhitespace.trim();
        System.out.println("Trimmed string: " + trimmedString); 
      
        
        String emptyString = "";
        String notEmptyString = "not empty";
        System.out.println("Is emptyString empty? " + emptyString.isEmpty()); 
        System.out.println("Is notEmptyString empty? " + notEmptyString.isEmpty()); 
      
        
        String[] parts = str.split(",");
        System.out.println("Parts after splitting by ',':");
        for (String part : parts) {
            System.out.println(part.trim());
        }
        
    }
}


/*String is a class, and strings in Java are treated as an object, hence the object of String class will be stored in Heap, not in the stack area.


string objects in two ways i.e 

    By string literal 
    By using the 'new' keyword 
	
By the use of 'new' keyword, the JVM will create a new string object in the normal heap area even if the same string object present in the string pool. 
	
	
	   
All objects in Java are stored in the heap. The reference variable to the object stored in the stack area or they can be contained in other objects which puts them in the heap area also.

The string is passed by reference by java.
	
A string reference variable is not a reference itself. It is a variable that stores a reference (memory address).*\