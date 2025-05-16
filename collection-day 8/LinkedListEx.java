import java.util.*;

public class LinkedListEx {
    public static void main(String[] args) {
        LinkedList<String> linkedList = new LinkedList<>();
        linkedList.add("Apple");
        linkedList.add("Banana");
        linkedList.add("Cherry");
        linkedList.addFirst("Mango"); 
        linkedList.addLast("Grapes"); 
        linkedList.add(2, "Orange"); 
        System.out.println("LinkedList: " + linkedList);
        System.out.println("First element: " + linkedList.getFirst());
        System.out.println("Last element: " + linkedList.getLast());
        System.out.println("Element at index 2: " + linkedList.get(2));
        linkedList.set(1, "Strawberry");
        System.out.println(linkedList);
        linkedList.removeFirst();
        System.out.println(linkedList);
        linkedList.removeLast();
        System.out.println(linkedList);
        linkedList.remove("Orange");
        System.out.println(linkedList);
        linkedList.remove(1);
        System.out.println(linkedList);
        System.out.println(linkedList.contains("Banana"));
        System.out.println(linkedList.indexOf("Cherry"));
        System.out.println(linkedList.size());
        linkedList.clear();
        System.out.println(linkedList);
        System.out.println(linkedList.isEmpty());
    }
}