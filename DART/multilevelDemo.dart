class Person {
  String? name;
  String? age;
  String? city;

  Person(String name, String age, String city) {
    this.name = name;
    this.age = age;
    this.city = city;
  }
}

class Student extends Person {
  String? department;

  Student(String name, String age, String city, String department): super(name, age, city) {
    this.department = department;
  }
}

class Graduate extends Student {
  String? degree;

  Graduate(String name, String age, String city, String department, String degree):super(name, age, city, department) {
    this.degree = degree;
  }

  void display() {
    print('Name: $name, Age: $age, City: $city, Department: $department, Degree: $degree');
  }
}

void main() {
  Graduate g1 = Graduate("Nithya", "21", "CBE", "SCI", "BSc");
  g1.display();
}
