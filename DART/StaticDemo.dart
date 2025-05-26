class Fruit {
  static int count = 0;
  Fruit() {
    count++;
  }
}

void main() {
  Fruit();
  Fruit();
  print(Fruit.count); 
}
/*Shared across all instances of a class
Used with either final or const usually