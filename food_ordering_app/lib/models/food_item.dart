class FoodItem {
  final int? id;
  final String name;
  final double cost;

  FoodItem({this.id, this.name = "", this.cost = 0.0});

  Map<String, dynamic> toMap() {
    if (id == null) {
      return {
        'name': name,
        'cost': cost,
      };
    }
    return {
      'id': id,
      'name': name,
      'cost': cost,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      cost: map['cost'],
    );
  }
}