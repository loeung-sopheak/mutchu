import 'package:flutter/material.dart';
import '../colors.dart';
import '../models/drink_model.dart';
import '../models/food_model.dart';
import '../services/supabase_service.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  String _selectedAddress = '';
  List<String> _savedAddresses = [];
  List<Drink> _trendingDrinks = [];
  List<Food> _trendingFoods = [];
  List<Drink> _newDrinks = [];
  List<Food> _newFoods = [];
  bool _isLoading = true;

  // Address related
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAddresses();
    _loadExploreData();
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    // Load from SharedPreferences or Supabase
    // For now, use dummy data
    setState(() {
      _savedAddresses = [
        '123 Main St, Phnom Penh, Cambodia',
        '456 Riverside Blvd, Phnom Penh, Cambodia',
      ];
      _selectedAddress = _savedAddresses.isNotEmpty ? _savedAddresses[0] : '';
    });
  }

  Future<void> _loadExploreData() async {
    setState(() => _isLoading = true);
    try {
      final drinks = await SupabaseService().getDrinks();
      final foods = await SupabaseService().getFoods();

      setState(() {
        _trendingDrinks = drinks.where((d) => d.isPopular).take(4).toList();
        _trendingFoods = foods.where((f) => f.isPopular).take(4).toList();
        _newDrinks = drinks.where((d) => d.isNew).take(4).toList();
        _newFoods = foods.where((f) => f.isNew).take(4).toList();
        _isLoading = false;
      });
    } catch (e) {
      // print('Error loading explore data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showAddressPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Select Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'GintoBold',
                      ),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _savedAddresses.length + 1,
                      itemBuilder: (context, index) {
                        if (index < _savedAddresses.length) {
                          return _buildAddressTile(
                            _savedAddresses[index],
                            index,
                            setSheetState,
                          );
                        } else {
                          return _buildAddAddressTile(setSheetState);
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAddressTile(
    String address,
    int index,
    StateSetter setSheetState,
  ) {
    final isSelected = _selectedAddress == address;
    return RadioListTile<String>(
      value: address,
      groupValue: _selectedAddress,
      onChanged: (value) {
        setState(() {
          _selectedAddress = value!;
        });
        setSheetState(() {});
        Navigator.pop(context);
      },
      title: Text(address, style: const TextStyle(fontSize: 14)),
      subtitle: isSelected
          ? const Text(
              '📍 Current delivery address',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      controlAffinity: ListTileControlAffinity.trailing,
      activeColor: MyColors.primary,
      dense: true,
    );
  }

  Widget _buildAddAddressTile(StateSetter setSheetState) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: MyColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: MyColors.primary),
      ),
      title: const Text(
        'Add New Address',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text('Add a new delivery address'),
      onTap: () {
        Navigator.pop(context);
        _showAddAddressDialog();
      },
    );
  }

  void _showAddAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Address'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _streetController,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _zipController,
                      decoration: const InputDecoration(
                        labelText: 'ZIP Code',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _countryController,
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final fullAddress =
                  '${_streetController.text}, ${_cityController.text}, ${_stateController.text} ${_zipController.text}, ${_countryController.text}';
              setState(() {
                _savedAddresses.add(fullAddress);
                _selectedAddress = fullAddress;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Address added!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Address'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: GestureDetector(
          onTap: _showAddressPicker,
          child: Row(
            children: [
              Icon(Icons.location_on, color: MyColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedAddress.isEmpty
                      ? 'Select address'
                      : _selectedAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt, color: MyColors.primary),
            onPressed: _showAddAddressDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: MyColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== ADDRESS SECTION =====
                  const SizedBox(height: 16),

                  // ===== RECOMMENDATIONS =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== FEATURED BANNER =====
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -20,
                                bottom: -20,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '✨ New Arrivals',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'GintoBold',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Discover our latest matcha creations',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ===== WHY MATCHA? =====
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.emoji_nature,
                                color: MyColors.primary,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Why Matcha?',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontFamily: 'Ginto'
                                      ),
                                    ),
                                    Text(
                                      'Rich in antioxidants, boosts energy, and enhances focus. 🌿',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                        fontFamily: 'GintoRegNorm'
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
