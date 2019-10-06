import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'history.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:random_string/random_string.dart';






UserLocation _currentLocation;
var location = Location();
List<String> coordinates;

class UserLocation {
  final double latitude;
  final double longitude;
  UserLocation({this.latitude, this.longitude});
}

class Homepage extends StatefulWidget {
  final String user;
  Homepage(this.user);
  @override
  HomepageState createState() => HomepageState(user);
}

/*void upload(String a) async {
  var url = "http://10.42.0.1:5000/hello";
  var response = await http.post(url, body: {'string': a});
  print(response);
}*/
String uniqueid(String img, String lat, String lon) {
  List uid = img.split("");
  uid.shuffle();
  String newstr = randomAlphaNumeric(15)+randomAlphaNumeric(10);


  return newstr;
}

void upload_server(
    String gid, String image, double lat, double lon, String user) async {
  String username = 'root';
  String password = '66224466';
  var str = jsonEncode({
    'grievance_id': gid,
    'area': 'unpredicted',
    'user_id': user,
    'image_link': image,
    'grievance_type': 'unpredicted',
    'latitude': lat.toString(),
    'longitude': lon.toString(),
    'assigned_authority': 'Anonymous',
    'status':'unsolved',
    'assigned_date': DateTime.now().toString(),
  });
  print(str);
  var url = "http://10.42.0.1:5000/grievance";
  String basicAuth = 'Basic cm9vdDo2NjIyNDQ2Ng==';
  print(basicAuth);

  var r = await http.post(url, body: str, headers: <String, String>{
    'authorization': basicAuth,
    HttpHeaders.contentTypeHeader: 'application/json'
  });
  print(r.statusCode);
  print(r.body);
  // var response = await http.post(url, body: body,headers: {HttpHeaders.authorizationHeader: "Basic cm9vdDo2NjIyNDQ2Ng==","Content-type": "application/json"},);
  // print(response.toString());
}

class HomepageState extends State<Homepage> {
  final String user;
  HomepageState(this.user);
  File _image;
  File image;
  void push(user) async {
    List<int> imageBytes = image.readAsBytesSync();
    String base64Image = base64.encode(imageBytes);
    //upload(base64Image);
    //print(base64Image);

    try {
      var userLocation = await location.getLocation();
      _currentLocation = UserLocation(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
      );
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }
    var lat = _currentLocation.latitude;
    var lon = _currentLocation.longitude;
    print('latitude: $lat, Longitude: $lon');
    print('$lat\n$lon\n$base64Image');

    String gid =
        uniqueid(base64Image.substring(1, 10), lat.toString(), lon.toString());
    upload_server(gid, base64Image, lat, lon, user);
    setState(() {
      _image = null;
    });
  }

  Future getImage() async {
    image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Align(
            alignment: Alignment.centerLeft,
              child: Text(
            'सहायक',
            style: TextStyle(fontSize: 30, fontFamily: 'Kalam'),
          )),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.history,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => history()),
                );
              },
            ),
            Container(
              padding: EdgeInsets.only(right: 10),
                child: Center(
              child: Row(
                children: <Widget>[Icon(Icons.account_circle,color: Colors.white,),Text('$user')],
              ),
            ))
          ],
        ),
        body: SingleChildScrollView(
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 25, left: 10, right: 10),
              decoration: BoxDecoration(border: Border.all()),
              height: 550,
              child: _image == null
                  ? Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.only(top: 150),
                              alignment: Alignment.center,
                              child: Icon(Icons.file_upload,
                                  size: 100, color: Colors.grey)),
                          Center(
                            child: Text(
                              'Upload grievance',
                              style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.grey[300],
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ))
                  : Image.file(
                      _image,
                    ),
            ),
            Align(
              alignment: Alignment.center,
              child: _image == null
                  ? IconButton(
                      onPressed: () {
                        getImage();
                      },
                      icon: Icon(
                        Icons.photo_camera,
                        size: 50.0,
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: FlatButton(
                                  child: Text('Upload'),
                                  color: Colors.transparent,
                                  textColor: Colors.blue,
                                  onPressed: () {
                                    print('\n\n\n\n\nuser:$user');
                                    push(user);
                                  },
                                )),
                          ),
                          Expanded(
                            flex: 2,
                            child: FlatButton(
                              child: Text('Cancel'),
                              color: Colors.transparent,
                              textColor: Colors.red,
                              onPressed: () {
                                setState(() {
                                  _image = null;
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    ),
            )
          ],
        ),
    )
    );
  }
}