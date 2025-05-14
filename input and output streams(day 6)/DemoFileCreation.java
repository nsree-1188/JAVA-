import java.io.File;
class DemoFileCreation{
    public static void main(String args[]) throws Exception{
        File fo=new File("File.txt");
        boolean status=fo.createNewFile();
        if(status)
        {
            System.out.print("A new file is created");
        }
        else{
            System.out.print("file is already available");
        }
        System.out.print("Name of the file\t"+fo.getName());
        System.out.print(" "+fo.isAbsolute());
        System.out.print("Path=\t"fo.getAbsolutePath());
       // System.out.print(fo.exists());
        boolean ex=fo.exists();
        if(ex){
        System.out.print("file is readable "+fo.canRead());
        System.out.print("file is writable "+fo.canWrite());
        }
    }
    
}