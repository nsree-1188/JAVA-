import hospital.Doctor;
 
 public class Patient extends Doctor
{
  public String pname,city;
  public int P_age;
 
   public Patient(String name,int age,String department,String pname,int P_age,String city)
	{
	   super(name,age,department);
	   
	  this.pname=pname;
	  this.P_age=P_age;
	  this.city=city;
	}
 
   public void displayPatient()
	{
	   super.displayDoc();
	   System.out.println("pName="+pname);
	   System.out.println("pAge="+P_age);
	   System.out.println("pCity="+city);
	}
 

 

    public static void main(String asd[])
	{
	      Patient obj=new Patient("prabhu",21,"cardio","Ram",32,"Banglore");
	      obj.displayPatient();
	      
	}
}
