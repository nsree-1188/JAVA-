import java.io.FilterReader;
import java.io.Reader;
import java.io.StringReader;

public class filterReaderExample {
   public static void main(String[] args) throws Exception {
      FilterReader fr = null;
      Reader r = null;
      boolean bool = false;
      
      try {
         r = new StringReader("ABCDEF");
         fr = new FilterReader(r) {
         };
         bool = fr.ready();
         System.out.println("Ready to read? "+bool);
         
      } catch(Exception e) {
         e.printStackTrace();
      } finally {
         if(r!=null)
            r.close();
         if(fr!=null)
            fr.close();
      }
   }
}
