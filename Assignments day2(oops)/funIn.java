@FunctionalInterface
interface MyFunctionalInterface {
    void myMethod(int a, int b);
}

public class Main {
    public static void main(String[] args) {

      new MyFunctionalInterface()
      {
          @Override
         public void myMethod(int a,int b)
          {
              System.out.print(a+b);
          }
      }.myMethod(2,3);
    }
}