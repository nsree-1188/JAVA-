import java.util.ArrayList;
import java.util.Iterator;

class ArrayListIterator {
  public static void main(String[] args){
    ArrayList<String> languages = new ArrayList<>();
    languages.add("Java");
    languages.add("Python");
    languages.add("JavaScript");
    languages.add("Swift");

    Iterator<String> iterate = languages.iterator();
    System.out.print("ArrayList: ");
    
    while(iterate.hasNext()){
      String element = iterate.next();
      System.out.print(element);
    }
  }
}