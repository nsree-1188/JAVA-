void add(int a, int b) 
{
  print(a + b);
}
void greet1([String? name]) 
{
  print("Hello ${name ?? 'Guest'}");
}
void greet2({String? name}) 
{
  print("Hello ${name ?? 'Guest'}");
}
void greet3({required String name}) 
{
  print("Hello $name");
}
void greet4({String name = 'Guest'}) 
{
  print("Hello $name");
}
void main() {
  add(5, 3);
  greet1();
  greet1("Alice");
  greet2();
  greet2(name: "Bob");
  greet3(name: "Charlie");
  greet4();
  greet4(name: "Daisy");
}