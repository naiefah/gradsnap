import 'package:flutter/material.dart';
import '../pages/home_content.dart';  
import '../pages/mua_page.dart';
import '../pages/photographer_page.dart';
import '../pages/profile_page.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {

  int selectedIndex = 0;

  final List<Widget> pages = [

  const HomeContent(),

  const MuaPage(),

  const PhotographerPage(),

  const ProfilePage(),

];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: pages[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: selectedIndex,

        onTap: (index) {

          setState(() {
            selectedIndex = index;
          });

        },

        selectedItemColor: Colors.amber,

        type: BottomNavigationBarType.fixed,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.face),
            label: "MUA",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: "Photographer",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),

        ],
      ),
    );
  }
}