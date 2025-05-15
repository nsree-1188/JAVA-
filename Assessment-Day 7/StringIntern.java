  import java.util.*;
  public class StringIntern{
  
  public static void main(String args[]){
   String str1 = "hello";
   String str2 = new String("hello");
   String str3 = str2.intern();

   System.out.println(str1 == str2); 
   System.out.println(str1 == str3); 
  }
  }
  //checks whether already exists in a String constant pool
  