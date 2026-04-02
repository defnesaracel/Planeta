import 'package:flutter/material.dart';
import 'package:planeta_app/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Üst Kısım: Logo ve Başlık
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF1B5E20),
                child: Icon(Icons.eco_outlined, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                "Planeta",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 40),

              // 2. Daily Quote Bölümü (Yeni Eklendi)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9), // Çok açık yeşil
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.format_quote, color: Color(0xFF2E7D32)),
                    SizedBox(height: 10),
                    Text(
                      "\"The greatest threat to our planet is the belief that someone else will save it.\"",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "- Robert Swan",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 3. Menü Kartları
              _buildMenuCard(
                context,
                icon: Icons.assignment_outlined,
                title: "Daily Survey",
                subtitle: "Complete today’s survey",
                onTap: () {
                  // UC3: Survey Screen yönlendirmesi buraya gelecek
                },
              ),
              const SizedBox(height: 20),
              _buildMenuCard(
                context,
                icon: Icons.history_outlined,
                title: "My History",
                subtitle: "View your achievements",
                onTap: () {
                  // UC4: History Screen yönlendirmesi buraya gelecek
                },
              ),

              const Spacer(),

              // 4. Çıkış Yap Butonu (Opsiyonel ama gerekli)
              TextButton.icon(
                onPressed: () async {
                  // 1. Çıkış işlemini başlat
                  await context.read<AuthProvider>().signOut();

                  // 2. Kullanıcıyı giriş ekranına geri gönder ve arkadaki tüm sayfaları temizle
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) =>
                          false, // Geri tuşuyla tekrar Home'a dönülmesini engeller
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF1B5E20), size: 28),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
