import java.util.*;

enum Role
 {

    ADMIN,
    USER
}

interface Parkable 
{
    void park(Vehicle vehicle);
    void remove(String ticketId, int hours);
}

class Vehicle 
{
    private String plate;
    private String type;

    public Vehicle(String plate, String color, String type) 
    {
        this.plate = plate;
        this.type = type;
    }

    public String getPlate() 
    {
        return plate;
    }

    public String getType() 
    {
        return type;
    }
}

class Ticket 
{
    private String id;
    private Vehicle vehicle;

    public Ticket(String id, Vehicle vehicle) 
    {
        this.id = id;
        this.vehicle = vehicle;
    }

    public String getId() 
    {
        return id;
    }

    public Vehicle getVehicle() 
    {
        return vehicle;
    }
}

class Slot 
{
    private int slotNo;
    private String allowedType;
    private boolean occupied;
    private Vehicle vehicle;
    private Ticket ticket;

    public Slot(int slotNo, String allowedType) 
    {
        this.slotNo = slotNo;
        this.allowedType = allowedType;
        this.occupied = false;
    }

    public int getSlotNo() 
    {
        return slotNo;
    }

    public boolean isAvailable()
     {
        return !occupied;
    }

    public boolean fits(String type) 
    {
        return allowedType.equals(type) && isAvailable();
    }

    public void park(Vehicle v, Ticket t) 
    {
        this.vehicle = v;
        this.ticket = t;
        this.occupied = true;
    }

    public void vacate() 
    {
        this.vehicle = null;
        this.ticket = null;
        this.occupied = false;
    }

    public Ticket getTicket() 
    {
        return ticket;
    }

    public boolean isOccupied() 
    {
        return occupied;
    }
}

class Floor 
{
    private ArrayList<Slot> slots;

    public Floor(int totalSlots) 
    {
        slots = new ArrayList<>();
        for (int i = 1; i <= totalSlots; i++) 
        {
            if (i == 1)
                slots.add(new Slot(i, "TRUCK"));
            else if (i <= 3)
                slots.add(new Slot(i, "BIKE"));
            else
                slots.add(new Slot(i, "CAR"));
        }
    }

    public Slot findSlot(String vehicleType) 
    {
        for (Slot slot : slots) {
            if (slot.fits(vehicleType))
                return slot;
        }
        return null;
    }

    public ArrayList<Slot> getAllSlots()
     {
        return slots;
    }
}

class Payment 
{
    private Ticket ticket;
    private int hours;
    private double amount;

    public Payment(Ticket ticket, int hours) 
    {
        this.ticket = ticket;
        this.hours = hours;
        this.amount = calculate(ticket.getVehicle().getType(), hours);
    }

    private double calculate(String type, int h)
     {
        double base = 0, extra = 10;
        switch (type) {
            case "CAR":
                base = 40;
                break;
            case "BIKE":
                base = 20;
                break;
            case "TRUCK":
                base = 60;
                break;
        }
        return (h == 1) ? base : base + (h - 1) * extra;
    }

    public void printReceipt() 
    {
        System.out.println("Ticket ID: " + ticket.getId());
        System.out.println("Vehicle Type: " + ticket.getVehicle().getType());
        System.out.println("Hours Parked: " + hours);
        System.out.println("Amount: Rs. " + amount);
    }
}

class ParkingLot implements Parkable 
{
    private String name;
    private ArrayList<Floor> floors;

    public static final int totalFloors = 5;
    public static final int totalSlots = 10;

    public ParkingLot(String name) {
        this.name = name;
        this.floors = new ArrayList<>();
        for (int i = 0; i < totalFloors; i++)
            floors.add(new Floor(totalSlots));
    }

    public ArrayList<Floor> getFloors() 
    {
        return floors;
    }

    @Override
    public void park(Vehicle v)
     {
        for (int i = 0; i < floors.size(); i++) 
        {
            Floor floor = floors.get(i);
            Slot slot = floor.findSlot(v.getType());
            if (slot != null) {
                String id = name + "_" + (i + 1) + "_" + slot.getSlotNo();
                Ticket ticket = new Ticket(id, v);
                slot.park(v, ticket);
                System.out.println("Parked: " + id);
                return;
            }
        }
        System.out.println("No slot available.");
    }

