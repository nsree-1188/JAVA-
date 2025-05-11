interface A {
     int add(int a,int b);
}

interface B {
    double add(double a, double b,double c);
}


class MyClass implements A, B {
    @Override
    public int add(int a,int b) {
       
       return a+b;
    }

    @Override
    public double add(double a, double b,double c) {
       return a+b+c;
    }
}
public class Main{
    public static void main(String args[]){
        MyClass obj=new MyClass();
       System.out.println(obj.add(1,1));
       System.out.println(obj.add(1,1,1));
    }
}