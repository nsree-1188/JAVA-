class sample extends Thread

{

   Thread t=new Thread(this);

    public void run()

	{

	  t.setName("Child thread");

	  System.out.println("Name of the thread\t"+t.getName());	

	 System.out.println(t.getPriority());
	  //System.out.println("y");

	}

}
 
 
class demothread2

{

    public static void main(String ads[])

	{

	    new sample().start();

	    Thread t1=Thread.currentThread();

	    t1.setName("Main thread");

	    System.out.println(t1.getName());

	    System.out.println(t1.getPriority());

	}

}
 