import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/user_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/new_order_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/lookups_management_screen.dart';
import 'screens/patron_reports_screen.dart';
import 'screens/manager_reports_screen.dart';
import 'screens/restaurant_selection_screen.dart';
import 'screens/config_management_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/payment_success_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Milky Shaky',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple,
          primaryColor: Color(0xFF667eea),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFF667eea),
            primary: Color(0xFF667eea),
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: AppBarTheme(
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: SplashScreen(),
        onGenerateRoute: (settings) {
          if (settings.name == '/payment') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => PaymentScreen(),
              settings: settings,
            );
          }
          
          // Default routes
          return null; 
        },
        routes: {
          '/auth': (context) => AuthScreen(),
          '/home': (context) => HomeScreen(),
          '/order': (context) => NewOrderScreen(),
          '/restaurants': (context) => RestaurantSelectionScreen(),
          '/payment': (context) => PaymentScreen(),
          '/profile': (context) => ProfileScreen(),
          '/history': (context) => OrderHistoryScreen(),
          '/lookups': (context) => LookupsManagementScreen(),
          '/reports/patron': (context) => PatronReportsScreen(),
          '/reports/manager': (context) => ManagerReportsScreen(),
          '/config': (context) => ConfigManagementScreen(),
          '/payment-success': (context) => const PaymentSuccessScreen(),

        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    _controller.forward();
    
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.loadUserFromPrefs();
    
    await Future.delayed(Duration(seconds: 2));
    
    if (mounted) {
      if (userProvider.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/auth');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _animation,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.local_drink,
                    size: 80,
                    color: Color(0xFF667eea),
                  ),
                ),
              ),
              SizedBox(height: 32),
              FadeTransition(
                opacity: _animation,
                child: Column(
                  children: [
                    Text(
                      'Milky Shaky',
                      style: GoogleFonts.pacifico(
                        fontSize: 48,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Delicious milkshakes delivered',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
