import 'package:flutter/material.dart';
import 'package:inventory/dashboard.dart';
import 'package:inventory/scanner.dart';
import 'package:inventory/profile.dart'; // Pastikan nama import sesuai
import 'package:inventory/history.dart';

// 🔥 HALAMAN TAMBAHAN (PUSH PAGE)
import 'package:inventory/items.dart';
import 'package:inventory/category.dart';
import 'package:inventory/user.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  
  // 🔥 TAMBAHKAN VARIABLE INI
  // Untuk mengecek apakah kita sedang membuka halaman profil atau tidak
  bool isProfileScreen = false; 

  // 🔹 LIST PAGE UTAMA (CUMA 3)
  List<Widget> get pages => [
        Dashboard(
          onItemsTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Items()),
            );
          },
          onCategoriesTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Category()),
            );
          },
          onUsersTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const User()),
            );
          },
        ),
        const Scanner(),
        const History(),
      ];

  // 🔹 NAVIGASI PROFILE (DIPERBAIKI)
  void goToProfile() {
    // Jangan gunakan Navigator.push. Ubah saja state-nya.
    setState(() {
      isProfileScreen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // 🔥 HEADER (TETAP)
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

                // 🔹 PROFILE BUTTON
                IconButton(
                  onPressed: goToProfile,
                  // Ubah warna icon jika sedang di halaman profile
                  icon: Icon(
                    Icons.person_outline, 
                    size: 28, 
                    color: isProfileScreen ? Colors.blue : Colors.black, // Opsi tambahan agar user tahu sedang aktif
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // 🔥 BODY (DIPERBAIKI)
      // Jika isProfileScreen true, tampilkan ProfileScreen.
      // Jika false, tampilkan halaman dari Bottom Nav (pages[currentIndex]).
      body: isProfileScreen ? const ProfileScreen() : pages[currentIndex],

      // 🔥 FLOATING BUTTON (SCAN)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              currentIndex = 1;
              isProfileScreen = false; // Matikan mode profile saat menekan SCAN
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

      // 🔥 BOTTOM NAV (CUMA 3 MENU)
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFD9D9D9),
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        // Hapus warna biru dari bottom nav jika sedang di halaman profil
        selectedItemColor: isProfileScreen ? Colors.black54 : Colors.black, 
        unselectedItemColor: Colors.black54,
        onTap: (index) {
          setState(() {
            currentIndex = index;
            isProfileScreen = false; // Matikan mode profile saat pindah tab bawah
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