import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/cart_provider.dart';
import 'providers/supabase_auth_provider.dart';
import 'providers/tab_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/functions.dart';
import 'package:provider/provider.dart';
import 'widgets/privacy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final supabasePubKey = dotenv.env['SUPABASE_ANON_KEY']!;
  
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePubKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SupabaseAuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),  
        ChangeNotifierProvider(create: (_) => TabProvider()),
      ],
    child:  const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey,
        home: PrivacyScreen(
          child: const SplashScreen()
        ),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.green,
        ),
      );
  }
}
