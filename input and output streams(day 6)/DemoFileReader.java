import java.io.*;
import java.io.Reader;

import java.io.FileReader;
class DemoFileReader{
    public static void main(String args[]) throws Exception{
    char a[]=new char[100];
    Reader rd=new FileReader("Data.txt");
    System.out.print(rd.ready());
    rd.read(a);
    System.out.print(a);
    rd.close();
}
}