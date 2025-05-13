class callme
{
   synchronized  public void call(String msg)
	{
	   System.out.print("[");
	   System.out.print(msg);
	   System.out.println("]");
	   this.display();
	}
 
     public void display()
	{
	  for(int i=0;i<10;i++)
		{
		  System.out.print(i);
		}
	}
}
 
 
class caller extends Thread
{
   Thread t=new Thread(this);
   callme targ;
   String msg;
 
     caller(callme targ,String msg)
	{
	  this.msg=msg;
	  this.targ=targ;
	  t.start();
	}
 
     @Override
     public void run()
	{
	  targ.call(msg);
	}
}
 
 
class sync
{
    public static void main(String asd[]) throws Exception
	{
	   callme c=new callme();
	   caller obj1=new caller(c,"welcome");
	   caller obj2=new caller(c,"to");
	   caller obj3=new caller(c,"iexceed");
 
	}
}