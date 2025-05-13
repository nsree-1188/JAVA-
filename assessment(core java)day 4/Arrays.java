import java.util.*;
 public class Arrays
{
    public static void main(String[] args) 
    {
        Scanner sc=new Scanner(System.in);
        int a=sc.nextInt();
        int a1[]=new int[a];
        for(int i=0;i<a;i++)
        {
            a1[i]=sc.nextInt();
        }
        for(int i=0;i<a;i++)
        {
            if(a1[i]%2==0)
            {
                a1[i]=0;
            }
            else
            {
                a1[i]=1;
            }
        }
        for(int i=0;i<a;i++)
        System.out.print(a1[i]+" ");
    }
}
