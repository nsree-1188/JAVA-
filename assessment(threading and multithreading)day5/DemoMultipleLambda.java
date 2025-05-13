class DemoMultipleLambda
{
    public static void main(String args[]) throws Exception
    {
        new Thread(){
            public void run()
    {
       
        for(int i=0;i<5;i++)
        System.out.println("hello");
     
        
    }
            
        }.start();
        
    
        new Thread(){
            public void run()
    {
        
        for(int i=0;i<5;i++)
        System.out.println("hi");
        
       
        
    }
            
        }.start();
        
    }
}