import java.util.*;

class LinkedHashMapExample {
  public static void main(String[] args) {

    
    Map<Integer, String> languages = new LinkedHashMap<>();
    languages.put(2, "Java");
    languages.put(1, "Python");
    languages.put(3, "JavaScript");
    System.out.println("HashMap: " + languages);

    
    System.out.print("Keys: ");
    for (Integer key : languages.keySet()) {
      System.out.print(key);
      System.out.print(", ");
    }

    
    for (String value : languages.values()) {
      System.out.print(value);
      System.out.print(", ");
    }
    
    
    for (Map.Entry<Integer, String> entry : languages.entrySet()) {
      System.out.print(entry);
      System.out.print(", ");
    }
  }
}