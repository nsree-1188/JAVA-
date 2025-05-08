abstract class Scan {
    abstract void print();
     void display(){
         System.out.print("hi");
     }
}


class R extends Scan{
    @Override
    void print() {
        System.out.println("printing...");
    }

    @Override
    void display() {
        System.out.println("displaying");
    }
}


public class Main {
    public static void main(String[] args) {
        Scan r = new R();//it calls everything from the parent class and override class in the parent class
        r.print();   
        r.display();  
    }
}