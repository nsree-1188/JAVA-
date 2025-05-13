public class DemoRunnableLambda
{
    public static void main(String args[])
    {
    Runnable obj1=new Runnable(){
        

    public void run()
    {
        for(int i=0;i<5;i++)
        {
            System.out.print("hi");
            try 
               { Thread.sleep(10);}catch(InterruptedException e) {}
        }
    }

    };
    Runnable obj2=new Runnable(){
        
    public void run()
    {
        for(int i=0;i<5;i++)
        {
            System.out.print("hello");
            try 
               { Thread.sleep(10);}catch(InterruptedException e) {}
        }
    }

    };
    
        
    Thread T1=new Thread(obj1)  ;  
    Thread T2=new Thread(obj2)  ;  
        T1.start();
        T2.start();
    }
}