class DemoThread4
{
    public static void main(String args[]) throws Exception 
    {
        Sample obj1=new Sample();
        Sample obj2=new Sample();
        Sample obj3=new Sample();
        obj1.start();
        obj1.join();
        obj2.start();
        obj2.join();
        obj3.start();
    }
}
class Sample extends Thread
{
    //Thread t1=new Thread(this);
    public void run(){
        for(int i=0;i<100;i++)
        {
            System.out.println(i);
        }
    }
    
}