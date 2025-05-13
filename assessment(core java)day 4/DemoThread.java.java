class A extends Thread
{
    public void run()
    {
        for(int i=0;i<100;i++)
        {
            System.out.print("hi");
            try {
                Thread.sleep(10);
            } 
            catch(InterruptedException e) 
            {
                e.printStackTrace();
            }
        }
    }
}
class B extends Thread
{
    public void run()
    {
        for(int i=0;i<100;i++)
        {
            System.out.print("hello");
            try {
                Thread.sleep(10);
            } 
            catch(InterruptedException e) 
            {
                e.printStackTrace();
            }
        }
    }
}
public class DemoThread
{
    public static void main(String args[])
    {
        A obj1=new A();
        B obj2=new B();
        
        obj1.start();
        obj2.start();
    }
}