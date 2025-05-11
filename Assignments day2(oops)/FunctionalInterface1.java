@FunctionalInterface
interface MyFunctionalInterface 
{
    void myMethod(int a, int b);
}

public class Main 
{
    public static void main(String[] args) 
	{
        
        MyFunctionalInterface add = (a, b) -> System.out.println(a + b);
        add.myMethod(5, 3);
    }
}