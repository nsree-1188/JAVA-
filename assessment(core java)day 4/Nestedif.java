public class NestedIf{
    public static void main(String[] args) {
 
        int n=24;
 
       
        if (n % 2 == 0){
 
           
            System.out.print("Even ");
 
           
            if (n % 6 == 0) {
                
                System.out.println("and divisible by 6");
            } else {
                
                System.out.println("and not divisible by 6");
            }
        } 
else {
           
            System.out.println("Odd ");
 
            
            if(n % 3 == 0) {
                
                System.out.println("and divisible by 3");
            } else {
                
                System.out.println("and not divisible by 3");
            }
        }
 
    }
}