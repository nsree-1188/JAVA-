public class bankAcc
{
    String accNo;
    int balance;
    public bankAcc(String accNo,int balance)
    {
        this.accNo=accNo;
        this.balance=balance
    }
    public void deposit(int amount)
    {
        balance+=amount;
        System.out.println("balance:"+balance);
    }

}
class savAcc
{
    public savAcc(String accNo,int balance)
    {
        super(accNo,balance);
    }
    public void addInterest()
    {
        int interest = balance* 5/100;
        balance+=interest;
        System.out.println(interest);
        System.out.println(balance);
    }
}
public class Main
{
    public static void main(String args[])
    {
        savAcc s=new savAcc("6000",1000);
        s.deposit(500);
        s.addInterest();
    }
}