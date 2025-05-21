void main(){
   var a=outerscope();
   print(a("hello"));
   var b=out();
   print(b("hi"));
   var c=demo();
   print(c("write"));

}
Function outerscope(){
    return ( 
   (String str)
    {
    return str;
    });
}
Function out(){
    String ins(String s){
        return s;
    }
    return ins;
}
Function demo =>(String k)=>k;
