import 'package:flutter/material.dart';
import 'package:planeta_app/providers/auth_provider.dart';
import 'package:planeta_app/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // if login successed
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Login successed!")));

          // User will not go back to login screen when enter back
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        // Error
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Hata: ${e.toString()}")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // AuthProvider's isLoading
    final authLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset('assets/leaf_image.png', height: 100),
                const SizedBox(height: 30),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Enter your email';
                    if (!value.contains('@'))
                      return 'Please enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 4) {
                      return 'Minimum 4 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: authLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Login',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),

                // Register Navigation
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Register",
                    style: TextStyle(color: Colors.grey),
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
