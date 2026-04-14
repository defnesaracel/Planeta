import 'dart:math';

import 'package:flutter/material.dart';

import 'package:planeta_app/providers/survey_provider.dart';

import 'package:planeta_app/screens/history_screen.dart';

import 'package:planeta_app/screens/login_screen.dart';

import 'package:planeta_app/screens/survey_screen.dart';

import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

 final List<Map<String, String>> quotes = [

    {"text": "The greatest threat to our planet is the belief that someone else will save it.", "author": "Robert Swan"},
    {"text": "What is tended becomes a garden, what is neglected becomes a wild.","author": "Turkish Proverb"},
    {"text": "Look deep into nature, and then you will understand everything better.","author": "Albert Einstein"},
    {"text": "Live simply so that others may simply live.","author": "Elizabeth Ann Seton"},
    {"text": "Earth provides enough to satisfy every man's needs, but not every man's greed.", "author": "Mahatma Gandhi"},

  ];

    final randomQuote = quotes[Random().nextInt(quotes.length)];



class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {

    final surveyProvider = context.watch<SurveyProvider>();

  final authProvider = context.watch<AuthProvider>();

  final uid = authProvider.user?.uid;

if (uid != null) {

  // PostFrameCallback kullanarak build işlemi bittikten sonra veriyi çekiyoruz

  WidgetsBinding.instance.addPostFrameCallback((_) {

    context.read<SurveyProvider>().checkDailyStatus(uid);

  });

}
    return Scaffold(

      backgroundColor: Colors.white,

      body: SafeArea(

        child: Padding(

          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.center,

            children: [

              //Logo

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



             //Quote

Container(

  width: double.infinity,

  padding: const EdgeInsets.all(20),

  decoration: BoxDecoration(

    color: const Color(0xFFF1F8E9),

    borderRadius: BorderRadius.circular(15),

    border: Border.all(color: const Color(0xFFC8E6C9)),

  ),

  child: Column(

    children: [

      const Icon(Icons.format_quote, color: Color(0xFF2E7D32)),

      const SizedBox(height: 10),

      Text(

        "\"${randomQuote['text']}\"", // Rastgele metin buraya geliyor

        textAlign: TextAlign.center,

        style: const TextStyle(

          fontSize: 16,

          fontStyle: FontStyle.italic,

          color: Color(0xFF2E7D32),

        ),

      ),

      const SizedBox(height: 10),

      Text(

        "- ${randomQuote['author']}", // Yazar buraya geliyor

        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B5E20),

        ),

      ),

    ],

  ),

),



              //Menu Cards

              // home_screen.dart içinde _buildMenuCard kullanımını güncelle



_buildMenuCard(
  context,
  icon: Icons.assignment_outlined,

  title: "Daily Survey",

  subtitle: surveyProvider.alreadyFilledToday

      ? "Come back tomorrow!"

      : "Complete today’s survey",

  onTap: () async {

    final provider = Provider.of<SurveyProvider>(context, listen: false);

   

    if (provider.alreadyFilledToday) {

      // Hakkı dolmuşsa mesaj göster

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text("You've already completed today's survey! 🌱"),
          backgroundColor: Color(0xFF1B5E20),
          behavior: SnackBarBehavior.floating,

        ),

      );

    } else {

      Navigator.push(

        context,
        MaterialPageRoute(builder: (context) => const SurveyScreen()),

      );

    }

  },

),

              const SizedBox(height: 20),
              _buildMenuCard(
                context,
                icon: Icons.history_outlined,
                title: "My History",
                subtitle: "View your achievements",
                onTap: () {

                  // UC4: History Screen navigator

                  Navigator.push(

    context,
    MaterialPageRoute(builder: (context) => const HistoryScreen()),

  );

                 

                },

              ),



              const Spacer(),



              //Logout

              TextButton.icon(

                onPressed: () async {

                  await context.read<AuthProvider>().signOut();



                  // navigate user back to login screen

                  if (context.mounted) {

                    Navigator.pushAndRemoveUntil(

                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),

                      ),

                      (route) => false,

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