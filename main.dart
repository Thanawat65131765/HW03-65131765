import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'users.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/userform': (context) => const UserForm(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      drawer: const SideMenu(),
      body: const Center(
        child: Text("Home Page"),
      ),
    );
  }
}

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    String accountName = "Thanawat Kinglek";
    String accountEmail = "kinglektanawat@gmail.com";
    String accountUrl =
        "https://scontent.fbkk6-2.fna.fbcdn.net/v/t39.30808-6/271444132_314831697215190_5174919754216671402_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeHa69-dTZXCZIGGw4ZbeqZJGCgVE9oxT4cYKBUT2jFPh9pdcCipfsnyoVJJMX51mXTCfvPpWmiJzpyN8Fiwqg3Q&_nc_ohc=Z3mh7A8HN54Q7kNvgFO6ceD&_nc_ht=scontent.fbkk6-2.fna&oh=00_AYCZjzCo4VWPeNQ6gnX24gX3Za6tvEftVZSaW-vpS-SfJg&oe=66D0ECCD";

    Users user = Configure.login;

    if (user.id != null) {
      accountName = user.fullname!;
      accountEmail = user.email!;
    }

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(accountName),
            accountEmail: Text(accountEmail),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(accountUrl),
              backgroundColor: Colors.white,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context); // กลับไปหน้า Home
            },
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text("Login"),
            onTap: () {
              Navigator.pushNamed(context, '/login'); // นำทางไปหน้าล็อกอิน
            },
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/userform');
          },
          child: const Text("Go to User Form"),
        ),
      ),
    );
  }
}

class Configure {
  static String server =
      "192.168.1.112:3000"; // แก้ไขเป็น URL ของเซิร์ฟเวอร์คุณ
  static List<String> gender = ["None", "Male", "Female", "Other"];

  static Users login = Users(); // เพิ่ม Users เพื่อใช้งานใน SideMenu
}

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  late Users user;

  @override
  Widget build(BuildContext context) {
    try {
      user = ModalRoute.of(context)!.settings.arguments as Users;
      print(user.fullname);
    } catch (e) {
      user = Users();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Form"),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              fnameInputField(),
              emailInputField(),
              passwordInputField(),
              genderFormInput(),
              const SizedBox(
                height: 10,
              ),
              submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget fnameInputField() {
    return TextFormField(
      initialValue: user.fullname,
      decoration: const InputDecoration(
        labelText: "Fullname",
        icon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return "This field is required";
        }
        return null;
      },
      onSaved: (newValue) => user.fullname = newValue,
    );
  }

  Widget emailInputField() {
    return TextFormField(
      initialValue: user.email,
      decoration: const InputDecoration(
        labelText: "Email",
        icon: Icon(Icons.email),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "This field is required";
        }
        return null;
      },
      onSaved: (newValue) => user.email = newValue,
    );
  }

  Widget passwordInputField() {
    return TextFormField(
      initialValue: user.password,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: "Password",
        icon: Icon(Icons.lock),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "This field is required";
        }
        return null;
      },
      onSaved: (newValue) => user.password = newValue,
    );
  }

  Widget submitButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          print(user.toJson().toString());
          if (user.id == null) {
            addNewUser(user);
          } else {
            updateData(user);
          }
        }
      },
      child: const Text("Save"),
    );
  }

  Widget genderFormInput() {
    var initGen = "None";
    try {
      if (user.gender != null) {
        initGen = user.gender!;
      }
    } catch (e) {
      initGen = "None";
    }
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "Gender",
        icon: Icon(Icons.person),
      ),
      value: initGen,
      items: Configure.gender.map((String val) {
        return DropdownMenuItem(
          value: val,
          child: Text(val),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() {
          user.gender = value;
        });
      },
      onSaved: (newValue) => user.gender = newValue,
    );
  }

  Future<void> addNewUser(Users user) async {
    var url = Uri.http(Configure.server, "users");
    var resp = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );
    var rs = usersFromJson("[${resp.body}]");
    if (rs.length == 1) {
      Navigator.pop(context, "refresh");
    }
  }

  Future<void> updateData(Users user) async {
    var url = Uri.http(Configure.server, "user/${user.id}");
    var resp = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );
    var rs = usersFromJson("[${resp.body}]");
    if (rs.length == 1) {
      Navigator.pop(context, "refresh");
    }
  }
}
