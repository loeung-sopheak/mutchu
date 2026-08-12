class Drink {
  final String id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final String imagePath;
  final String category;
  final bool isPopular;
  final bool isVegan;
  final bool isNew;
  final double rating;
  final int preparationTime; // in minutes
  final List<String> tags;
  final NutritionInfo nutrition; 

  Drink({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice = 0,
    required this.imagePath,
    required this.category,
    this.isPopular = false,
    this.isVegan = false,
    this.isNew = false,
    this.rating = 4.5,
    this.preparationTime = 5,
    this.tags = const [],
    required this.nutrition,
  });

  double get discount {
    if (originalPrice == 0) return 0;
    return ((originalPrice - price) / originalPrice * 100).roundToDouble();
  }

  factory Drink.fromJson(Map<String, dynamic> json) {
    return Drink(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0,
      imagePath: json['image_path'] ?? '',
      category: json['category'] ?? '',
      isPopular: json['is_popular'] ?? false,
      isVegan: json['is_vegan'] ?? false,
      isNew: json['is_new'] ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      preparationTime: json['preparation_time'] ?? 5,
      tags: json['tags'] is List ? List<String>.from(json['tags']) : [],
      nutrition: NutritionInfo(
        calories: json['calories'] ?? 0,
        sugar: json['sugar'] ?? 0,
        protein: json['protein'] ?? 0,
        caffeine: json['caffeine'] ?? 0,
        servingSize: json['serving_size'] ?? '12 fl oz',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'image_path': imagePath,
      'category': category,
      'is_popular': isPopular,
      'is_vegan': isVegan,
      'is_new': isNew,
      'rating': rating,
      'preparation_time': preparationTime,
      'tags': tags,
      'calories': nutrition.calories,
      'sugar': nutrition.sugar,
      'protein': nutrition.protein,
      'caffeine': nutrition.caffeine,
      'serving_size': nutrition.servingSize,
    };
  }

}

class NutritionInfo {
  final int calories;
  final int sugar;
  final int protein;
  final int caffeine;
  final String servingSize;

  NutritionInfo({
    required this.calories,
    required this.sugar,
    required this.protein,
    required this.caffeine,
    required this.servingSize,
  });

  Map<String, dynamic> toJson() => {
    'calories': calories,
    'sugar': sugar,
    'protein': protein,
    'caffeine': caffeine,
    'servingSize': servingSize,
  };
}
