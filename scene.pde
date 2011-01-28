/* adapted from http://processing.org/learning/topics/springs.html */
class Bird
{
    PShape pth;
    int pathpos=0;
    PShape shp;
    int animpos=1;
    bool dirback=false;
    float curx;
    float cury;
    float tmr=0;
    float totdst=0;
    float pcnt=0;
    void update() {
	if (tmr % 1==0)
	    {
		if (dirback) animpos--;
		else animpos++;
	    }

	if (animpos>=7) 
	    {
		dirback=true;
	    }
	else if (animpos<=2) 
	    {
		dirback=false;
	    }
    }
    void display() {
	var chname = 'bird'+animpos;
	PShape ch = shp.getChild(chname);
	//console.log("gotten child %o from %o for %o. placing on %o, %o (%o,%o)",ch,shp,chname,curx,cury,shp.width,shp.height);
	if (!ch) throw "no child";
	ch.height = shp.height; ch.width = shp.width;
	//ch.disableStyle();

	//console.log("reading %o",pth);
	var fvert = pth.vertices[pathpos];
	var tvert = pth.vertices[pathpos+1];
	//console.log("verts %o,%o",fvert,tvert);
	float frx=fvert[0]; float fry=fvert[1]; float tox = tvert[0]; float toy=tvert[1];
	//console.log("seg %o,%o => %o,%o",frx,fry,tox,toy);
	float mydst = dist(frx,fry,tox,toy);
	float mypcnt = totdst / mydst / 100 /5;
	var coeff=2;
	fry*=coeff;fry+=60 + animpos*3;
	toy*=coeff;toy+=60 + animpos*3;
	frx*=coeff;frx+=60;
	tox*=coeff;tox+=60;
	var oprt=onpath(frx,fry,tox,toy,mypcnt,ch,3,pcnt,true);
	pathpos+=oprt[0]; pcnt = oprt[1]; curx = oprt[2]; cury = oprt[3];
	//shape(ch,curx,cury,ch.width/2,ch.height/2);
	if (pathpos>=pth.vertices.length-1) pathpos=0;



	//if (tmr>=39) throw "hi";

	//rect(curx,cury,shp.width,shp.height);
	tmr++;
    }
    Bird(PShape s,x,y,p)
    {
	pth = p;
	for (var i=0;i<pth.vertices.length-1;i++)
	    totdst+=dist(pth.vertices[i][0]
			     ,pth.vertices[i][1]
			     ,pth.vertices[i+1][0]
			     ,pth.vertices[i+1][1]);
	console.log('bird totdst is %o',totdst);
	shp = s;
	animpos=0;
	curx = x ;
	cury = y;
    }
}
class Spring 
{ 
    // Screen values 
    float xpos, ypos;
    float tempxpos, tempypos; 
    int size = 20; 
    boolean over = false; 
    boolean move = false; 

    // Spring simulation constants 
    float mass;       // Mass 
    float k = 0.2;    // Spring constant 
    float damp;       // Damping 
    float rest_posx;  // Rest position X 
    float rest_posy;  // Rest position Y 

    // Spring simulation variables 
    //float pos = 20.0; // Position 
    float velx = 0.0;   // X Velocity 
    float vely = 0.0;   // Y Velocity 
    float accel = 0;    // Acceleration 
    float force = 0;    // Force 

    Spring[] friends;
    int me;

    PShape mshape;

    // Constructor
    Spring(float x, float y, int s, float d, float m, 
	   
	   float k_in, Spring[] others, int id,PShape shp) 
    { 
	xpos = tempxpos = x; 
	ypos = tempypos = y;
	rest_posx = x;
	rest_posy = y;
	size = s;
	damp = d; 
	mass = m; 
	k = k_in;
	friends = others;
	me = id; 
	mshape = shp;
    } 