    @Override
    public void remove(String id, int hours) 
    {
        if (!id.matches("^" + name + "_\\d+_\\d+$")) 
        {
            System.out.println("Invalid Ticket ID.");
            return;
        }

        String[] parts = id.split("_");
        int floorIdx = Integer.parseInt(parts[1]) - 1;
        int slotIdx = Integer.parseInt(parts[2]) - 1;

        if (floorIdx >= floors.size() || floorIdx < 0) 
        {
            System.out.println("Invalid floor.");
            return;
        }

        Floor floor = floors.get(floorIdx);
        ArrayList<Slot> slots = floor.getAllSlots();

        if (slotIdx >= slots.size() || slotIdx < 0) 
        {
            System.out.println("Invalid slot.");
            return;
        }

        Slot slot = slots.get(slotIdx);
        Ticket t = slot.getTicket();

        if (t == null || !t.getId().equals(id)) 
        {
            System.out.println("Ticket not found.");
            return;
        }

        slot.vacate();
        Payment p = new Payment(t, hours);
        p.printReceipt();
    }

    public void viewAvailability() 
    {
        for (int i = 0; i < floors.size(); i++) 
        {
            int count = 0;
            ArrayList<Slot> slots = floors.get(i).getAllSlots();
            for (Slot slot : slots) {
                if (slot.isAvailable()) 
                {
                    count++;
                }
            }
            System.out.println("Floor " + (i + 1) + ": " + count + " available slots");
        }
    }
}

public class Parking 
{
    public static void main(String[] args) 
    {
        Scanner sc = new Scanner(System.in);
        Parkable lot = new ParkingLot("NITHYA");

        System.out.println("Welcome to NITHYA Parking System");
        System.out.print("Are you an ADMIN or USER? (Enter ADMIN/USER): ");
        String roleInput = sc.nextLine().trim().toUpperCase();

        Role role;
        try {
            role = Role.valueOf(roleInput);
        } catch (Exception e) {
            System.out.println("Invalid role. Exiting.");
            return;
        }

        while (true) {
            System.out.println("\n--- " + role + " Menu ---");

            if (role == Role.USER) {
                System.out.println("1. Park Vehicle");
                System.out.println("2. Remove Vehicle");
                System.out.println("3. Exit");
            } else if (role == Role.ADMIN) {
                System.out.println("1. View Parking Status");
                System.out.println("2. Exit");
            }

            System.out.print("Enter choice: ");
            int choice = sc.nextInt();
            sc.nextLine();

            if (role == Role.USER) 
            {
                switch (choice)
                 {
                    case 1:
                        System.out.print("Enter vehicle number: ");
                        String plate = sc.nextLine();
                        System.out.print("Enter vehicle color: ");
                        String color = sc.nextLine();
                        System.out.print("Enter vehicle type (CAR/BIKE/TRUCK): ");
                        String type = sc.nextLine().toUpperCase();

                        Vehicle v = new Vehicle(plate, color, type);
                        lot.park(v);
                        break;

                    case 2:
                        System.out.print("Enter ticket ID: ");
                        String id = sc.nextLine();
                        System.out.print("Enter hours parked: ");
                        int hrs = sc.nextInt();
                        sc.nextLine();
                        lot.remove(id, hrs);
                        break;

                    case 3:
                        System.out.println("Goodbye!");
                        sc.close();
                        return;

                    default:
                        System.out.println("Invalid choice.");
                }
            } else if (role == Role.ADMIN) 
            {
                switch (choice)
                 {
                    case 1:
                        ((ParkingLot) lot).viewAvailability(); 
                        break;
                 case 2:
                        System.out.println("Goodbye!");
                        sc.close();
                        return;

                    default:
                        System.out.println("Invalid choice.");
                }
            }
        }
    }
}