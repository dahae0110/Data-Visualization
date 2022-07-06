/*****************************************************************************************************************
 Reference: 
 [1] HTML color picker, w3schools, [https://www.w3schools.com/colors/colors_picker.asp] (most recent access 2021-07-12)
 [2] ShowSelectedState, PhiLho, [http://bazaar.launchpad.net/~philho/+junk/Processing/files/head:/_QuickExperiments/_SVG/ShowSelectedState/] (most recent access 2021-07-12)
 
 2600190451-4 Dahae Shin
 "Minimum wage of U.S."
 Preprocessed the data (using excel). Added Latitude and Longitude.
 U.S. Map image: https://www.50states.com/maps/usamap.htm
 US states coordinates: https://www.kaggle.com/washimahmed/usa-latlong-for-state-abbreviations
 From the data set, I deleted: Guam, Purto Rico and U.S. virgin islands due to the location (isolated locations)
 *****************************************************************************************************************/

import java.util.ArrayList;
import java.util.List;
import java.util.Arrays;
import java.util.*;
import java.util.ArrayList;

// Hash table 
int index = 0;
// PImage map;
PShape US;
PGraphics map;

// For data visualization
int numOfData;
String csvFileName = "US_wage.csv";
State[] wage;
int stateCount;
float scale = 1.2;
int selectedState = -1;
int selYear = 2020;
String stateName = "<none>";
float scaleGraph = 0.8f;


// For labeling the data visualization
float topspace = 700;
float rightspace = 570;
int horizontalspacing = 20; // horizontal spacing
float yearlabelradians = radians(-45);
int verticalscale = 30; 

// For calling the data
Table table;
String [] minColumns = {"2001", "2002", "2003", "2004", "2005", "2006", "2007", "2008", "2009", "2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020"};
String [] fedColumns = {"2001_Fed", "2002_Fed", "2003_Fed", "2004_Fed", "2005_Fed", "2006_Fed", "2007_Fed", "2008_Fed", "2009_Fed", "2010_Fed", "2011_Fed", "2012_Fed", "2013_Fed", "2014_Fed", "2015_Fed", "2016_Fed", "2017_Fed", "2018_Fed", "2019_Fed", "2020_Fed"};
String [] minOldColumns = {"2001_Old", "2002_Old", "2003_Old", "2004_Old", "2005_Old", "2006_Old", "2007_Old", "2008_Old", "2009_Old", "2010_Old", "2011_Old", "2012_Old", "2013_Old", "2014_Old", "2015_Old", "2016_Old", "2017_Old", "2018_Old", "2019_Old", "2020_Old"};

HashMap<String, State> listOfStates = new HashMap<String, State>();  // Declare and initalize
HashMap<String, Year> minListOfYears;  // Declare
HashMap<String, Year> fedListOfYears;  // Declare
HashMap<String, Year> minOldListOfYears;  // Declare

