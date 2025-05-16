import java.util.Stack;

class StackEx {
    public static void main(String[] args) {
        Stack<String> animals= new Stack<>();
        animals.push("Dog");
        animals.push("Horse");
        animals.push("Cat");
        animals.poll("Dog");
        System.out.println("Stack: " + animals);
        String element = animals.peek();
        System.out.println("Element at top: " + element);
        int ani=animals.search("Horse");
        System.out.print(ani);

    }
}