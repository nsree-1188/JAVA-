void main()
{
    print(greetings(a));

}
 String greetings(Function callFun)
 {

    return callFun();
}
String  a(){
    return "hello world";
}