    void update() 
    { 
	float td = dist(xpos,ypos,mouseX,mouseY);
	float mondist = dist(0,0,width,height)/30;
	//console.log("checking td %o for tree %o vs %o",td,me,mondist);
	if (td<mondist)
	    pressed();
	else
	    released();

	if (move) { 
	    rest_posy = mouseY-mshape.height; 
	    rest_posx = mouseX-mshape.width;
	} 

	force = -k * (tempypos - rest_posy);  // f=-ky 
	accel = force / mass;                 // Set the acceleration, f=ma == a=f/m 
	vely = damp * (vely + accel);         // Set the velocity 
	tempypos = tempypos + vely;           // Updated position 

	force = -k * (tempxpos - rest_posx);  // f=-ky 
	accel = force / mass;                 // Set the acceleration, f=ma == a=f/m 
	velx = damp * (velx + accel);         // Set the velocity 
	tempxpos = tempxpos + velx;           // Updated position 

    
	/*if ((over() || move) && !otherOver() ) { 
	    over = true; 
	} else { 
	    over = false; 
	    } */
    } 
  
    // Test to see if mouse is over this spring
    boolean over() {
	float disX = tempxpos - mouseX;
	float disY = tempypos - mouseY;
	if (sqrt(sq(disX) + sq(disY)) < size/2 ) {
	    return true;
	} else {
	    return false;
	}
    }
  
    // Make sure no other springs are active
    boolean otherOver() {
	for (int i=0; i<num; i++) {
	    if (i != me) {
		if (friends[i].over == true) {
		    return true;
		}
	    }
	}
	return false;
    }

    void display() 
    { 
	if (over) { 
	    fill(153); 
	} else { 
	    fill(255); 
	} 
	//ellipse(tempxpos, tempypos, size, size);
	//console.log(accel);
	float acoeff = 1 - abs(accel);
	shape(mshape,tempxpos,tempypos,mshape.width*2*acoeff,mshape.height*2*acoeff);
    } 

    void pressed() 
    { 
	if (over) { 
	    move = true; 
	} else { 
	    move = false; 
	}  
    } 

    void released() 
    { 
	move = false; 
	rest_posx = xpos;
	rest_posy = ypos;
    } 
} 

PShape sc,clouds,tree,tree2,ski;
PImage sci;
Spring spr,spr2;
Bird brd;
int clmov=0;
float tx,ty,tcx,tcy;
float t2x,t2y,t2cx,t2cy;
PShape skipath,birdpath;
var ski_totdst = 0; //of skipath
var brd_totdst = 0;
void setup() {
    //drawing.svg,clouds.svg,tree.svg,
  /* @pjs preload="drawing.png"; */
  tree = loadShape("tree.svg");
  ski = loadShape("ski.svg");
  sc = loadShape("drawing.svg");
  skipath = sc.getChild("skipath");
  birdpath = sc.getChild("birdpath");
  console.log("skipath = %o",skipath);

  //calculate total path distances
  for (var i=0;i<skipath.vertices.length-1;i++)
	  ski_totdst+=dist(skipath.vertices[i][0],skipath.vertices[i][1],skipath.vertices[i+1][0],skipath.vertices[i+1][1]);



  sci = loadImage("drawing.png");

  clouds = loadShape("clouds.svg");

  tree2 = loadShape("tree2.svg");
  tx = width/17; ty = height/1.8;
  tcx = tx+tree.width;
  tcy = ty+tree.height;
  spr = new Spring( tx, ty,  20, 0.98, 8.0, 0.1, [], 0,tree); 

  brd = new Bird(loadShape("birds.svg"),width/2,height/5,birdpath);

  t2x = width/5.1; t2y = height/1.8;
  t2cx = t2x+tree2.width;
  t2cy = t2y+tree2.height;
  spr2 = new Spring (t2x,t2y,20,0.98,5,0.1,[],1,tree2);

  background(255,255,255);
  smooth();

}
int onpath(float fx,float fy,float tx,float ty,flaot pcntincr,PShape ski,float sizecoeff,float pcnt,bool doshow)  {
    float dstx = tx-fx;
    float dsty = ty-fy;
    pcnt += pcntincr; //0.10;  
    
    float curx = fx + (pcnt * dstx);  
    float cury = fy + (pcnt * dsty); //(pow(pcnt, exponent) * dsty);  


     //console.log("%o,%o => %o,%o :: %o (+=%o) shape(%o,%o,%o,%o,%o)",fx,fy,tx,ty,pcnt,pcntincr,ski,curx-width/20,cury-height/6,ski.width/sizecoeff,ski.height/sizecoeff);
    if (!doshow) return [0,pcnt];
    shape(ski,curx-width/20,cury-height/6,ski.width/sizecoeff,ski.height/sizecoeff); //ellipse(curx, cury, 20, 20);  
    if (pcnt>=1)
	{
	    pcnt=0;
	    return [1,pcnt,curx,cury];
	}
    else
	return [0,pcnt,curx,cury];
}

