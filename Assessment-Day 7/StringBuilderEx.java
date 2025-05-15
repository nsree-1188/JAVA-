public class StringBuilderEx {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder();

        sb.append("Nithya");
        sb.append(" ");
        sb.append("is");
        System.out.println(sb.toString()); 

        sb.insert(5, ", beautiful");
         System.out.println(sb.toString());

        sb.delete(5, 16);
        System.out.println(sb.toString()); 

        sb.replace(0, 5, "Greetings");
        System.out.println(sb.toString()); 

        sb.reverse();
        System.out.println(sb.toString()); 

        int length = sb.length();
        System.out.print("Length "+length);

        char firstChar = sb.charAt(0);
        System.out.println("First character: " + firstChar); 
    }
}