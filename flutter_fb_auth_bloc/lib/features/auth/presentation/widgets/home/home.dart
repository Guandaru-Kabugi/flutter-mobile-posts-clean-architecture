import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fb_auth_bloc/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:flutter_fb_auth_bloc/features/auth/presentation/views/auth_intermediary/signinorlogin.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    animation = Tween<double>(begin: 0, end: 400).animate(controller)
      ..addListener(() {
        setState(() {}); // Triggers rebuild to reflect animation value
      });

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  final state = context.watch<AuthBloc>().state;
  final isLoggedIn = state is AuthLoginSuccessState;

  return Scaffold(
    backgroundColor: Colors.grey[100],
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            Text(
              isLoggedIn
                  ? 'Hi, ${state.userCredential.user!.email}'
                  : 'Welcome 👋',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Discover posts and explore content easily',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const Spacer(),

            
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + (controller.value * 0.2),
                  child: Opacity(
                    opacity: controller.value,
                    child: child,
                  ),
                );
              },
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    'https://tse4.mm.bing.net/th/id/OIP.j4oq-4C2nkvqkb0_wiRZnQHaE8?r=0&rs=1&pid=ImgDetMain&o=7&rm=3',
                    height: 220,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // 🔹 Button
            if (!isLoggedIn)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => WelcomePage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}
}
