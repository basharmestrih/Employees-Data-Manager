import 'package:flutter/material.dart';
import 'package:flutter_application_1/BozpakPage.dart';
import 'package:flutter_application_1/DashboardPage.dart';
import 'package:flutter_application_1/DataBase.dart';
import 'package:flutter_application_1/HomePage.dart';
import 'package:google_fonts/google_fonts.dart';

class Startpage extends StatelessWidget {
  const Startpage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Employee Management',
          style: GoogleFonts.pompiere(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        backgroundColor: Colors.grey[350],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildCard(
                    context,
                    icon: Icons.person_add,
                    text: 'Add New Employee',
                    destination: HomePage(),
                  ),
                  buildCard(
                    context,
                    icon: Icons.list,
                    text: 'View Employees List',
                    destination: DatabaseScreen(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildCard(
                    context,
                    icon: Icons.receipt_long,
                    text: 'Add/Show Bills',
                    destination: Bozpakpage(),
                  ),
                  buildCard(
                    context,
                    icon: Icons.dashboard,
                    text: 'Dashboard',
                    destination: Dashboardpage(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(BuildContext context, {required IconData icon, required String text, required Widget destination}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.height * 0.35,
      child: Card(
        color: Colors.blue[800],
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pompiere(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}