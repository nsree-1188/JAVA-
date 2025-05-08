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

    Patient(String name, Doctor doc) {
        this.name = name;
        this.doc = doc;
    }

    public void showPatient() {
        System.out.println("Patient Name: " + name);
        doc.showDoctor();
    }
}

class HospitalMain {
    public static void main(String args[]) {
        Doctor d = new Doctor("Dr. Anu", "ENT");
        Patient p = new Patient("Rahul", d);
        p.showPatient();
    }
}
