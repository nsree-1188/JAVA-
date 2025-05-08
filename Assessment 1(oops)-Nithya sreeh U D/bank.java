class bankAcc
{
    String name;
    String type;
    int balance;

    bankAcc(String name, String type, int balance) 
    {
        this.name = name;
        this.type = type;
        this.balance = balance;
    }

    public void displayBankAcc() 
    {
        System.out.println(name + " " + type + " " + balance);
    }
}

class savingAcc extends bankAcc 
{
    String accNo;

 
    savingAcc(String name, String type, int balance)
    {
        super(name, type, balance);
    }

    
    savingAcc(String name, String type, int balance, String accNo)
    {
        this(name, type, balance); 
        this.accNo = accNo;
        this.name = "Ram"; 
        
    }

    public void displaySavingAcc() 
    {
        super.type="current";
        super.displayBankAcc();
        System.out.println(accNo);
    }

    public void result() 
    {
        this.displaySavingAcc();
        System.out.print("Nithya");
    }
}

class bank
{
    public static void main(String[] args)
    {
        savingAcc s = new savingAcc("Prabhu", "Savings", 7000, "A101");
        s.result();
    }
}
