package hospital;
public class Doctor
{
    String name;
    int age;
    String department;
public Doctor(String name,int age,String department)
    {
     this.name=name;
	 this.age=age;
	 this.department=department;
    }
public void displayDoc()
   {
   System.out.print("Name "+name);
   System.out.print("Name "+age);
   System.out.print("Name "+department);
   }
}