void setup() {
  // Canvas
  size(1500, 800);
  smooth();
  noStroke();

  // U.S. states  image
  US = loadShape("US_Map.svg");
  stateCount = US.getChildCount();
  
  // Load CSV
  Table csvData = loadTable(csvFileName, "header");
  numOfData = csvData.getRowCount();

  for (TableRow tr : csvData.rows()) {  // For each row
    minListOfYears = new HashMap<String, Year>();  // Initalize and get a new hashmap
    fedListOfYears = new HashMap<String, Year>();  // Initalize and get a new hashmap
    minOldListOfYears = new HashMap<String, Year>();  // Initalize and get a new hashmap

    String code = tr.getString("Code");
    //println("code = " + code);
    
    for (String column : minColumns) {  // For each column
      float stateMin = tr.getFloat(column);
      //println("stateMin = " + column + ", " + stateMin);
      Year year = new Year();
      year.value = column;
      year.stateMin = stateMin;
      minListOfYears.put(column, year);
    }
    for (String column : fedColumns) {  // For each column
      float fedMin = tr.getFloat(column);
      //println("fedMin = " + column + ", " + fedMin);
      Year year = new Year();
      year.value = column;
      year.fedMin = fedMin;
      fedListOfYears.put(column, year);
    }  
    for (String column : minOldColumns) {  // For each column
      float stateOldMin = tr.getFloat(column);
      //println("stateOldMin = " + column + ", " + fedMin);
      Year year = new Year();
      year.value = column;
      year.stateOldMin = stateOldMin;
      minOldListOfYears.put(column, year);
    }
    State state = new State();
    state.code = code;
    state.minListOfYears = minListOfYears;
    state.fedListOfYears = fedListOfYears;
    state.minOldListOfYears = minOldListOfYears;
    listOfStates.put(code, state);
  }
  
  /* Checking if the data is called right */
  //State state = listOfStates.get("AL");
  //println("state = " + state.code);
      
  // for one year
  //Year yearMin = state.minListOfYears.get("2009");
  //println("StateMin = " + yearMin.value + ", "  + yearMin.stateMin);
  
    
  //Iterator itr = listOfStates.entrySet().iterator();
  
  //while (itr.hasNext()){
  //  Map.Entry mapElement = (Map.Entry)itr.next();
  //  State state = ((State)mapElement.getValue());
  //  println("state = " + state.code);

  ////   //to check all years
    
    //Iterator itr2 = state.minListOfYears.entrySet().iterator();

    //while (itr2.hasNext()){
    //  Map.Entry mapElement2 = (Map.Entry)itr2.next();
    //  Year year = ((Year)mapElement2.getValue());
    //  println("stateMin = " + year.value + ", " + year.stateMin);
    //  //println("fedMin = " + year.fedMin);
    //}
  //}

  // Function for state selection
  makeHiddenMap();
  
  // Function for state color difference
  displayStates();
  
  // Function for displaying labels 
  drawLabel(); 
}

void draw() {
  // Leave this blank
}

// For drawing show maps and graphics information layout
void drawLabel() {
  noStroke();
  
  // Graph title 
  pushMatrix();
  fill(0, 0, 0, 200);
  textSize(30);
  text("< 20 Years Trend of Minimum Wage in US >", 400, 770);
  popMatrix();
  
  // Show the current year of the displayed map
  pushMatrix();
  fill(0,0,0, 180);
  textSize(30);
  text("Year showing: " + selYear, 700, 50);
  popMatrix();

  // Label to show color difference on the wage difference
  for (int i = 40; i < 255; i++) {
    pushMatrix();
    fill(305-(10+i), 335-(10+i), 255); 
    rect(rightspace + 0.75 * i, topspace, 100, 20);
    popMatrix();
  }
  
  //// Label to show color difference on the wage difference
  //for (int i = 0; i < 255; i++) {
  //  pushMatrix();
  //  fill(10+i, 100+i, 255); 
  //  rect(rightspace + 100 + 0.75 * i, topspace, 1, 20);
  //  popMatrix();
  //}
  
  //// Label to show color difference on the wage difference
  //for (int i = 0; i < 255; i++) {
  //  for (int j = 0; j < 113; j++) {
  //    k = 235-j;
  //  }
  //    fill(204-52-i, k, 255, 200); 
  //    rect(rightspace + 100 + 0.75 * i, topspace, 2, 20);
  //}
  
  // Label to display what the color difference indicates
  fill(0, 0, 0, 200);
  textSize(20);
  text("Wages", rightspace + 120, topspace - 20);
  fill(55, 67, 253, 240);
  textSize(18);
  text("High", rightspace + 250, topspace - 20);
  textSize(18);
  fill(154, 155, 187, 240);
  text("Low", rightspace + 20, topspace - 20);

}

// For indicating the state
void makeHiddenMap()
{
  map = createGraphics(width, height);
  map.beginDraw();
  map.scale(scale);
  map.noStroke();
  map.background(255);
  
  for (int i = 0; i < stateCount; i++) 
  {
    PShape state = US.getChild(i);
    // Colors in the US_Map.svg will be disabled
    state.disableStyle();
    // Set the coloring depending on the total number of states
    // Up to 255 states avaliable
    map.fill(i, 0, 0);
    // Draw a single state  
    map.shape(state, 0, 0);
  }
  map.endDraw();
  //image(map,0,0); // To show the map
}

