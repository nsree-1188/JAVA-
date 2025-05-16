import java.util.*;
public class LinkedHashSetExample {
    public static void main(String[] args) {
        HashSet<Integer> set1 = new LinkedHashSet<>(Arrays.asList(1, 2, 3, 4, 5));
        HashSet<Integer> set2 = new LinkedHashSet<>(Arrays.asList(4, 5, 6, 7, 8));
        HashSet<Integer> set3 = new LinkedHashSet<>(Arrays.asList(1, 2, 3));
        System.out.println("set1 before add(6): " + set1);
        set1.add(6);
        System.out.println("set1 after add(6): " + set1);

    
        System.out.println("set1 before addAll(set2): " + set1);
        set1.addAll(set2);
        System.out.println("set1 after addAll(set2): " + set1);
        System.out.println("set1 contains 3: " + set1.contains(3));
        System.out.println("set1 containsAll set3: " + set1.containsAll(set3));
        System.out.println("set2 containsAll set3: " + set2.containsAll(set3));
        System.out.println("set1 before retainAll(set2): " + set1);
        set1.retainAll(set2);
        System.out.println("set1 after retainAll(set2): " + set1);
        System.out.println("set1 before remove(4): " + set1);
        set1.remove(4);
        System.out.println("set1 after remove(4): " + set1);

         System.out.println("set2 before removeAll(set1): " + set2);
        set2.removeAll(set1);
        System.out.println("set2 after removeAll(set1): " + set2);

    
        System.out.println("set3 before clear(): " + set3);
        set3.clear();
        System.out.println("set3 after clear(): " + set3);

    
        System.out.println("set3 is empty: " + set3.isEmpty());

       
        System.out.println("set1 size: " + set1.size());
    }
}