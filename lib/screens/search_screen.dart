// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/drink_model.dart';
import '../models/food_model.dart';
import '../providers/cart_provider.dart';
import '../services/supabase_service.dart';
import '../colors.dart';

class SearchScreen extends StatefulWidget {
  final bool showBackButton;

  const SearchScreen({super.key, this.showBackButton = true});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  
  List<Drink> _allDrinks = [];
  List<Food> _allFoods = [];
  List<Drink> _popularDrinks = [];
  List<Food> _popularFoods = [];
  List<String> _recentSearches = [];
  List<String> _popularSearches = [];
  
  List<dynamic> _searchResults = [];
  bool _isLoading = true;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _loadAllItems();
    _loadRecentSearches();
    _loadPopularSearches();
    
    _searchFocus.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadAllItems() async {
    setState(() => _isLoading = true);
    try {
      final drinks = await SupabaseService().getDrinks();
      final foods = await SupabaseService().getFoods();
      
      // Get popular items from Supabase
      final popularData = await SupabaseService().getPopularItems();
      
      final popularDrinks = <Drink>[];
      final popularFoods = <Food>[];
      
      for (var data in popularData) {
        if (data['item_type'] == 'drink') {
          final drink = drinks.firstWhere(
            (d) => d.id == data['item_id'],
            orElse: () => throw Exception('Drink not found'),
          );
          popularDrinks.add(drink);
        } else {
          final food = foods.firstWhere(
            (f) => f.id == data['item_id'],
            orElse: () => throw Exception('Food not found'),
          );
          popularFoods.add(food);
        }
      }
      
      setState(() {
        _allDrinks = drinks;
        _allFoods = foods;
        _popularDrinks = popularDrinks;
        _popularFoods = popularFoods;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading items: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList('recent_searches') ?? [];
    setState(() {
      _recentSearches = searches;
    });
  }

  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  Future<void> _loadPopularSearches() async {
    // You can fetch from Supabase or use default list
    final defaultSearches = ['Matcha Latte', 'Iced Coffee', 'Cheesecake', 'Croissant', 'Matcha Cake'];
    setState(() {
      _popularSearches = defaultSearches;
    });
  }

  void _searchItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _showResults = false;
        _searchResults = [];
      } else {
        _showResults = true;
        
        // Search drinks
        final drinks = _allDrinks
            .where((drink) =>
                drink.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
        
        // Search foods
        final foods = _allFoods
            .where((food) =>
                food.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
        
        _searchResults = [...drinks, ...foods];
      }
    });
  }

  void _saveSearch(String query) {
    if (query.trim().isEmpty) return;
    
    setState(() {
      // Remove if already exists
      _recentSearches.remove(query);
      // Add to front
      _recentSearches.insert(0, query);
      // Keep only last 5
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast();
      }
      _saveRecentSearches();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _showResults = false;
      _searchResults = [];
    });
    _searchFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            onChanged: _searchItems,  // Still shows results as you type
            onSubmitted: (value) {    // Only saves when user presses "Search" / Enter
              _saveSearch(value);
            },
            style: const TextStyle(fontSize: 16, fontFamily: 'GintoRegNorm'),
            decoration: InputDecoration(
              hintText: 'Search matcha drinks and foods...',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontFamily: 'GintoRegNorm',
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.grey[400],
                size: 26,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 10,
              ),
            ),
          ),
        ),
        automaticallyImplyLeading: widget.showBackButton,
        leading: widget.showBackButton ? IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: MyColors.primary_50,
          ),
          onPressed: () => Navigator.pop(context),
        ) : null,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: MyColors.primary),
            )
          : _showResults
              ? _buildSearchResults()
              : _buildMainView(),
    );
  }

  Widget _buildMainView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== POPULAR SEARCHES =====
          if (_popularSearches.isNotEmpty) ...[
            const Text(
              'Popular Searches',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'GintoBold',
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularSearches.map((search) {
                return ActionChip(
                  label: Text(
                    search,
                    style: const TextStyle(fontSize: 13),
                  ),
                  onPressed: () {
                    _searchController.text = search;
                    _searchItems(search);
                  },
                  backgroundColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // ===== RECENT SEARCHES =====
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GintoBold',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _recentSearches.clear();
                      _saveRecentSearches();
                    });
                  },
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((search) {
                return GestureDetector(  // ← Wrap with GestureDetector
                  onTap: () {
                    _searchController.text = search;
                    _searchItems(search);
                    _saveSearch(search);
                    _searchFocus.unfocus();
                  },
                  child: Chip(
                    label: Text(
                      search,
                      style: const TextStyle(fontSize: 13),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () {
                      setState(() {
                        _recentSearches.remove(search);
                        _saveRecentSearches();
                      });
                    },
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // ===== TOP FOODS =====
          if (_popularFoods.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🍔 Top Foods',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GintoBold',
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: MyColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _popularFoods.length,
                itemBuilder: (context, index) {
                  final food = _popularFoods[index];
                  return SizedBox(
                    width: 150,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _buildPopularFoodCard(food),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ===== TOP DRINKS =====
          if (_popularDrinks.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top Drinks',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GintoBold',
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: MyColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _popularDrinks.length,
                itemBuilder: (context, index) {
                  final drink = _popularDrinks[index];
                  return SizedBox(
                    width: 150,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _buildPopularDrinkCard(drink),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildPopularFoodCard(Food food) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1.0,
          color: Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                'assets/${food.imagePath}',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GintoRegNorm',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${food.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: MyColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularDrinkCard(Drink drink) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1.0,
          color: Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                'assets/${drink.imagePath}',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drink.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GintoRegNorm',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${drink.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: MyColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'GintoRegNorm',
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try searching for something else',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'GintoRegNorm',
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        if (item is Drink) {
          return _buildDrinkResult(item);
        } else if (item is Food) {
          return _buildFoodResult(item);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDrinkResult(Drink drink) {
    return _buildResultCard(
      imagePath: drink.imagePath,
      name: drink.name,
      rating: drink.rating,
      category: drink.category,
      price: drink.price,
      onAddToCart: () {
        // Add drink to cart
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        cartProvider.addDrink(
          drink: drink,
          quantity: 1,
          size: 'M',
          sugarLevel: '100%',
          iceLevel: 'Regular',
          totalPrice: drink.price,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${drink.name} added to cart!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }

  Widget _buildFoodResult(Food food) {
    return _buildResultCard(
      imagePath: food.imagePath,
      name: food.name,
      rating: food.rating,
      category: food.category,
      price: food.price,
      onAddToCart: () {
        // Add food to cart
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        cartProvider.addFood(
          food: food,
          quantity: 1,
          size: 'Regular',
          totalPrice: food.price,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${food.name} added to cart!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }

  Widget _buildResultCard({
    required String imagePath,
    required String name,
    required double rating,
    required String category,
    required double price,
    required VoidCallback onAddToCart,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          width: 1.0,
          color: Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Image.asset(
                'assets/$imagePath',
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GintoRegNorm',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'GintoRegNorm',
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'GintoRegNorm',
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GintoRegNorm',
                    color: MyColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 30,
            decoration: BoxDecoration(
              color: MyColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: onAddToCart,
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ),
        ],
      ),
    );
  }
}