class Fruit {
  final String name;
  Fruit(this.name);
}

void main() {
  var apple = Fruit("Apple");
  print(apple.name);  
}
//Assigned only once
//Value is decided at runtime
//Different instances can have different values