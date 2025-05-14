import java.io.*;

class demoBuffer{
    public static void main(String[] args) {
        try {
            // Writing data to the file
            FileOutputStream fout = new FileOutputStream("nith.txt");
            String str="this is new";
            byte str_b[]=str.getBytes();
           fout.write(str_b);
           fout.close();
            // Reading data from the file
           
        }
        catch(Exception e){}
        try{
            FileInputStream fo = new FileInputStream("nith.txt");
         BufferedInputStream fin = new BufferedInputStream(fo);
         int i=0;
         while((i=fin.read())!=-1)
         {
            System.out.print((char)i);
         }
        }catch(Exception e){}
    }
}