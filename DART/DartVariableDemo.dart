void main() {
  String? f;
  f ??= "Mango";
  print("Fav: $f"); 
  int? l = f?.length;
  print("Len: $l"); 
  String? b;
  String d = b ?? f;
  print("Display: $d"); 
  var buffer = StringBuffer();
  buffer.write('Hello ');
  buffer.write('world!');
  buffer.write('\n');
  print(buffer.toString());
  dynamic item = "Mango";
  if (item is String) 
  {
    String fruit = item as String;
    print("Fruit in uppercase: ${fruit.toUpperCase()}");
  }
  if (item is! int)
   {
    print("It's not a number.");
  }

}