int cloudspeed=width/200;
bool treejump=false;
bool pause=false;

int skipos=0;
float segpos=0;
float skipcnt=0;
int exponent=4;
float skicurx=0;
float skicury=0;

void keyPressed(kp) {
    console.log(keyCode);
    if (keyCode==32)
	pause=!pause;
}
float cloudx,cloudy;
bool styledisabled=false;
void mouseClicked() {
    if (dist(mouseX,mouseY,cloudx,cloudy)<clouds.width/2)
	{
	    console.log(clouds);
	    
	    if (!styledisabled)
		{
		    clouds.disableStyle();
		    styledisabled=true;
		}
	    else
		{
		    clouds.enableStyle();
		    styledisabled=false;
		}
	    
	    /*	    var cf = clouds.getChild('cloudfill');
	    console.log(cf);
	    cf.fillColor='#000000';
	    cf.disableStyle();*/
	}
}
int drwcnt=0;
void draw() {

    if (pause) return;
  background(#ffffff);
  clmov+=cloudspeed;
  shape(clouds,0-clouds.width,0,width/3.5,height/3.5);

  if (svgbg) { 
      shape(sc,0,0,width,height); 
      //println("using svg background");
  }
  else  image(sci,0,0,width,height);

  //shape(birdpath,0,0,width,height);

  clouds.translate(cloudspeed,0);
  if (clmov>=width)
    {
      clmov=0;
      clouds.translate(width*-1,0);
    }
  //update our registry of cloud pos
  //IT IS A COMPLETE MYSTERY AS TO WHY THE RECT HAS TO INCREASE X BY 1.3
  cloudx = 0+(clmov*1.3)+clouds.width/5; 
  cloudy = height/10;
  //console.log("%o,%o (%o)",cloudx,cloudy,clmov);


  //jump the tree if we are close to it
  spr.update();
  spr.display();
  spr2.update();
  spr2.display();


  var coeff=2;
  var skxos = 0; //width/2.6;
  var skyos = height/8;
  //console.log("ski_totdst %o",ski_totdst);
  var svert = skipath.vertices[skipos];
  var stovert = skipath.vertices[skipos+1];
  float frx = svert[0]; float fry = svert[1]; float tox=stovert[0] ; float toy=stovert[1];
  float mydst = dist(svert[0],svert[1],stovert[0],stovert[1]);
  float mypcnt = ski_totdst / mydst / 100 ;
  frx*=coeff;fry*=coeff;
  frx+=skxos; fry+=skyos;
  tox*=coeff; toy*=coeff;
  tox+=skxos; toy+=skyos;
  //console.log("%o / %o (%o points) = %o",mydst,ski_totdst,skipath.vertices.length,mypcnt);

  var oprt=onpath(frx,fry,tox,toy,mypcnt/2,ski,10,skipcnt,true);
  skipos+=oprt[0]; skipcnt=oprt[1]; skicurx = oprt[2]; skicury = oprt[3];
  if (skipos>=skipath.vertices.length-1) skipos=0;


  brd.update();
  brd.display();

  drwcnt++;
  //if (drwcnt>5) throw "bahaha";

}



