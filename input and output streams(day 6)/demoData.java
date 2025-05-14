import java.io.*;

class DemoData {
    public static void main(String[] args) {
        try {
            // Writing data to the file
            FileOutputStream fout = new FileOutputStream("nithya.txt");
            DataOutputStream dout = new DataOutputStream(fout);
            dout.writeInt(2);
            dout.close();
            fout.close();

            // Reading data from the file
            FileInputStream fin = new FileInputStream("nithya.txt");
            DataInputStream din = new DataInputStream(fin);
            int data = din.readInt();
            System.out.println(data);
            din.close();
            fin.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
