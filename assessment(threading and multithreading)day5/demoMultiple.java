class A extends Thread
{
    public void run()
    {
        try{
        for(int i=0;i<5;i++)
        System.out.println("hi");
        }
        catch(Exception e){}
        
    }
}
class B extends Thread
{
    public void run()
    {
        try{
        for(int i=0;i<5;i++)
        System.out.println("hello");
        }
        catch(Exception e){}
        
    }
}
class DemoMultiple
{
    public static void main(String args[]) throws Exception
    {
        A obj1=new A();
        B obj2=new B();
        obj1.start();
        obj1.join();
        obj2.start();
    }
}