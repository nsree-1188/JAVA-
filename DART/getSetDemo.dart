class Student
{
String? _name="";
int? _roll=0;
String? _dept="";

void setName(String name)
{
    this._name=name;
}
void setRoll(int roll)
{
    this._roll=roll;
}
void setDept(String dept)
{
    this._dept=dept;
}
String? get getName=>_name;
int? get getRoll=>_roll;
String? get getDept=>_dept;

void display()
{
    print("Name $_name");
    print("Roll $_roll");
    print("Dept $_dept");
}
}
void main()
{
    Student s1=Student();
    s1.setName("Nithya");
    //print(s1.getName);
    s1.setName("MSD");
    s1.display();
    print(s1.getName);

}