// For showing each state's different minimum wage by color difference
void displayStates()
{
  String yearSelected = str(selYear); // Change selYear to string, in order to use it for the hash map

  PGraphics map2 = createGraphics(width, height);
  map2.beginDraw();
  map2.scale(scale);
  map2.noStroke();
  map2.background(255);


  for (int i = 0; i < stateCount; i++) 
  {
    PShape pstate = US.getChild(i);
    println("["+i+"] code = " + pstate.getName());
    pstate.disableStyle();

    State state = listOfStates.get(pstate.getName());
    println("state code = " + state.code);
    
    // Draw a single state
    Year year = state.minListOfYears.get(yearSelected);
    // Darkest (0,122,204,200)
    // Lightest (204,235,255,200)
    map2.fill( 204 - (year.stateMin * 40) , 275 - (year.stateMin * 20), 255, 200);

    //map2.fill((year.stateMin * 10) + 10 , (year.stateMin * 20), 255);
    map2.shape(pstate, 0, 0);

  }
  map2.endDraw();
  image(map2,0,0); // To show the map
}

// For displaying graphs on the state selected by mouse click
void drawSelectedState() 
{
  String yearSelected = str(selYear); // Change selYear to string, in order to use it for the hash map

  PShape state = US.getChild(selectedState);
  state.disableStyle();

  State selectedState = listOfStates.get(stateName); // stateName = code
  //println("state = " + selectedState.code);
  
  fill(155); // filling selected state's color
  pushMatrix();
  scale(scale);
  shape(state, 0, 0);   // Draw a single state
  popMatrix();
  
  //pushMatrix();
  textSize(20);
  fill(0);
  text("state minimum wage", 1125, 100);
  text("by", 1125, 121);
  //fill(255, 255, 0);
  fill(250, 220, 8, 255);
  text("the original", 1155, 121);
  fill(0);
  text("and", 1125, 141);
  fill(150, 186, 255);
  text("2020 dollars", 1165, 141);
  fill(0);
  text("converted", 1295, 141);
  //popMatrix();
  
  // Draw the state minimum wage data in current dollar value bar graph
  float x = 1125f;  
  float y = 120;

  for (String col : minColumns) {
    Year year = selectedState.minListOfYears.get(col);
    y = y + verticalscale;

    if (col.equals(yearSelected)) {
      //println("[1]col =" + col +", yearSelected = " + yearSelected);
      //fill(24, 90, 219);
      fill(124, 131, 253);
    } else {
      //println("[2]col =" + col +", yearSelected = " + yearSelected);
      fill(150, 186, 255);
    }
    
    if (year.stateMin == 0f || year.stateMin < 3f) {
      rect(x, y, ((int)year.stateMin* 30), 15);
      textSize(12);
      fill(0);
      text("$" + year.stateMin , x + 5, y + 14);  // Write the minimum wage label
      //textSize(13);
      //fill(0);
      //rect(x, y, 5, 15);
      //text("$" + year.stateMin , x + 5, y + 15);  // Write the minimum wage label
    } else if (year.stateMin > 11f) {
      rect(x, y, (((int)year.stateMin* 30) - 70) * 0.95, 15);
      textSize(12);
      fill(0);
      text("$" + year.stateMin , x + 5, y + 14);  // Write the minimum wage label
      //textSize(13);
      //fill(0);
      //rect(x, y, 5, 15);
      //text("$" + year.stateMin , x + 5, y + 15);  // Write the minimum wage label
    } else {
      rect(x, y, ((int)year.stateMin* 30)-70, 15);
      textSize(12);
      fill(0);
      text("$" + year.stateMin , x + 5, y + 14);  // Write the minimum wage label

    }
    textSize(14);
    fill(0);
    text(col, x - 40, y + 15);  // Write the year label
  }   
  
  // Draw the state minimum wage data in old dollar value in bar graph
  x = 1125f;  
  y = 135; // (state minimum graph y location) + 15 
  
  for (String col : minOldColumns) {
    Year year = selectedState.minOldListOfYears.get(col);
    y = y + verticalscale;

    //println("[2]col =" + col +", yearSelected = " + yearSelected);
    fill(250, 220, 58, 200);
    
    if (year.stateOldMin == 0f || year.stateOldMin < 3f) {
      rect(x, y, ((int)year.stateOldMin* 30), 15);
      textSize(12);
      fill(0);
      text("$" + year.stateOldMin , x + 5, y + 14);  // Write the minimum wage label
     } else if (year.stateOldMin > 11f) {
      rect(x, y, (((int)year.stateOldMin* 30) - 70) * 0.95, 15);
      textSize(12);
      fill(0);
      text("$" + year.stateOldMin , x + 5, y + 14);  // Write the minimum wage label
      //textSize(13);
      //fill(0);
      //rect(x, y, 5, 15);
      //text("$" + year.stateMin , x + 5, y + 15);  // Write the minimum wage label
    } else {
      rect(x, y, ((int)year.stateOldMin* 30)-70, 15);
      textSize(11);
      //fill(255);
      fill(0);
      text("$" + year.stateOldMin , x + 5, y + 14);  // Write the minimum wage label

    }
    //textSize(15);
    //fill(0);
    //text(col, x - 40, y + 15);  // Write the year label
  }     
  
  // Draw the federal minimum wage data by circle
  x = 1125f;  
  y = 127; // (state minimum graph y location) + 7
    
  for (String col : fedColumns) {
    fill(255,0,0, 170);
    y = y + verticalscale;

    Year year = selectedState.fedListOfYears.get(col);
    circle(x + ((int)year.fedMin* 20)+5, y, 5);
  }
  
  // Shows what red dots mean (=federal Minimum)
  textSize(15);
  fill(255,0,0, 190);
  text("red circle indicates federal minimum" , x, 770);  
}

