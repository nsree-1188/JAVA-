mixin Swim {
  void run() {
    print("running");
  }

  void swimming() {
    print("swimming");
  }
}

mixin Cat {
  void sound() {
    print("meow...");
  }
}

abstract class Ant {
  void ani();
}

class Fish with Swim {
  void fun() {
    run();
  }
}

class Dog extends Fish with Swim {
  void activity() {
    print("sleep");
    swimming();
  }
}

class Animal extends Ant with Cat, Swim {
  @override
  void ani() {
    sound();
    run();
    print("catch");
  }
}

void main() {
  Fish f = Fish();
  f.fun();

  Dog d = Dog();
  d.activity();

  Animal a = Animal();
  a.ani();
}
