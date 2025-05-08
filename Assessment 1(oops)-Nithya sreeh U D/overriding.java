class Animal {
    
    void move() 
    { 
        System.out.println( "Animal is moving."); }
    void eat() { 
        System.out.println( "Animal is eating.");
      }
}

class Dog extends Animal
{
     void move()
    { 
        System.out.println("Dog is running.");
    }
    void bark()
    {
        System.out.println("Dog is barking."); 
        
    }
}

public class Main {
    public static void main(String[] args)
    {
       Animal d = new Dog();
        d.move(); 
        d.eat(); 
        //d.bark(); 
    }
}