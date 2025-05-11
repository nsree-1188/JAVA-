@FunctionalInterface
interface demofunctional
{
    public void showme();
 
}
 
class Main
{
    public static void main(String[] args) {
        new demofunctional()
    {
    @Override
    public void showme()
    {
        System.out.println("functional interface");
    }
    }.showme();
}
}