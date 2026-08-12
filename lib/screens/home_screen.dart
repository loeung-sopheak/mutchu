import 'package:flutter/material.dart';
import 'package:flutter_application_2/colors.dart';
import 'package:flutter_application_2/screens/search_screen.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/supabase_auth_provider.dart';
import '../screens/cart_screen.dart';
import '../widgets/privacy.dart';
import '../widgets/profile_tab.dart';
import '../widgets/home_tab.dart';
import '../widgets/explore_tab.dart';
import 'login_screen.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const ExploreTab(),
    const SearchScreen(showBackButton: false,),
    const CartScreen(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<SupabaseAuthProvider>(context);
    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }

    return PrivacyScreen(
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _screens),
        bottomNavigationBar: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              decoration: BoxDecoration(
                color: MyColors.secondary,
                border: Border(
                  top: BorderSide(
                    width: 1.0,
                    color: Colors.grey.withValues(alpha: 0.3)
                  )
                )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home, Icons.home_outlined, 'Home', 0),
                  _buildNavItem(Icons.explore, Icons.explore_outlined, 'Explore', 1),
                  _buildNavItem(Icons.search_rounded, Icons.search_outlined, 'Search', 2),
                  _buildNavItem(
                    Icons.shopping_cart,
                    Icons.shopping_cart_outlined,
                    'Cart',
                    3,
                    badgeCount: cartProvider.items.length,
                  ),
                  _buildNavItem(Icons.person, Icons.person_outline, 'Profile', 4),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData iconActive,
    IconData iconInactive,
    String label,
    int index, {
      int badgeCount = 0
    }
  ) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedIndex = index;
          });
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.only(
            bottom: 25,
            top: 2,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween<double>(
                      begin: 1.0,
                      end: isSelected ? 1.2 : 1.0,
                    ),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.translate(
                        offset: Offset(0, 0),
                        child: Transform.scale(scale: scale, child: child),
                      );
                    },
                    child: Icon(
                      isSelected ? iconActive : iconInactive,
                      size: 22,
                      color: isSelected ? MyColors.primary_50 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'GintoBold',
                      fontSize: 10,
                      color: isSelected ? MyColors.primary_50 : Colors.grey,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              // badge chip
              if (badgeCount > 0)
                Positioned(
                  top: -5,
                  right: badgeCount > 1 ? (badgeCount > 90 ? 14 : 22) : 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    decoration: BoxDecoration(
                      color: MyColors.primary_50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'GintoRegNorm',
                      ),
                      textAlign: TextAlign.center,
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
