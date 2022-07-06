/*******************************************************************
    Mid-term 2021 - A Year Of Rain at BKC - Final Submission
    Dahae Shin 2600190451-4 
    2020/06/12 
********************************************************************/
 
import java.util.ArrayList;
import java.util.List;
import java.util.Arrays;
import java.time.YearMonth;

int leftMargin = 70;  // offset is the left margin
int topMargin = 40; // offset2 is the top margin
int verticalscale = 25; // spacing of data vertically
int horizontalspacing = 37; // horizontal spacing
int keypadding = 30;  // padding around the key 

ArrayList<OneMonth> allMonths = new ArrayList<OneMonth>();
String [] monthnames = { "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Jan", "Feb", "Mar"};
ArrayList<Integer> numOfDaysInMonth;
ArrayList<String> monthList = new ArrayList<String>(); // month list to store months if it the data matches selected month

int selMonth = 0;  // month starts off from April because data starts off from April

int screenColor = color(150, 150, 150); // background color

Table table;

void settings() {
  size (1300, 850);  // Set the size of the Applet
}

void draw() {
  //if key board is needed
}

void setup() {

  table = loadTable("2019AY_precipdata.csv", "header");  //Load the table from the csv file which is in the same folder
  allMonths = new ArrayList<OneMonth>();
  
  String timestamp = "";

  OneMonth month = new OneMonth();
  OneDay day = new OneDay();
  Reading reading = new Reading();

  int prevMonth = 0;
  int curMonth = 0;
  String curYear = "";
  String prevDate = "";
  String curDate = "";
  String curTime = "";
  float curAvg = 0;
  int numReadings = 0;
  YearMonth ym = null;

  for (TableRow tr : table.rows()) {  // For each row
    // Get the data from the csv file and extract string into parts needed for visualization
    timestamp = tr.getString("time");
    curYear =  timestamp.substring(3, 7);
    curMonth =  Integer.parseInt(timestamp.substring(7, 9));   
    curDate =  timestamp.substring(9, 11);    
    curTime =  timestamp.substring(11, 13);
    curAvg = tr.getFloat("ave_mmh");
    numReadings = Integer.parseInt(tr.getString("n_readings"));

    // To get the number of days in the current month
    ym = YearMonth.of(Integer.parseInt(curYear), curMonth);

    if (curMonth != prevMonth) {

      // This is a new month
      month = new OneMonth();
      month.value = curMonth;
      prevMonth = curMonth;

      // Create first day for the month
      day = new OneDay();
      day.date = curDate;
      prevDate = curDate;

      // Create first reading of the day
      reading = new Reading();
      reading.avg = curAvg;
      reading.time = curTime;
      reading.numOfReadings = numReadings;

      day.readings.add(reading);
    } else {
      // This is the same month.
      if (curDate.equals(prevDate)) {
        // This is the same day. So, just create next reading.
        reading = new Reading();
        reading.avg = curAvg;
        reading.time = curTime;
        reading.numOfReadings = numReadings;

        day.readings.add(reading);
      } else {
        // This is a new day. Add day to month and create a new day.
        month.daysOfMonth.add(day);

        day = new OneDay();
        day.date = curDate;
        prevDate = curDate;

        // Create reading for the day.
        reading = new Reading();
        reading.avg = curAvg;
        reading.time = curTime;
        reading.numOfReadings = numReadings;

        day.readings.add(reading);
      }
    }

    // If it is the last day of the last hour of the month, add month to allMonths array list. 
    if (ym.lengthOfMonth() == Integer.parseInt(curDate) && curTime.equals("23")) {
      month.daysOfMonth.add(day);
      allMonths.add(month);
    }
  }
  // Just for chekcing 
  for (OneMonth thisMonth : allMonths) {
    print("month: "+thisMonth.value+", ");
  }
  drawData();
}

