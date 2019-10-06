import 'package:flutter/material.dart';
import 'home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


import './home.dart';
import './register.dart';
String user;
Map<String, dynamic> rt;
bool login_not = false;
// ({"$and": [{"$or":[{"username": username},{"phone": username}]}, {"password": password}]})
Future<http.Response> fetchPost(username, password, context) async {
  String basicAuth = 'Basic cm9vdDo2NjIyNDQ2Ng==';
  var response = await http.get(
      'http://10.42.0.1:5000/grievance_users?where={"\$and":[{"user_email":"$username"},{"user_password":"$password"}]}',
      headers: <String, String>{
        'authorization': basicAuth,
        "Accept": "application/json"
      });
  rt = jsonDecode(response.body);
  print('\n\n\n\n\n\ndata:' + rt['_items'].toString());
  if (rt['_items'].toString() == '[]') {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: Center(
                child: Text(
              'Invalid credentials',
              textAlign: TextAlign.center,
            )),
            content: Container(
              height: 80,
              child: Column(
                children: <Widget>[
                  Center(
                      child: Text(
                    'Please Enter valid credentials',
                    textAlign: TextAlign.center,
                  )),
                  Divider(),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: FlatButton(
                        child: Text(
                          'Okay',
                          style: TextStyle(color: Colors.blue, fontSize: 18),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ))
                ],
              ),
            )));
  } else {
    user=rt['_items'][0]['user_name'];
    print('\n\n\n\n\n$user');
    login_not = true;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Homepage(user)),
    );
  }
}

class Login extends StatelessWidget {
  final username = TextEditingController();
  final password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(login_not==false){
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body:SingleChildScrollView( 
      child:Container(
        child: Column(
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(top: 150),
                child: Center(
                    child: Column(
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      padding: EdgeInsets.only(top: 10),
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
                              fontSize: 60,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'सहायक',
                        style: TextStyle(fontSize: 35, fontFamily: 'Kalam'),
                      ),
                    )
                  ],
                ))),
            Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: TextField(
                          controller: username,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 15),
                              labelText: 'Email or phone',
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
                        child: FlatButton(
                          child: Align(
                              child: Text('Forget password?'),
                              alignment: Alignment.centerRight),
                          textColor: Colors.blue,
                          onPressed: () {
                            print('Forget');
                          },
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
                              child: Text('Log in'),
                              onPressed: () {
                                fetchPost(
                                    username.text, password.text, context);
                              },
                            ),
                          )),
                      Container(
                        margin: EdgeInsets.only(top: 18),
                        child: Text(
                          'Or',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Container(
                        child: FlatButton(
                          child: Text('Register now'),
                          textColor: Colors.blue,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Register()),
                            );
                          },
                        ),
                      ),
                      Container(
                        child: FlatButton(
                          child: Text("skip login"),
                          textColor:  Colors.blueGrey,
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder:  (context) => Homepage(user)),);
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
      )
    );
    }
    else{
      return Homepage(user);
    }
  }
}
