import 'package:flutter/material.dart';
import 'package:inventory/admin/dashboard.dart';
import 'package:inventory/admin/scanner.dart';
import 'package:inventory/admin/profile.dart';
import 'package:inventory/admin/history.dart';

// 🔥 HALAMAN TAMBAHAN (PUSH PAGE)
import 'package:inventory/admin/items.dart';
import 'package:inventory/admin/category.dart';
import 'package:inventory/admin/user.dart';

class MainPage extends StatefulWidget {
  final String userName; // 👈 1. Tambahkan variabel penampung nama

  const MainPage({
    super.key,
    this.userName = "Admin", // 👈 Default nilai jika tidak dikirim
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  bool isProfileScreen = false; 

  // 🔑 Key untuk memaksa Dashboard reload data saat kembali dari halaman lain
  Key dashboardKey = UniqueKey();

  void refreshDashboard() {
    setState(() {
      dashboardKey = UniqueKey(); // Ganti key agar Dashboard merender ulang
    });
  }

  // 🔹 LIST PAGE UTAMA
  List<Widget> get pages => [
        Dashboard(
          key: dashboardKey, // Pass Key ke Dashboard
          onItemsTap: () async {
            // Tunggu (await) sampai user kembali dari halaman Items
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Items()),
            );
            refreshDashboard(); // 🔄 Refresh data setelah kembali
          },
          onCategoriesTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Category()),
            );
            refreshDashboard(); // 🔄 Refresh data setelah kembali
          },
          onUsersTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const User()),
            );
            refreshDashboard(); // 🔄 Refresh data setelah kembali
          },
        ),
        const Scanner(),
        const History(),
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

      // HEADER
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

                // PROFILE BUTTON
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

      // BODY
      // 👈 2. Kirim widget.userName ke ProfileScreen (hapus kata 'const' di depan ProfileScreen)
      body: isProfileScreen 
          ? ProfileScreen(userName: widget.userName) 
          : pages[currentIndex],

      // FLOATING BUTTON (SCAN)
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
              Text(
                "SCAN",
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ),
      ),

      // BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFD9D9D9),
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: isProfileScreen ? Colors.black54 : Colors.black, 
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