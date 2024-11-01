import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MenuPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30,),

            Center(
                child: Text('FHIR Resource Manager', style: TextStyle(fontSize: 30),)
            ),

            SizedBox(height: 30,),

            ElevatedButton(
                onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePage()),);},
                child: Text('Create', style: TextStyle(fontSize: 30),)
            ),

            SizedBox(height: 30,),

            ElevatedButton(
                onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => ReadPage()),);},
                child: Text('Read', style: TextStyle(fontSize: 30),)
            ),

            SizedBox(height: 30,),

            ElevatedButton(
                onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePage()),);},
                child: Text('Update', style: TextStyle(fontSize: 30),)
            ),

            SizedBox(height: 30,),

            ElevatedButton(
                onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => DeletePage()),);},
                child: Text('Delete', style: TextStyle(fontSize: 30),)
            ),

            SizedBox(height: 30,),

            ElevatedButton(
                onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()),);},
                child: Text('Search', style: TextStyle(fontSize: 30),)
            ),

          ],
        )
      )
    );
  }
}

class CreatePage extends StatelessWidget {
  CreatePage({super.key});
  int id = 0;
  final firstname = TextEditingController();
  final lastname = TextEditingController();
  final gender = TextEditingController();
  final DOB = TextEditingController();

  String _response = '';
  Future<void> FHIRCreate() async {
    final url = 'https://launch.smarthealthit.org/v/r4/fhir/Patient';
    final headers = {'Content-Type': 'application/fhir+json'};
    final body = json.encode({
      "resourceType": "Patient",
      "meta": {
        "versionId": "1",
        //-----------------------------------------------
        "lastUpdated": DateTime.now().toIso8601String()
        //-----------------------------------------------
      },
      "text": {
        "status": "generated",
        "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\">firstname.text + " " + lastname.text</div>"
      },
      "name": [
        {
          "use": "official",
          "text": firstname.text + " " + lastname.text,
          "family": lastname.text,
          "given": [
            firstname.text
          ]
        }
      ],
      "gender": gender.text,
      "birthDate": DOB.text
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);
      _response = 'Status: ${response.statusCode}\nBody: ${response.body}';
      print("Status Code" + response.statusCode.toString());
    }

    catch (e) {
      _response = 'Error: $e';
      print(_response.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create'),
        leading: IconButton(
          onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => MenuPage()),);},
          icon: Icon(Icons.logout),
        ),
      ),

      body: Column(
        children: [
          SizedBox(height: 30,),

          TextField(
            controller: firstname,
            decoration: InputDecoration(hintText: "First Name"),
          ),

          SizedBox(height: 30,),

          TextField(
            controller: lastname,
            decoration: InputDecoration(hintText: "Last Name"),
          ),

          SizedBox(height: 30,),

          TextField(
            controller: DOB,
            decoration: InputDecoration(hintText: "Date of Birth (YYYY-MM-DD)"),
          ),

          SizedBox(height: 30,),

          TextField(
            controller: gender,
            decoration: InputDecoration(hintText: "Gender"),
          ),

          SizedBox(height: 30,),

          ElevatedButton(
              onPressed: (){
                var rng = Random();
                id = rng.nextInt(500000) + 250000;
                FHIRCreate();
              },
              child: Text('Create Patient', style: TextStyle(fontSize: 30),)
          )
        ],
      ),
    );
  }
}

class ReadPage extends StatelessWidget {
  ReadPage({super.key});

  Map<String, dynamic>? patientData;
  final id = TextEditingController();
  Future<void> fetchPatientData(id) async {
    final url = 'https://launch.smarthealthit.org/v/r4/fhir/Patient/' + id.text;
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      patientData = json.decode(response.body);
      print (response.statusCode);
    }
    else {
      print (response.statusCode);
    }
    throw Exception('Failed to load patient data');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Read'),
        leading: IconButton(
          onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => MenuPage()),);},
          icon: Icon(Icons.logout),
        ),
      ),

      body: Column(
        children: [
          TextField(
            controller: id,
            decoration: InputDecoration(hintText: "ID"),
          ),

          SizedBox(height: 30,),

          ElevatedButton(
              onPressed: (){
                fetchPatientData(id);
                Future.delayed(Duration(seconds: 2), (){
                  print(patientData!["resourceType"]);
                  print(patientData!["id"]);
                  print(patientData!["name"][0]["text"]);
                  print(patientData!["name"][0]["family"]);
                  print(patientData!["name"][0]["given"][0]);
                  print(patientData!["gender"]);
                  print(patientData!["birthDate"]);
                });
              },
              child: Text('Read', style: TextStyle(fontSize: 30),)
          )
        ],
      )
    );
  }
}

class UpdatePage extends StatelessWidget {
  UpdatePage({super.key});

  final id = TextEditingController();
  final familyName = TextEditingController();
  final givenName = TextEditingController();
  final gender = TextEditingController();
  final birthDate = TextEditingController();

