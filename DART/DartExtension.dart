class Person {
  String? name;
  String? age;
  String? city;

  Person(this.name, this.age, this.city);
}

class Student extends Person {
  String? department;

  Student(String name, String age, String city, this.department): super(name, age, city);
}

class Graduate extends Student {
  String? degree;

  Graduate(String name, String age, String city, String department, this.degree): super(name, age, city, department);
}


extension GraduateExtension on Graduate {
  void display() {
    print('Name: $name, Age: $age, City: $city, Department: $department, Degree: $degree');
  }
}

void main() {
  Graduate g1 = Graduate("Nithya", "21", "CBE", "SCI", "BSc");
  g1.display();
}