// On mousePressed
void mousePressed()
{
  if (mouseButton == LEFT)
  {
    color c = map.get(mouseX, mouseY);
    selectedState = int(red(c));
    if (selectedState >= stateCount) // White background or unmapped color (anti-aliasing!)
    {
      selectedState = -1;
    } else
    {
      PShape state = US.getChild(selectedState);
      stateName = state.getName();
    }
    println("Selected: " + selectedState + " - " + stateName);
  } else
  {
    selectedState = -1;
  }
  if (selectedState >= 0) {
    displayStates();
    drawSelectedState();
    drawLabel();
  } else {
    displayStates();
    drawLabel();
  }
}

// On keyPressed
void keyPressed() {
  // do something with character input
  // includes ASCII coded BACKSPACE, TAB, ENTER, RETURN, ESC, DELETE
  switch (key) {
  case 'x':
    exit();
    break;
  case ENTER:
    break;
  case RETURN: 
    // do the same thing for ENTER or RETURN
    break;
  case CODED:
    codedKeyPressed();
    break;
  }
  println(key);
}

// For using UP and DOWN keys
void codedKeyPressed() {
  // handle non-character keys
  // includes arrows UP, DOWN, LEFT, RIGHT, plus ALT, CONTROL, SHIFT
  switch( keyCode ) {
  case UP:
    selYear--;
    if (selYear < 2001) {
      selYear = selYear + 1;
    }
    break;
  case DOWN:
    selYear++;
    if (selYear > 2020) {
      selYear = selYear - 1;
    }
    break;
  case LEFT:
    break;
  case RIGHT:
    break;
  default:
    println("Key not implemented.");
  }
  println("selYear: " + selYear);
  if (selectedState >= 0) {
    displayStates();
    drawSelectedState();
    drawLabel();
  }
}

// Going up and down through the years
String getYear(int year) {
  year--;
  if ( year <0 || year >= minColumns.length ) {
    return "NoMonth";
  } else {
    return minColumns[year];
  }
}

// Class containing code, hashmap for minimum wage and federal wage list of years
class State {
  String code = "";
  HashMap<String, Year> minListOfYears = new HashMap<String, Year>();
  HashMap<String, Year> fedListOfYears = new HashMap<String, Year>();
  HashMap<String, Year> minOldListOfYears = new HashMap<String, Year>();

}

// Class containing value, state minimum wage and federal minimum wage
class Year {
  String value = "";
  float stateMin = 0.0f;
  float fedMin = 0.0f;
  float stateOldMin = 0.0f;
}