  Future<void> updatePatientData(id) async {
    final String apiUrl = 'https://launch.smarthealthit.org/v/r4/fhir/Patient/' + id.text;
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'resourceType': 'Patient',
        'id': id.text,
        'meta': {
          'versionId': '1',
          'lastUpdated': DateTime.now().toIso8601String(),
        },
        'text': {
          'status': 'generated',
          'div': '<div xmlns="http://www.w3.org/1999/xhtml">${givenName.text + familyName.text}</div>',
        },
        'name': [
          {
            'use': 'official',
            'text': givenName.text + familyName.text,
            'family': familyName.text,
            'given': [givenName.text],
          }
        ],
        'gender': gender.text,
        'birthDate': birthDate.text,
      }),
    );

    if (response.statusCode == 200) {
      print ('Success');
    }
    else{
      print('Code: ' + (response.statusCode).toString());
    }
    throw Exception('Failed to load patient data');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update'),
        leading: IconButton(
          onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => MenuPage()),);},
          icon: Icon(Icons.logout),
        ),
      ),

      body: Column(
        children: [
          SizedBox(height: 30,),

          TextField(
            controller: id,
            decoration: InputDecoration(hintText: "ID"),
          ),

          SizedBox(height: 30,),

          TextField(
            controller: givenName,
            decoration: InputDecoration(hintText: "First Name"),
          ),

          SizedBox(height: 30,),

          TextField(
            controller: familyName,
            decoration: InputDecoration(hintText: "Last Name"),
          ),

          SizedBox(height: 30,),

          TextField(
            controller: birthDate,
            decoration: InputDecoration(hintText: "Date of Birth (YYYY-MM-DD)"),
          ),

          SizedBox(height: 30,),

          TextField(
            controller: gender,
            decoration: InputDecoration(hintText: "Gender"),
          ),

          SizedBox(height: 30,),

          ElevatedButton(
              onPressed: (){
                updatePatientData(id);
              },
              child: Text('Update Patient', style: TextStyle(fontSize: 30),)
          )
        ],
      ),
    );
  }
}

class DeletePage extends StatelessWidget {
  DeletePage({super.key});

  final id = TextEditingController();
  Future<void> deletePatient(id) async {
    final String url = 'https://launch.smarthealthit.org/v/r4/fhir/Patient/' + id.text;

    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        // Successful response
        print('Patient deleted successfully.');
      } else {
        // Handle unsuccessful response
        print('Failed to delete patient. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle error
      print('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete'),
        leading: IconButton(
          onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => MenuPage()),);},
          icon: Icon(Icons.logout),
        ),
      ),

        body: Column(
          children: [
            TextField(
              controller: id,
              decoration: InputDecoration(hintText: "ID"),
            ),

            SizedBox(height: 30,),

            ElevatedButton(
                onPressed: (){
                  deletePatient(id);
                },
                child: Text('Delete', style: TextStyle(fontSize: 30),)
            )
          ],
        )
    );
  }
}

class SearchPage extends StatelessWidget {
  SearchPage({super.key});

  List<Map<String, String>> _patients = [];
  final id = TextEditingController();
  final firstname = TextEditingController();
  final lastname = TextEditingController();
  final gender = TextEditingController();
  final DOB = TextEditingController();
  Future<void> searchPatientData() async {
    String url = 'https://launch.smarthealthit.org/v/r4/fhir/Patient?';

    if (id.text != '') {
      url = url + '&_id=' + id.text;
    }
    if (firstname.text != '') {
      url = url + '&given=' + firstname.text;
    }
    if (lastname.text != '') {
      url = url + '&family=' + lastname.text;
    }
    if (gender.text != '') {
      url = url + '&gender=' + gender.text;
    }
    if (DOB.text != '') {
      url = url + '&birthdate=' + DOB.text;
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      for (var entry in data['entry']) {
        final resource = entry['resource'];
        final name = resource['name'][0];

        final id = resource['id'];
        final given = name['given'][0];
        final family = name['family'];
        final gender = resource['gender'];
        final birthDate = resource['birthDate'];

        print('ID: $id');
        print('Given Name: $given');
        print('Family Name: $family');
        print('Gender: $gender');
        print('Birth Date: $birthDate');
      }
    }
    else {
      print(response.statusCode);
    }
    throw Exception('Failed to load patient data');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        leading: IconButton(
          onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => MenuPage()),);},
          icon: Icon(Icons.logout),
        ),
      ),

      body: Column(
        children: [
          SizedBox(height: 30,),

          TextField(
            controller: id,
            decoration: InputDecoration(hintText: "ID"),
          ),

          SizedBox(height: 30,),

          TextField(
            controller: firstname,
            decoration: InputDecoration(hintText: "First Name"),
          ),

          SizedBox(height: 30,),

          TextField(
            controller: lastname,
            decoration: InputDecoration(hintText: "Last Name"),
          ),

          SizedBox(height: 30,),

          TextField(
            controller: DOB,
            decoration: InputDecoration(hintText: "Date of Birth (YYYY-MM-DD)"),
          ),

          SizedBox(height: 30,),

          TextField(
            controller: gender,
            decoration: InputDecoration(hintText: "Gender"),
          ),

          SizedBox(height: 30,),

          ElevatedButton(
              onPressed: (){
                searchPatientData();
              },
              child: Text('Search', style: TextStyle(fontSize: 30),)
          )
        ],
      ),

    );
  }
}