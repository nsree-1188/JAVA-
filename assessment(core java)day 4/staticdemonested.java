*******************************************************************************/
class Doctor
{
    String name;
    String department;
    int age;
 
     static class Patient
    {
        String nameofpatient;
        int patient_age;
 
        public void displayPatient(String nameofpatient,int patient_age)
        {
            this.nameofpatient=nameofpatient;
            this.patient_age=patient_age;
 
            System.out.println("Name of the patient"+nameofpatient);
            System.out.println("patient_age"+patient_age);
        }
        public void display(){
            System.out.print("age"+patient_age);
        }
    }
}
 
class demostaticnested
 {
      public static void main(String[] args) {
         Doctor.Patient obj1=new Doctor.Patient();
         //obj1.patient_age=10;
          obj1.displayPatient("jp",22);
          obj1.patient_age=10;
          obj1.display();
          
      }
 }