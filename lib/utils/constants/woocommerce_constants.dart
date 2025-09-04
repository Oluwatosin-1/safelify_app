class CartKeys {
  static const cartItemCountKey = 'Cart Item Count';
  static const billingAddress = 'Billing Address';
  static const shippingAddress = 'Shipping Address';
}

class ProductFilters {
  static const String clear = 'clear';
  static const String date = 'date';
  static const String price = 'price';
  static const String popularity = 'popularity';
  static const String rating = 'rating';
}

class OrderStatus {
  static String any = 'any';
  static String pending = 'pending';
  static String processing = 'processing';
  static String onHold = 'on-hold';
  static String completed = 'completed';
  static String cancelled = 'cancelled';
  static String refunded = 'refunded';
  static String failed = 'failed';
  static String trash = 'trash';
}

class ProductTypes {
  static String simple = 'simple';
  static String grouped = 'grouped';
  static String variation = 'variation';
  static String variable = 'variable';

  static String external = 'external';
}

class DiscountType {
  static String percentage = 'percent';
  static String fixedCart = 'fixed_cart';
  static String fixedProduct = 'fixed_product';
}
