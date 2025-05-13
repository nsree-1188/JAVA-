class Z
{
    
}


class A implements Runnable
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
class B implements Runnable
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
public class DemoRunnable
{
    public static void main(String args[])
    {
    Runnable obj1=new A();
    Runnable obj2=new B();
        
    Thread T1=new Thread(obj1)  ;  
    Thread T2=new Thread(obj2)  ;  
        T1.start();
        T2.start();
    }
}