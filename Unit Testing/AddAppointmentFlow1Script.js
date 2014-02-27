/*
 Use Case: Add Appointment
 Flow: 1 (Default information + description entered)
 
 Staring point: Beginning of app
 Precondition: No events in calendar
 Postcondition: Event added
 */

//TODO: This one is weird, finish it
#import "Tuneup JS/tuneup_js/tuneup.js" 

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();
var staticTable = window.tableViews()[0];
var titleCell = staticTable.cells()[0];
var descriptionCell = staticTable.cells()[1];
var startCell = staticTable.cells()[2];
var appointmentTitle = "New Appointment";

//Get to Add Appointment View
app.navigationBar().tapWithOptions({tapOffset:{x:0.98, y:0.22}});
app.actionSheet().buttons()["Add Appointment"].tap();

//Enter title
titleCell.textFields()[0].tap();
app.keyboard().typeString(appointmentTitle);


//Enter description
descriptionCell.textFields()[0].tap();
app.keyboard().typeString("This is a test");

//Choose start time
target.frontMostApp().mainWindow().tableViews()[0].cells()[2].tap();

var startTimePickerCell = staticTable.cells()[3];
var startPicker = startTimePickerCell.pickers()[0];
startPicker.wheels()[0].selectValue("Tues Feb 25");
startPicker.wheels()[1].selectValue("9");
startPicker.wheels()[2].selectValue("00");
startPicker.wheels()[3].selectValue("AM");
target.frontMostApp().mainWindow().tableViews()[0].cells()[2].tap();

//Assert that end time moved to one hour after start time

//Choose end time
target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()[4].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[3].pickers()[0].wheels()[0].selectValue("Tues Feb 25");
target.frontMostApp().mainWindow().tableViews()[0].cells()[3].pickers()[0].wheels()[1].selectValue("10");
target.frontMostApp().mainWindow().tableViews()[0].cells()[3].pickers()[0].wheels()[2].selectValue("30");
target.frontMostApp().mainWindow().tableViews()[0].cells()[3].pickers()[0].wheels()[3].selectValue("AM");
target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()[4].tap();

//Click done
app.navigationBar().rightButton().tap();

//Assuming no other appointments, so check first cell in events table
var newAppointmentCellEvent = window.tableViews()[1].cells()[0].name();

//Test title and start time
test("Testing new appointment title displayed", function(target, app) {
  assertEquals(newAppointmentCellEvent,"New Appointment, Feb 25, 2014 9:00 AM", "Mismatch between new appointment and first event displayed");
});

