class Doctor {
    String name;
    String department;

    Doctor(String name, String department) {
        this.name = name;
        this.department = department;
    }

    public void showDoctor() {
        System.out.println("Doctor Name: " + name);
        System.out.println("Department: " + department);
    }
}

class Patient {
    String name;
    Doctor doc;

    Patient(String name) {
        this.name = name;
        
    }

    public void showPatient() {
        System.out.println("Patient Name: " + name);
        
    }
}
class Diagonosis
{
    String disease;
    Doctor doc;
    Patient p;
    Diagonosis(String disease,Doctor doc,Patient p)
    {
        this.disease=disease;
        this.doc=doc;
        this.p=p;
    }
    public void showReport()
    {
        doc.showDoctor();
        p.showPatient();
        System.out.print("disease: "+disease);
    }
}

class Main {
    public static void main(String args[]) {
        Doctor d = new Doctor("Dr. Anu", "ENT");
        Patient p = new Patient("Rahul");
        Diagonosis di=new Diagonosis("fever",d,p);
        di.showReport();
    }
}
    