/* for drawing the graph outline */
void drawData() {
  background(screenColor); // Clearout the screen before drawing the next data

  OneMonth curMonth = allMonths.get(selMonth); // Get the month that will be used for visualization
  println(selMonth); // Just for checking
  // println("curMonth: "+curMonth.value);

  /* showing the data of rainfall averages per time in a day 
   and indicating which days have gotten the wrong readings */
  float x = 100f;
  float y = verticalscale +15;
  // Draw the data
  for (OneDay day : curMonth.daysOfMonth) {
    for (Reading reading : day.readings) {
      y = y + verticalscale;
      fill(0, 0, 255);
      circle(x, y, reading.avg);
      // Indicate readings were less than 48
      if (reading.numOfReadings < 48) {
        fill(255, 0, 0);
        line(x-7, y-7, x+7, y+7);
        line(x-7, y+7, x+7, y-7);
        fill(0, 102, 153);
        int captionLoc = 770 - keypadding;

        // Indicating wrong readings
        if (reading.numOfReadings == 40 || reading.numOfReadings == 16) {
          textSize(16);
          fill(255, 0, 0);
          text("*", leftMargin, captionLoc);
          fill(0, 0, 0);
          text("X indicates wrong readings less than 48", leftMargin + 10, captionLoc);
          
          // To show which days had wrong readings and its number
          //text("X indicates wrong reading less than 48. 2019-07-19 09:00 had ", leftMargin, captionLoc);
          //fill(255, 0, 0);
          //text("40 readings ", leftMargin + 378, captionLoc);
          //fill(0, 0, 0);
          //text("and 10:00 had ", leftMargin + 378 + 75, captionLoc);
          //fill(255, 0, 0);
          //text("16 readings", leftMargin + 378 + 75 + 89, captionLoc);
        } else if (reading.numOfReadings == 44 || reading.numOfReadings == 32) {
          textSize(16);
          fill(255, 0, 0);
          text("*", leftMargin, captionLoc);
          fill(0, 0, 0);
          text("X indicates wrong readings less than 48", leftMargin + 10, captionLoc);
          
          // To show which days had wrong readings and its number
          //text("X indicates wrong reading less than 48. 2020-01-26 21:00 had ", leftMargin, captionLoc);
          //fill(255, 0, 0);
          //text("32 readings ", leftMargin + 378, captionLoc);
          //fill(0, 0, 0);
          //text("and 22:00 had ", leftMargin + 378 + 75, captionLoc);
          //fill(255, 0, 0);
          //text("40 readings", leftMargin + 378 + 75 + 89, captionLoc);
        }
      }
    }
    x = x + horizontalspacing;
    y = verticalscale +15;
  }

  /* Graph title */
  pushMatrix();
  fill(0, 0, 0);
  textSize(30);
  text("< A Year Of Rain at BKC >", 500, 30);
  popMatrix();

  /* Labeling time */
  pushMatrix();
  float angle = radians(270);
  fill(0, 0, 0);
  textSize(25);
  translate(30, 380);
  rotate(angle);
  text("TIME", 0, 0);
  popMatrix();

  /* Labeling date */
  pushMatrix();
  fill(0, 0, 0);
  textSize(25);
  text("DATES", 630, 715);
  popMatrix();

  /* Show "date" avg/date graph date */
  x = 63f;
  y = 658 + verticalscale * 0.75f;

  for (OneDay day : curMonth.daysOfMonth) {
    x = x + horizontalspacing;
    line(x, topMargin, x, y-10);
    textSize(15);
    fill(0, 0, 0);
    text(day.date, x-6, y + 7);
  }

  /* Show "time" for avg/date graph */
  stroke(0);
  strokeWeight(0.5);
  int h = verticalscale +15;

  // The time repeats for each day, only need to retrieve it from one particular day
  OneDay thisDay = curMonth.daysOfMonth.get(0);
  for (Reading reading : thisDay.readings) {
    h =  h + verticalscale; 
    // Make the 'time' lines bit lighter than the day columns
    // Also make the color of each line different using only 2 colors to help understanding easily
    if (Integer.parseInt(reading.time) % 2 == 0) 
    { 
      stroke(190, 190, 0);
      line(leftMargin, h, width - leftMargin, h);
    } else {      
      stroke(210, 210, 210);
      line(leftMargin, h, width - leftMargin, h);
    }
    textSize(13);
    fill(0, 0, 0);
    text(reading.time, leftMargin-26, h + 4 );
    text(reading.time, 1300 -leftMargin + 15, h + 4 );
  }

  /* Draw a box for the key and indicating which month it shows */
  noFill();
  stroke(0);
  strokeWeight(1);
  rect(leftMargin, 780-keypadding, 1230-leftMargin, 80) ;
  float x1 = 140f;
  float y2 = 800f;
  textSize(15);
  fill(0, 0, 0);
  text("2019 ~", x1, y2-28);
  text("2020 ~", x1+(90*9)-3, y2-28);
  // Get the order of the months starting from April in a simple way and show
  for (int i = 0; i < monthnames.length; i++ ) {
    if ( i != selMonth) {
      textSize(25);
      fill(0, 0, 0);
      text(monthnames[i], x1, y2);
    }
    // Change the color of the month = highlighting which month is visualized
    else if (i == selMonth) {
      fill(0, 0, 255);
      println("selected one is : " + monthnames[i]);
      textSize(25);
      text(monthnames[selMonth], x1, y2);
    } 
    x1+=90;
  }

  /* Show toggle keys (just for showing) */
  fill(100, 100, 100);
  triangle(75, 790, 105, 760, 105, 820);
  triangle(1195, 760, 1195, 820, 1225, 790);
}

/* Use 'CODED' for key pressing */
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

/* By using Left and Right arrow keys, show the data for each month */
void codedKeyPressed() {
  // handle non-character keys
  // includes arrows UP, DOWN, LEFT, RIGHT, plus ALT, CONTROL, SHIFT
  switch( keyCode ) {
  case UP:
    break;
  case DOWN:
    break;
  case LEFT:
    selMonth--;
    drawData();
    break;
  case RIGHT:
    selMonth++;
    drawData();
    break;
  default:
    println("Key not implemented.");
  }
  println("selMonth: " + selMonth);
}

// Getting month easily instead of using 'switch()'
String getMonth(int month) {
  month--;
  if ( month <0 || month>=monthnames.length ) {
    return "NoMonth";
  } else {
    return monthnames[month];
  }
}

// Setting up a class for OneMonth
class OneMonth {
  String year = "";
  int value = 0;
  List<OneDay> daysOfMonth = new ArrayList<OneDay>();
}

// Setting up a class for OneDay
class OneDay {
  String date = "";
  List<Reading> readings = new ArrayList<Reading>();
}

// Setting up a class for Reading
class Reading {
  float avg = 0.0;
  String time = "";
  int numOfReadings = 0;
}
