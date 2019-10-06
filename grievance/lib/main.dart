import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:random_string/random_string.dart';

void main(List<String> args) {
  runApp(
    MaterialApp(
      home: Login(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
