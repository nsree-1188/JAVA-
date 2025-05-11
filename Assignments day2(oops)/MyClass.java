
class MyClass {
    static int count = 0; 

    public MyClass() {
        count=count+1;
		System.out.print(count);
    }



    public static void main(String[] args) {
        MyClass obj1 = new MyClass();
        MyClass obj2 = new MyClass();
		
       
	}
}