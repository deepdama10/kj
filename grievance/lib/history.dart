import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

var rtlen = 0;
Map<String, dynamic> rt;


Future<http.Response> fetchPost() async {
  String basicAuth = 'Basic cm9vdDo2NjIyNDQ2Ng==';
  var response = await http.get('http://10.42.0.1:5000/grievance',
      headers: <String, String>{
        'authorization': basicAuth,
        "Accept": "application/json"
      });
  rt = jsonDecode(response.body);
  rtlen = rt["_meta"]["total"];
  
}

class history extends StatelessWidget {
  history() {
    fetchPost();
  }
  List<Widget> getitem() {
    List<Widget> list = new List<Widget>();
    try {
      if (rtlen>0){
        for (var i = 0; i < rtlen-1; i++) {
          list.add(Column(
            children: <Widget>[Text('$i')],
          ));
        }
      }
      else{
        Text("No Histroy to display. ");
      }
      
    }
    on Exception {
        Text("No Histroy to display. ");
    }
    
    return list;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Text('Submitted grievances')),
        body: Container(
          child: ListView.builder(
            itemCount: rtlen,
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 13),
                title: Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                            color: Colors.black38,
                            offset: Offset(5, 5),
                            blurRadius: 10.0)
                      ]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                        child: Image.memory(base64Decode(
                            rt['_items'][index]['image_link'].toString())),
                      ),
                    ),
                    Align(
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.location_on, color: Colors.black),
                          Container(
                              padding: EdgeInsets.only(
                                  top: 3, bottom: 3, left: 3, right: 20),
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(25))),
                              child: Text(
                                rt['_items'][index]['area'].toString(),
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                ),
                              ))
                        ],
                      ),
                    )
                  ],
                ),
                subtitle: Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black38,
                            offset: Offset(5, 5),
                            blurRadius: 10.0)
                      ],
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.sort,
                        size: 22,
                      ),
                      Text(rt['_items'][index]['grievance_type'].toString(),
                          style: TextStyle(fontSize: 20, color: Colors.black)),
                      Flexible(fit: FlexFit.tight, child: SizedBox()),
                      Text(rt['_items'][index]['status'].toString(),
                          style: TextStyle(fontSize: 15, color: Colors.black54)),
                      Icon(
                        Icons.calendar_today,
                        size: 17,
                        color: Colors.black54,
                      ),
                      Text(rt['_items'][index]['assigned_date'].toString(),
                          style: TextStyle(fontSize: 15, color: Colors.black54))
                    ],
                    
                  ),
                ),
              );
            },
          ),
        ));
  }
}
