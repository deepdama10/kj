import 'package:flutter/material.dart';
import 'package:grievances/login.dart';
import 'package:http/http.dart' as http;
import 'history.dart';
import 'dart:convert';
import 'dart:io';

var rt = 0;

void upload(name, phone, email, password) async {
  var str = jsonEncode({
    'user_id': 234234.toString(),
    'user_name': name.toString(),
    'user_phone': phone.toString(),
    'user_email': email.toString(),
    'user_password': password.toString()
  });
  var url = "http://10.42.0.1:5000/grievance_users";
  String basicAuth = 'Basic cm9vdDo2NjIyNDQ2Ng==';
  print(basicAuth);

  var r = await http.post(url, body: str, headers: <String, String>{
    'authorization': basicAuth,
    HttpHeaders.contentTypeHeader: 'application/json'
  });

  print(r.statusCode);
  if (r.statusCode == 201) {
    rt = 1;
  }
}

class Register extends StatefulWidget {
  @override
  _RegisterState createState() {
    return _RegisterState();
  }
}

class _RegisterState extends State<Register> {
  final name = TextEditingController();

  final phone = TextEditingController();

  final email = TextEditingController();

  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: 30),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 50, bottom: 10),
              child: Center(
                  child: Column(
                children: <Widget>[
                  Container(
                    width: 60,
                    height: 60,
                    padding: EdgeInsets.only(top: 7),
                    decoration: new BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'स',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Kalam',
                            fontSize: 35,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'सहायक',
                      style: TextStyle(fontSize: 25, fontFamily: 'Kalam'),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Text('Create your account',
                        style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 30)),
                  )
                ],
              )),
            ),
            Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: TextField(
                          controller: name,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 15),
                              labelText: 'Full name',
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)))),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: TextField(
                          controller: email,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 15),
                              labelText: 'Email Id',
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)))),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: TextField(
                          controller: phone,
                          keyboardType: TextInputType.numberWithOptions(),
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 15),
                              labelText: 'Phone',
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)))),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: TextField(
                          controller: password,
                          obscureText: true,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 15),
                              labelText: 'Password',
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey[300]),
                              ),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)))),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 15),
                              labelText: 'Confirm Password',
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey[300]),
                              ),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)))),
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 20),
                          child: SizedBox(
                            width: double.infinity,
                            child: RaisedButton(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(8.0),
                              ),
                              color: Colors.blue,
                              textColor: Colors.white,
                              child: Text('Sign up'),
                              onPressed: () {
                                print('\n\n\n\n\n\nsent data:' +
                                    name.text +
                                    '\n' +
                                    phone.text +
                                    '\n' +
                                    email.text +
                                    '\n' +
                                    password.text);
                                upload(name.text, phone.text, email.text,
                                    password.text);
                                if (rt == 1) {
                                  print("checked return");
                                  MaterialPageRoute(
                                    builder: (context) => Login(),
                                  );
                                }
                              },
                            ),
                          )),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: FlatButton(
                          child: Text('Back to login'),
                          textColor: Colors.blue,
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    ));
  }
}
