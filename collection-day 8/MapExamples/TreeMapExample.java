import java.util.*;
class TreeMapExample {
    public static void main(String[] args) {

        TreeMap<String, Integer> numbers = new TreeMap<>();
        numbers.put("One", 1);
        numbers.put("Two", 2);
        numbers.put("Three", 3);
        System.out.println("TreeMap: " + numbers);
        int value = numbers.remove("Two");
        System.out.println(value);
        boolean result = numbers.remove("Three", 3);
        System.out.println(result);
        System.out.println("Updated TreeMap: " + numbers);
    }
}
