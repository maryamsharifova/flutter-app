import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../screens/home_page.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;
  String? errorText;

  static const Color backgroundPink = Color(0xFFFFF6F9);
  static const Color pastelGreen = Color(0xFFE4F1E8);
  static const Color pastelPink = Color(0xFFD98FA6);
  static const Color darkText = Color(0xFF403238);
  static const Color lightText = Color(0xFF8C8085);

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: lightText),
      prefixIcon: Icon(icon, color: pastelPink, size: 22),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: pastelGreen,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFD3E5D8),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: pastelPink,
          width: 1.5,
        ),
      ),
    );
  }

  Future<void> signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorText = "Passwords don't match";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorText = null;
    });

    final error = await ref.read(authProvider.notifier).signUp(
          usernameController.text,
          passwordController.text,
        );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        isLoading = false;
        errorText = error;
      });
      return;
    }

    // Brand new user - no tasks yet, but this sets which user
    // future addTask calls should be saved under.
    final user = ref.read(authProvider);
    if (user != null) {
      await ref.read(taskProvider.notifier).loadTasksForUser(user.id);
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundPink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: pastelPink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add_alt_1,
                  size: 48,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "Get started",
                style: TextStyle(
                  color: pastelPink,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Sign Up",
                style: TextStyle(
                  color: darkText,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Create an account to save your tasks",
                style: TextStyle(
                  color: lightText,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 36),

              TextField(
                controller: usernameController,
                decoration: _fieldDecoration(
                  label: "Username",
                  icon: Icons.person_outline,
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: _fieldDecoration(
                  label: "Password",
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: lightText,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: confirmPasswordController,
                obscureText: obscurePassword,
                onSubmitted: (_) => signUp(),
                decoration: _fieldDecoration(
                  label: "Confirm Password",
                  icon: Icons.lock_outline,
                ),
              ),

              if (errorText != null) ...[
                const SizedBox(height: 14),
                Text(
                  errorText!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pastelPink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 18),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Already have an account? Login",
                  style: TextStyle(
                    color: pastelPink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}