class Karnataka
{
    String capital;
    String cm;
    int area;
 
    class Mysuru
    {
        String nameofcollector;
        int dis_area;
 
        public void displayMysuru(String nameofcollector,int dis_area)
        {
            this.nameofcollector=nameofcollector;
            this.dis_area=dis_area;
 
            System.out.println("Name of the collector"+nameofcollector);
            System.out.println("Distance area"+dis_area);
        }
    }
}
 
class demonested
 {
      public static void main(String[] args) {
          Karnataka kobj=new Karnataka();
          Karnataka.Mysuru mobj=kobj.new Mysuru();
          mobj.displayMysuru("samy",32332);
      }
 }