void main() {
  List<String> fruits = ['Apple', 'Mango', 'Banana'];

  fruits.forEach((fruit) {
    print('Fruit is $fruit');
  });

   List<String> fruits1 = ['Apple', 'Mango', 'Banana'];

  for (var fruit in fruits1) {
    print('Fruit is $fruit');
  }
  List<String> fruits2 = ['Apple', 'Mango', 'Banana'];

  for (int i = 0; i < fruits2.length; i++) {
    print('Fruit at index $i is ${fruits2[i]}');
  }
}
