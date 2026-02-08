import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketnest/config/supabase_config.dart';
import 'package:pocketnest/core/navigation/cubit/app_flow_cubit.dart';
import 'package:pocketnest/core/theme/app_theme.dart';
import 'package:pocketnest/features/auth/screens/auth_screen.dart';
import 'package:pocketnest/features/splash/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable runtime font fetching — use only bundled/local fonts
  GoogleFonts.config.allowRuntimeFetching = false;

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await SupabaseService.initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AppFlowCubit(supabaseClient: SupabaseService.client)
                ..initializeApp(),
        ),
      ],
      child: const PocketNestApp(),
    ),
  );
}

class PocketNestApp extends StatelessWidget {
  const PocketNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PocketNest',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AppFlowCubit, AppFlowState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _buildScreen(context, state),
          );
        },
      ),
    );
  }

  Widget _buildScreen(BuildContext context, AppFlowState state) {
    if (state is SplashState) {
      return const SplashScreen();
    } else if (state is UnauthenticatedState) {
      return const AuthScreen();
    } else if (state is ProfileIncompleteState) {
      // TODO: Implement profile completion screen
      return Scaffold(
        appBar: AppBar(title: const Text('Complete Your Profile')),
        body: const Center(child: Text('Profile Completion Screen')),
      );
    } else if (state is AuthenticatedState) {
      // TODO: Implement home/main screen
      return Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: const Center(child: Text('Main App Screen')),
      );
    } else if (state is AppFlowErrorState) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('An error occurred'),
              const SizedBox(height: 16),
              Text(state.message),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.read<AppFlowCubit>().initializeApp();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return const SplashScreen();
  }
}
