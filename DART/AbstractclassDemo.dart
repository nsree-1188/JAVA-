import 'dart:math';
abstract class Shape 
{
    double area(); 
}
class Circle extends Shape 
{
  double radius;
  Circle(this.radius);
  @override
  double area() =>pi * pow(radius, 2);
}

void main() 
{
  Circle circle = Circle(5);
  double a= circle.area();
  print(a);
}
