import java.io.*;
class demoBaos
{
    public static void main(String args[]) throws Exception
    {
        try{
            FileOutputStream focus1=new FileOutputStream("s1.txt");
            FileOutputStream focus2=new FileOutputStream("s2.txt");

            ByteArrayOutputStream baos=new ByteArrayOutputStream();
            String str="this is a string";
            baos.write(65);
            baos.write(str.getBytes());

            baos.writeTo(focus1);
            baos.writeTo(focus2);
           // baos.flush();
            baos.close();
        }catch(Exception e){}
        
    }
}