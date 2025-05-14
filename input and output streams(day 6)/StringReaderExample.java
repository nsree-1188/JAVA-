import java.io.*;
import java.io.IOException;
import java.io.StringReader;

public class StringReaderExample {
    public static void main(String[] args) {
        String data = "Hello, World!";
        try (StringReader reader = new StringReader(data)) {
            int charCode;
            while ((charCode = reader.read()) != -1) {
                System.out.print((char) charCode);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}