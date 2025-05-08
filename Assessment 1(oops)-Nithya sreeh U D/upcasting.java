class Animal {
    void sound() {
        System.out.println("Animal makes a sound");
    }
}

class Dog extends Animal {
    void bark() {
        System.out.println("Dog barks");
    }

    @Override
    void sound() {
        System.out.println("Dog makes a sound");
    }
}

class Main {
    public static void main(String[] args) {
        Animal a = new Dog();  
        a.sound();            
       
    }
}
//
