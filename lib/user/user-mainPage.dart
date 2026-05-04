import 'package:flutter/material.dart';

// 🔹 HALAMAN USER
import 'user-dashboard.dart';
import 'user-scanner.dart';
import 'user-history.dart';
import 'user-profile.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({super.key});

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  int currentIndex = 0;
  bool isProfileScreen = false;

  // 🔹 LIST PAGE USER
  List<Widget> get pages => [
        const UserDashboard(),
        const UserScanner(),
        const UserHistory(),
      ];

  void goToProfile() {
    setState(() {
      isProfileScreen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // 🔥 HEADER (SAMA)
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Image(
                      image: AssetImage('assets/images/Logo.png'),
                      width: 50,
                      height: 50,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "INVENTORY",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: goToProfile,
                  icon: Icon(
                    Icons.person_outline,
                    size: 28,
                    color: isProfileScreen ? Colors.blue : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // 🔥 BODY
      body: isProfileScreen
          ? const UserProfile()
          : pages[currentIndex],

      // 🔥 FLOATING BUTTON
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              currentIndex = 1;
              isProfileScreen = false;
            });
          },
          backgroundColor: Colors.black,
          shape: const CircleBorder(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.qr_code_scanner, color: Colors.white),
              Text("SCAN", style: TextStyle(fontSize: 10, color: Colors.white)),
            ],
          ),
        ),
      ),

      // 🔥 BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFD9D9D9),
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor:
            isProfileScreen ? Colors.black54 : Colors.black,
        unselectedItemColor: Colors.black54,
        onTap: (index) {
          setState(() {
            currentIndex = index;
            isProfileScreen = false;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'DASHBOARD',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'HISTORY',
          ),
        ],
      ),
    );
  }
}