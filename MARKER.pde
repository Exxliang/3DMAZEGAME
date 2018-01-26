class MARKER{
  float Mx,My,Mz;
  MARKER(float x,float y,float z){
    Mx = x;
    My = y;
    Mz = z;
  }
  
  void MAKE(){
    stroke(75,206,219);
    noFill();
    translate(Mx,My,Mz);
    sphere(s/4);
    translate(-Mx,-My,-Mz);
  }
}
