class counter
{
    int count;
    public synchronized void increment()
    {
        count++;
    }
    public void display()
    {
        System.out.print("count"+count);
    }
}
public class SyncDemo1
{
    public static void main(String args[])
    {
        counter c=new counter();
        Thread t1=new Thread (new Runnable(){
            public void run()
            {
                for(int i=0;i<10;i++)
                {
                    c.increment();
            c.display();
                }
            }
        });
        t1.start();
       // System.out.print("count"+c.count);
       Thread t2=new Thread (new Runnable(){
            public void run()
            {
                for(int i=0;i<10;i++)
                {
                    c.increment();
            c.display();
                }
            }
        });
        t2.start();
    }
}