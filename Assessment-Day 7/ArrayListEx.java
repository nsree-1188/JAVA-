import java.util.ArrayList;

class ArrayListEx {
  public static void main(String[] args) {

   
    ArrayList<String> animals = new ArrayList<>();
    animals.add("Cow");
    animals.add("Cat");
    animals.add("Dog");
    animals.remove("Cat");
    animals.set(1,"Elephant");
    System.out.println("ArrayList: " + animals);

   
    System.out.println("Accessing individual elements:  ");

    for (String language : animals) {
      System.out.print(language);
      System.out.print(", ");
    }
  }
}