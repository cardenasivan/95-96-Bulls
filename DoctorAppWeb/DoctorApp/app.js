var express = require("express");
var app = express();
var path = require("path");
var firebase = require("firebase");
var bodyParser = require('body-parser');
var nodemailer = require('nodemailer');
var request = require('request');

// intialize bodyparser
app.use(bodyParser.json());       // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({     // to support URL-encoded bodies
    extended: true
})); 

// initialize firebase
var config = {
    serviceAccount: "C:\Users\\wil.stephens\\Downloads\\DoctorApp-52e7cef89c53.json",
    databaseURL: "https://doctorapp-bfed0.firebaseio.com/"
};
firebase.initializeApp(config);

// serve files
app.use(express.static(path.join(__dirname + "/public")));

// routes
app.get('/', function (req, res) {
    res.sendFile(path.join(__dirname + "/views/index.html"));
});

app.post('/login', function (req, res) {
    var db = firebase.database();
    var ref = db.ref("/");
    ref.once("value", function (snapshot) {
        var dbValue = snapshot.val();
        for (var key in dbValue["patients"]) {
            var dbEntrys = dbValue["patients"][key];
            if (dbEntrys["email"] === req.body.email) {
                    res.sendFile(path.join(__dirname + "/views/patientDashboard.html"));
            }
        }
        for (var key in dbValue["medicalStaff"]) {
            var dbEntrys = dbValue["medicalStaff"][key];
            if (dbEntrys["email"] === req.body.email) {
                res.sendFile(path.join(__dirname + "/views/medicalStaffDashboard.html"));
            }
        }
    });
});

app.post('/createFhirUser', function (req, res) {
    var fhirUser = {
        resourceType: "Patient",
        id: req.body.patientID,
        name: [
            {
                family: [req.body.lastName],
                given: [req.body.firstName, req.body.middleInitial]
            }
        ],
        telecom: [
            {
                system: "phone",
                value: req.body.phoneNumber,
            },
            {
                system: "email",
                value: req.body.emailAddress
            }
        ],
        address: [
            {
                use: "home",
                line: [req.body.addressOne],
                city: req.body.city,
                state: req.body.state,
                postalCode: req.body.zipCode
            }
        ],
        gender: req.body.gender
    };
    fhirUser = JSON.stringify(fhirUser);

    request({
        url: 'https://fhir-open-api-dstu2.smarthealthit.org/Patient/' + req.body.patientID, //URL to hit
        method: 'PUT', //Specify the method
        headers: { //We can define headers too
            'Content-Type': 'application/json',
        },
        body: fhirUser
    }, function (error, response, body) {
        if (error) {
            res.json({ response: 'error' });
        } else {
            res.sendFile(path.join(__dirname + "/views/patientRegistrationSuccess.html"));
        }
    });

});

app.get('/patientRegistration', function (req, res) {
    res.sendFile(path.join(__dirname + "/views/patientRegistration.html"));
});

app.get('/medicalStaffDashboard', function (req, res) {
    res.sendFile(path.join(__dirname + "/views/medicalStaffDashboard.html"));
});

app.get('/medicalStaffCreateUser', function (req, res) {
    res.sendFile(path.join(__dirname + "/views/medicalStaffCreateUser.html"));
});

app.get('/patientDashboard', function (req, res) {
    res.sendFile(path.join(__dirname + "/views/patientDashboard.html"));
});

app.post("/createUser", function (req, res) {
    var tempID = Math.floor((Math.random() * 10000) + 10000);
    var db = firebase.database();
    var ref = db.ref("/");
    var patientsRef = ref.child("patients");
    var newPatientsRef = patientsRef.push();
    newPatientsRef.set({ email: req.body.email, patientID: tempID}, function (error) {
        if (!error) {
            var transporter = nodemailer.createTransport({
                service: 'Gmail',
                auth: {
                    user: "dsiteamhackaton@gmail.com", // Your email id
                    pass: "DSIdsi_1" // Your password
                }
            });
            var tempID = Math.floor((Math.random() * 10000) + 10000);
            var text = "Welcome to Patient Link! A temporary account has been created with these credentials!\nPatientID: " + tempID + "\nTemporary Password: " + req.body.temporaryPassword;
            var mailOptions = {
                from: 'dsiteamhackaton@gmail.com', // sender address
                to: req.body.email, // list of receivers
                subject: 'Patient Link - Account Created', // Subject line
                text: text //, // plaintext body
            };
            transporter.sendMail(mailOptions, function (error, info) {
                if (error) {
                    console.log("Message error: " + error);
                    res.json({ response: 'error' });
                } else {
                    console.log('Message sent: ' + info.response);
                    res.sendFile(path.join(__dirname + "/views/medicalStaffCreateUserSuccess.html"));
                };
            });
        }
    });
});

// start server
app.listen(3000, function () {
    console.log('Example app listening on port 3000!');
});