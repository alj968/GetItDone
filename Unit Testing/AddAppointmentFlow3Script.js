/*
 Use Case: Add Appointment
 Flow: 3 (Just title entered)
 
 Staring point: Beginning of app
 Precondition: No events in calendar
 Postcondition: Event added
 */

#import "Tuneup JS/tuneup_js/tuneup.js" 

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();
var staticTable = window.tableViews()[0];
var titleCell = staticTable.cells()[0];
var appointmentTitle = "New Appointment";

//Get to Add Appointment View
app.navigationBar().tapWithOptions({tapOffset:{x:0.98, y:0.22}});
app.actionSheet().buttons()["Add Appointment"].tap();

//Enter title
titleCell.textFields()[0].tap();
app.keyboard().typeString(appointmentTitle);

//Click done
app.navigationBar().rightButton().tap();

//Assuming no other appointments, so checks first cell in events table
var eventsTable = window.tableViews()[1];
var newAppointmentCellEvent = eventsTable.cells()[0].name();

//Only test title since time will change depending on current time
test("Testing new appointment title displayed", function(target, app) {
  assertEquals(newAppointmentCellEvent.substring(0,15), appointmentTitle, "New apppointment title not first in events table");
});