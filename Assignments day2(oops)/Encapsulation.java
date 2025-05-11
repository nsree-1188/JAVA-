class Product
{
    private int id;
    private String name;
    private String discription;
    private int price;
    private String quantity;
    public void setId(int id)
    {
        this.id=id;
    }
    public void setName(String name)
    {
        this.name=name;
    }
    public void setDiscription(String discription)
    {
        this.discription=discription;
    }
    public void setPrice(int price)
    {
        this.price=price;
    }
     public void setQuantity(String quantity)
    {
        this.quantity=quantity;
    }
    public void getId()
    {
        System.out.println("Id "+id);
    }
    public void getName()
    {
        System.out.println("Name "+name);
    }
    public void getDiscription()
    {
        System.out.println("discription "+discription);
    }
    public void getPrice()
    {
        System.out.println("price "+price);
    }
    public void getQuantity()
    {
        System.out.println("quantity "+quantity);
    }
}
public class Main
{
    public static void main(String args[])
    {
        Product p=new Product();
        p.setId(1);
        p.setName("Raw honey");
        p.setDiscription("pure");
        p.setPrice(100);
        p.setQuantity("1l");
        
        p.getId();
        p.getName();
        p.getDiscription();
        p.getPrice();
        p.getQuantity();
    }
}
    