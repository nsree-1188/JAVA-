interface one
 {
    public void display();
 }
 
 interface two extends one
  {
    public void display1();
  }
 
  class demo implements two
  {
    public void display(){System.out.println("display");}
    public void display1(){System.out.println("display1");}
  }
 
  class demointerface1
  {
    public static void main(String[] args) {
        demo ob=new demo();
        ob.display();
        ob.display1();
    }
  }