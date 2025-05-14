
import java.io.*;
import java.io.Serializable;
class Student implements Serializable {
    String name;
    String city;

    Student(String name, String city) {
        this.name = name;
        this.city = city;
    }
}

class DemoObj {
    public static void main(String[] args) throws Exception {
        Student s1 = new Student("Nithya", "Udumalpet");

        try (FileOutputStream fout = new FileOutputStream("Data.txt");
             ObjectOutputStream os = new ObjectOutputStream(fout)) {

            os.writeObject(s1);
            System.out.println("Object has been serialized and written to Data.txt");
            os.close();
            ObjectInputStream ois=new ObjectInputStream(new FileInputStream("Data.txt"));
           // System.out.print(ois.readObject());
            Student s2=(Student)ois.readObject();
            System.out.print(s2.name+" reside in "+s2.city);

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
