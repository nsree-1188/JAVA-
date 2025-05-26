class Person {
  String? name;
  int? age;
  String? city;

  Person(String name, int age, String city) {
    this.name = name;
    this.age = age;
    this.city = city;
  }
}

class Student extends Person {
  String? department;

  Student(String name, int age, String city, String department): super(name, age, city) {
    this.department = department;
  }

  void display() {
    print('Name: $name, Age: $age, City: $city, Department: $department');
  }
}

void main() {
  Student s1 = Student("Nithya", 21, "CBE", "SCI");
  s1.display();
}
