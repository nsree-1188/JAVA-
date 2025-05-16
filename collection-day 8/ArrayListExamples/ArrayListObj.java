
import java.util.*;

class Person {
    String name;
    int age;

    Person(String name, int age) {
        this.name = name;
        this.age = age;
    }

    
    public String getName() {
        return name;
    }

    public void setAge(int age) {
        this.age = age;
    }

    
}

public class ArrayListObj {
    public static void main(String[] args) {
        Person p1 = new Person("Aditya", 19);
        Person p2 = new Person("Shivam", 19);
        Person p3 = new Person("Anuj", 15);

        ArrayList<Person> names = new ArrayList<>();
        names.add(p1);
        names.add(p2);
        names.add(p3);

        for (Person p : names) {
            if (p.getName().equals("Anuj")) {
                p.setAge(26);
            }
        }

        System.out.println(names.get(0).name);
        System.out.println(names.get(0).age);
        System.out.println(names.get(1).name);
        System.out.println(names.get(1).age);
        System.out.println(names.get(2).name);
        System.out.println(names.get(2).age);
       //System.out.println(names);  
    }
}
