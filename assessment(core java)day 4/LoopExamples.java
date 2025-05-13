public class LoopExamples {
    public static void main(String[] args) {
        
        int count = 0;
      
        while (count < 3) {
            System.out.println("Count: " + count);
            count++;
        }

       
        int num = 5;
        
        do {
            System.out.println("Number: " + num);
            num--;
        } while (num > 0);
    }
}