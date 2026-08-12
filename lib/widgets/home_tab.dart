import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../colors.dart';
import '../models/drink_model.dart';
import '../models/food_model.dart';
import '../providers/cart_provider.dart';
// import '../screens/login_screen.dart';
import '../screens/search_screen.dart';
import '../services/supabase_service.dart';
import 'animated_scale.dart';
import 'category_chip.dart';
import 'drink_card.dart';
import 'food_card.dart';
import '../skeletons/home_tab_skeleton.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _selectedCategoryFoods = 'All';
  String _selectedCategoryDrinks = 'All';
  String _selectedTagPastries = 'All';
  List<String> _favorites = [];
  List<Food> _foods = [];
  List<Food> _pastries = [];
  List<Drink> _drinks = [];
  bool _isLoading = true;
  final FocusNode _searchFocus = FocusNode();
  final FocusNode _promoFocus = FocusNode();

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadAllItems();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadAllItems() async {
    setState(() => _isLoading = true);

    try {
      // Load drinks
      final drinks = await SupabaseService().getDrinks();
      // Load foods
      final foods = await SupabaseService().getFoodsByCategory('Dine');
      // Load pastries
      final pasties = await SupabaseService().getFoodsByCategory('Pastry');

      setState(() {
        _drinks = drinks;
        _foods = foods;
        _pastries = pasties;
        _isLoading = false;
      });

      _refreshController.refreshCompleted();
    } catch (e) {
      print('Error loading items: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      _favorites = favorites;
    });
  }

  Future<void> _toggleFavorite(String drinkId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(drinkId)) {
        _favorites.remove(drinkId);
      } else {
        _favorites.add(drinkId);
      }
      prefs.setStringList('favorites', _favorites);
    });
  }

  List<Drink> get _filteredDrinks {
    if (_selectedCategoryDrinks == 'All') {
      return _drinks;
    }
    return _drinks
        .where((drink) => drink.category == _selectedCategoryDrinks)
        .toList();
  }

  List<Food> get _filteredFoods {
    if (_selectedCategoryFoods == 'All') {
      return _foods;
    }
    return _foods
        .where((food) => food.category == _selectedCategoryFoods)
        .toList();
  }

  List<Food> get _filteredPastries {
    if (_selectedTagPastries == 'All') {
      return _pastries;
    }
    return _pastries
        .where((pastry) => pastry.tags.contains(_selectedTagPastries))
        .toList();
  }

  void _quickAddToCartDrink(Drink drink) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    cartProvider.addDrink(
      drink: drink,
      quantity: 1,
      size: 'M',
      sugarLevel: '100%',
      iceLevel: 'Regular',
      addOn: null,
      specialInstructions: null,
      totalPrice: drink.price,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${drink.name} added to cart!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _quickAddToCartFood(Food food) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    cartProvider.addFood(
      food: food,
      quantity: 1,
      size: 'Regular',
      addOn: null,
      specialInstructions: null,
      totalPrice: food.price,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${food.name} added to cart!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverAppBar(
            automaticallyImplyLeading: false,
            floating: true,
            pinned: true,
            backgroundColor: innerBoxIsScrolled
                ? Colors.white
                : MyColors.primary,
            elevation: 0,
            toolbarHeight: 110,
            flexibleSpace: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              color: innerBoxIsScrolled
                  ? MyColors.secondary
                  : MyColors.primary,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/Mutchu_Logo_${!innerBoxIsScrolled ? 'White' : 'Green'}.svg',
                            width: 30,
                            height: 30,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Discover your favorite matcha~',
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'GintoRegNorm',
                              color: !innerBoxIsScrolled
                                  ? MyColors.secondary
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 60),
                          IconButton(
                            icon: Icon(
                              Icons.favorite_border,
                              color: !innerBoxIsScrolled
                                  ? MyColors.secondary
                                  : MyColors.primary,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AnimatedScaleWidget(
                        focusNode: _searchFocus,
                        onTap: () {},
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: !innerBoxIsScrolled
                                ? MyColors.secondary
                                : MyColors.primary,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: MyColors.primary_50.withAlpha(50),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SearchScreen(),
                                  fullscreenDialog: true,
                                ),
                              );
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: !innerBoxIsScrolled
                                    ? MyColors.secondary
                                    : MyColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.search_rounded,
                                    color: innerBoxIsScrolled
                                        ? MyColors.secondary.withValues(
                                            alpha: 0.8,
                                          )
                                        : MyColors.primary,
                                    size: 23,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Search matcha drinks and foods...',
                                    style: TextStyle(
                                      color: innerBoxIsScrolled
                                          ? MyColors.secondary.withValues(
                                              alpha: 0.8,
                                            )
                                          : MyColors.primary,
                                      fontFamily: 'GintoRegNorm',
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.tune,
                                    color: innerBoxIsScrolled
                                        ? MyColors.secondary.withValues(
                                            alpha: 0.8,
                                          )
                                        : MyColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ];
      },
      body: _isLoading
          ? const HomeTabSkeleton()
          : SmartRefresher(
              controller: _refreshController,
              onRefresh: _loadAllItems,
              header: BezierHeader(
                bezierColor: MyColors.primary,
              ),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 80),
                children: [
                  // ===== PROMO BANNER =====
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: AnimatedScaleWidget(
                      focusNode: _promoFocus,
                      onTap: () {},
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [MyColors.primary, Color(0xFF4CAF50)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.shade300.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -27,
                              bottom: 0,
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Image.asset(
                                    "assets/icons/promo_icon.png",
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.hourglass_top_rounded,
                                          size: 15,
                                          color: MyColors.secondary,
                                        ),
                                        const Text(
                                          'SPECIAL OFFER',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontFamily: 'GintoRegNorm',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    '25% OFF Matcha Latte',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight(700),
                                      fontFamily: 'GintoBold',
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Use code: MATCHA25',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontFamily: 'GintoRegNorm',
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Order Now →',
                                      style: TextStyle(
                                        color: Color(0xFF2E7D32),
                                        fontFamily: 'GintoRegNorm',
                                        fontSize: 11,
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
                  ),
                  const SizedBox(height: 16),

                  // ===== PASTRY CATEGORIES =====
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pastries',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'GintoBold',
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  setState(() => _selectedTagPastries = 'All'),
                              child: const Text(
                                'See All',
                                style: TextStyle(
                                  color: MyColors.primary,
                                  fontSize: 12,
                                  fontFamily: 'GintoRegNorm',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 34,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            CategoryChip(
                              label: 'All',
                              icon: '',
                              isSelected: _selectedTagPastries == 'All',
                              onTap: () =>
                                  setState(() => _selectedTagPastries = 'All'),
                            ),
                            const SizedBox(width: 10),
                            CategoryChip(
                              label: 'Dubai Collection',
                              icon: '',
                              isSelected:
                                  _selectedTagPastries == 'Dubai Collection',
                              onTap: () => setState(
                                () => _selectedTagPastries = 'Dubai Collection',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ===== PASTRIES GRID =====
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: MyColors.primary,
                        ),
                      ),
                    )
                  else if (_filteredPastries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: Text('No foods found')),
                    )
                  else
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredPastries.length,
                        itemBuilder: (context, index) {
                          final food = _filteredPastries[index];
                          return SizedBox(
                            width: 175,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: FoodCard(
                                food: food,
                                isFavorite: _favorites.contains(food.id),
                                onFavorite: () => _toggleFavorite(food.id),
                                onAddToCart: () => _quickAddToCartFood(food),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),

                  // ===== FOOD CATEGORIES =====
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Foods',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'GintoBold',
                              ),
                            ),
                            TextButton(
                              onPressed: () => setState(
                                () => _selectedCategoryFoods = 'All',
                              ),
                              child: const Text(
                                'See All',
                                style: TextStyle(
                                  color: MyColors.primary,
                                  fontSize: 12,
                                  fontFamily: 'GintoRegNorm',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 34,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            CategoryChip(
                              label: 'All',
                              icon: '',
                              isSelected: _selectedCategoryFoods == 'All',
                              onTap: () => setState(
                                () => _selectedCategoryFoods = 'All',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ===== FOODS GRID =====
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: MyColors.primary,
                        ),
                      ),
                    )
                  else if (_filteredFoods.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: Text('No foods found')),
                    )
                  else
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredFoods.length,
                        itemBuilder: (context, index) {
                          final food = _filteredFoods[index];
                          return SizedBox(
                            width: 175,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: FoodCard(
                                food: food,
                                isFavorite: _favorites.contains(food.id),
                                onFavorite: () => _toggleFavorite(food.id),
                                onAddToCart: () => _quickAddToCartFood(food),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),

                  // ===== DRINK CATEGORIES =====
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Drinks',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'GintoBold',
                              ),
                            ),
                            TextButton(
                              onPressed: () => setState(
                                () => _selectedCategoryDrinks = 'All',
                              ),
                              child: const Text(
                                'See All',
                                style: TextStyle(
                                  color: MyColors.primary,
                                  fontSize: 12,
                                  fontFamily: 'GintoRegNorm',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 34,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            CategoryChip(
                              label: 'All',
                              icon: '',
                              isSelected: _selectedCategoryDrinks == 'All',
                              onTap: () => setState(
                                () => _selectedCategoryDrinks = 'All',
                              ),
                            ),
                            const SizedBox(width: 8),
                            CategoryChip(
                              label: 'Latte',
                              icon: '',
                              isSelected: _selectedCategoryDrinks == 'Latte',
                              onTap: () => setState(
                                () => _selectedCategoryDrinks = 'Latte',
                              ),
                            ),
                            const SizedBox(width: 8),
                            CategoryChip(
                              label: 'Mocktail',
                              icon: '',
                              isSelected: _selectedCategoryDrinks == 'Mocktail',
                              onTap: () => setState(
                                () => _selectedCategoryDrinks = 'Mocktail',
                              ),
                            ),
                            const SizedBox(width: 8),
                            CategoryChip(
                              label: 'Cocktail',
                              icon: '',
                              isSelected: _selectedCategoryDrinks == 'Cocktail',
                              onTap: () => setState(
                                () => _selectedCategoryDrinks = 'Cocktail',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ===== DRINKS GRID =====
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: MyColors.primary,
                        ),
                      ),
                    )
                  else if (_filteredDrinks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: Text('No drinks found')),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.60,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _filteredDrinks.length,
                      itemBuilder: (context, index) {
                        final drink = _filteredDrinks[index];
                        return DrinkCard(
                          drink: drink,
                          isFavorite: _favorites.contains(drink.id),
                          onFavorite: () => _toggleFavorite(drink.id),
                          onAddToCart: () => _quickAddToCartDrink(drink),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
