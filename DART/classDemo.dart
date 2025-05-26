class Student {
  String? _name;
  int? _age;
  int? _f;

  Student() {
    _name = "shivani";
    _age = 20;
    _f = 3;
  }

  Student.parameterized({String? name, int? age, int? f}) {
    _name = name;
    _age = age;
    _f = f;
    print("Sum in constructor: ${_age! + _f!}");
  }

  void displayStudent() {
    print("Name: $_name");
    print("Age: $_age");
    print("Sum in method: ${_age! + _f!}");
  }
}

void main() {
  Student s1 = Student();
  s1.displayStudent();

  Student s2 = Student.parameterized(name: "Nithya", age: 21, f: 3);
  s2.displayStudent();
}
