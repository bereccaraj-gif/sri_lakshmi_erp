import 'package:flutter/material.dart';

void main() {
  runApp(const CollegeApp());
}

class CollegeApp extends StatelessWidget {
  const CollegeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Sri Lakshmi ERP",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}

// ---------------- DATA ----------------

final admin = {"username": "admin", "password": "admin123"};

final List<Map<String, String>> students = [
  for (var dept in ["BCA", "BCOM", "BA"])
    for (int i = 1; i <= 10; i++)
      {
        "regno": "${dept}00$i",
        "name": "$dept Student$i",
        "password": "pass$i",
        "dept": dept
      }
];

final List<Map<String, String>> teachers = [
  for (var dept in ["BCA", "BCOM", "BA"])
    for (int i = 1; i <= 10; i++)
      {
        "name": "$dept Teacher$i",
        "password": "teach$i",
        "dept": dept
      }
];

final subjects = {
  "BCA": ["Programming", "DBMS", "Web"],
  "BCOM": ["Accounting", "Economics", "Law"],
  "BA": ["History", "English", "Political"]
};

final attendance = {
  for (var s in students)
    s["regno"]!: {
      for (var sub in subjects[s["dept"]]!) sub: "75%"
    }
};

final marks = {
  for (var s in students)
    s["regno"]!: {
      for (var sub in subjects[s["dept"]]!) sub: "80"
    }
};

List<String> notices = ["Holiday Tomorrow"];
List<String> assignments = ["Submit Assignment"];
List<String> sports = ["Football Match"];
List<String> fees = ["Fees Paid"];

// ---------------- LOGIN ----------------

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String role = "Student";
  String dept = "BCA";

  final id = TextEditingController();
  final name = TextEditingController();
  final pass = TextEditingController();

  void login() {
    if (role == "Admin") {
      if (id.text == admin["username"] && pass.text == admin["password"]) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AdminPage()));
      }
    } else if (role == "Student") {
      final user = students.firstWhere(
          (s) =>
              s["regno"] == id.text &&
              s["password"] == pass.text &&
              s["dept"] == dept,
          orElse: () => {});
      if (user.isNotEmpty) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => StudentPage(user: user)));
      }
    } else {
      final user = teachers.firstWhere(
          (t) =>
              t["name"] == name.text &&
              t["password"] == pass.text &&
              t["dept"] == dept,
          orElse: () => {});
      if (user.isNotEmpty) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => FacultyPage(user: user)));
      }
    }
  }

  Widget input(String hint, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
            hintText: hint,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue, Colors.purple])),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text("SRI LAKSHMI COLLEGE",
                    style: TextStyle(color: Colors.white, fontSize: 22)),
                DropdownButton(
                  value: role,
                  items: ["Admin", "Student", "Faculty"]
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => role = v!),
                ),
                if (role == "Faculty")
                  input("Name", name)
                else
                  input("ID", id),
                input("Password", pass),
                if (role != "Admin")
                  DropdownButton(
                    value: dept,
                    items: ["BCA", "BCOM", "BA"]
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => dept = v!),
                  ),
                ElevatedButton(onPressed: login, child: const Text("LOGIN"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- DASHBOARD CARD ----------------

Widget card(BuildContext c, IconData i, String t, Widget p) {
  return GestureDetector(
    onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => p)),
    child: Card(
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(i, size: 40), Text(t)],
      ),
    ),
  );
}

// ---------------- STUDENT ----------------

class StudentPage extends StatelessWidget {
  final Map user;
  const StudentPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    String reg = user["regno"];
    return Scaffold(
      appBar: AppBar(
        title: Text(user["name"]),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const LoginPage())))
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          card(context, Icons.bar_chart, "Attendance",
              DataPage(attendance[reg]!)),
          card(context, Icons.book, "Marks", DataPage(marks[reg]!)),
          card(context, Icons.assignment, "Assignments",
              ListPage(assignments)),
          card(context, Icons.sports_soccer, "Sports", ListPage(sports)),
          card(context, Icons.money, "Fees", ListPage(fees)),
          card(context, Icons.notifications, "Notices",
              ListPage(notices)),
        ],
      ),
    );
  }
}

// ---------------- FACULTY ----------------

class FacultyPage extends StatefulWidget {
  final Map user;
  const FacultyPage({super.key, required this.user});

  @override
  State<FacultyPage> createState() => _FacultyPageState();
}

class _FacultyPageState extends State<FacultyPage> {
  String dept = "BCA";
  String subject = "Programming";
  String? reg;
  final ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var deptStudents =
        students.where((s) => s["dept"] == dept).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Faculty ${widget.user["name"]}")),
      body: Column(
        children: [
          DropdownButton(
            value: dept,
            items: subjects.keys
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => dept = v!),
          ),
          DropdownButton(
            value: subject,
            items: subjects[dept]!
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => subject = v!),
          ),
          DropdownButton(
            hint: const Text("Select Student"),
            value: reg,
            items: deptStudents
                .map((s) => DropdownMenuItem(
                    value: s["regno"], child: Text(s["name"]!)))
                .toList(),
            onChanged: (v) => setState(() => reg = v),
          ),
          TextField(
              controller: ctrl,
              decoration:
                  const InputDecoration(labelText: "Attendance %")),
          ElevatedButton(
              onPressed: () {
                if (reg != null) {
                  setState(() {
                    attendance[reg]![subject] = ctrl.text;
                  });
                }
              },
              child: const Text("SAVE"))
        ],
      ),
    );
  }
}

// ---------------- ADMIN ----------------

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: ListView(
        children: [
          const ListTile(title: Text("Students")),
          ...students.map((s) => ListTile(
              title: Text(s["name"]!),
              subtitle: Text("${s["regno"]} - ${s["dept"]}"))),
          const Divider(),
          const ListTile(title: Text("Teachers")),
          ...teachers.map((t) => ListTile(
              title: Text(t["name"]!),
              subtitle: Text(t["dept"]!))),
        ],
      ),
    );
  }
}

// ---------------- DATA PAGE ----------------

class DataPage extends StatelessWidget {
  final Map data;
  const DataPage(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Details")),
      body: ListView(
        children: data.entries
            .map((e) =>
                ListTile(title: Text(e.key), trailing: Text(e.value)))
            .toList(),
      ),
    );
  }
}

// ---------------- LIST PAGE ----------------

class ListPage extends StatelessWidget {
  final List<String> list;
  const ListPage(this.list, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Details")),
      body: ListView(
        children: list.map((e) => ListTile(title: Text(e))).toList(),
      ),
    );
  }
}