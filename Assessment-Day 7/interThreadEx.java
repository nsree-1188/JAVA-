class Shop {
    String item;
    boolean available = false;

    synchronized public void buy() {
        System.out.println("Customer wants to buy an item.");
        while (!available) {
            System.out.println("No item available. Waiting for seller to produce...");
           try {
                wait();
            } catch (InterruptedException e) {
                System.out.println("Interrupted while waiting.");
            }
        }
        System.out.println("Customer bought the " + item);
        available = false;
       // notify(); 
    }

    synchronized public void produce(String item) {
        System.out.println("Seller wants to produce an item.");
        while (available) {
            System.out.println("Item already available. Waiting for customer to buy...");
          /*  try {
                notify();
            } catch (InterruptedException e) {
                System.out.println("Interrupted while waiting.");
            }
        }*/
        }
        this.item = item;
        System.out.println("Seller produced: " + item);
        available = true;
       notify();  
    }
}

public class interThreadEx {
    public static void main(String[] args) throws Exception{
        Shop shop = new Shop();

        
        new Thread(() -> {
            shop.buy();
        }).start();

        
        new Thread(() -> {
            shop.produce("Laptop");
        }).start();
    }
}
