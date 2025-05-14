import java.io.*;

class DemoBais {
    public static void main(String[] args)  throws Exception{
        try {
            // Create FileOutputStreams for writing to files
            FileOutputStream focus1 = new FileOutputStream("s1.txt");
            FileOutputStream focus2 = new FileOutputStream("s2.txt");

            // Create a ByteArrayOutputStream
            ByteArrayOutputStream baos = new ByteArrayOutputStream();

            // Write data to the ByteArrayOutputStream
            String str = "this is a string";
            baos.write(65); // Writes the byte value 65 (ASCII for 'A')
            baos.write(str.getBytes()); // Writes the bytes of the string

            // Write the content of ByteArrayOutputStream to both files
            baos.writeTo(focus1);
            baos.writeTo(focus2);

            // Convert ByteArrayOutputStream to byte array
            byte[] byteArray = baos.toByteArray();

            // Create a ByteArrayInputStream from the byte array
            ByteArrayInputStream bais = new ByteArrayInputStream(byteArray);

            // Read and print the content from ByteArrayInputStream
            int data;
            while ((data = bais.read()) != -1) {
                System.out.print((char) data);
            }
            System.out.println();

            // Close all streams
            baos.close();
            focus1.close();
            focus2.close();
            bais.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
