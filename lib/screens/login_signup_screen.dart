import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/login_screen.dart';
import 'package:flutter_application_2/screens/sign_up_screen.dart';
import '../colors.dart';

// import 'package:rive/rive.dart' as rive;

class LoginSignUpScreen extends StatefulWidget {
  const LoginSignUpScreen({super.key});

  @override
  State<LoginSignUpScreen> createState() => _LoginSignupScreen();
}

class _LoginSignupScreen extends State<LoginSignUpScreen> {
  // late Future<rive.RiveWidgetController?> _riveControllerFuture;

  @override
  void initState() {
    super.initState();
    
    // Pre-load the animation file into memory using the 0.14+ C++ decoder contract
    // _riveControllerFuture = _loadRiveAsset();
  }

  //   Future<rive.RiveWidgetController?> _loadRiveAsset() async {
  //     try {
  //       final file = await rive.File.asset(
  //         'assets/coffee1.riv',
  //         riveFactory: rive.Factory.rive, // Forces high-fidelity native engine
  //       );
  //       if (file != null) {
  //         return rive.RiveWidgetController(file);
  //       }
  //     } catch (e) {
  //       debugPrint("Rive initialization failed: $e");
  //     }
  //     return null;
  //   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              //   Expanded(
              //     child: FutureBuilder<rive.RiveWidgetController?>(
              //       future: _riveControllerFuture,
              //       builder: (context, snapshot) {
              //         if (snapshot.connectionState == ConnectionState.waiting) {
              //           return const Center(child: CupertinoActivityIndicator());
              //         }

              //         if (snapshot.hasData && snapshot.data != null) {
              //           return Container(
              //             color: Colors.transparent,
              //             child: rive.RiveWidget(
              //                 controller: snapshot.data!,
              //                 fit: rive.Fit.contain,
              //             ),
              //           );
              //         }

              //         // Safe graphical fallback if file path is missing in pubspec
              //         return const Center(
              //           child: Text(
              //             'Animation missing or path misconfigured',
              //             style: TextStyle(color: Colors.grey),
              //           ),
              //         );
              //       },
              //     ),
              //   ),
              CupertinoButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => const SignUpScreen(),
                    ),
                  );
                },
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                minimumSize: Size(100, 50),
                child: const Text(
                  "Sign Up with Phone Number",
                  style: TextStyle(
                    color: MyColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                color: Colors.transparent,
                height: MediaQuery.of(context).size.height / 5,
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      color: MyColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      minimumSize: Size(100, 50),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: MyColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    SizedBox(width: 30),

                    CupertinoButton(
                      onPressed: () {},
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      minimumSize: Size(100, 50),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: MyColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
