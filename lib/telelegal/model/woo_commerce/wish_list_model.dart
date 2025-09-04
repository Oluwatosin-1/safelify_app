import 'package:safelify/telelegal/model/woo_commerce/common_models.dart';

class WishListModel {
  String? message;
  String? code;
  bool? status;

  List<WishList>? wishList;

  WishListModel({
    this.message,
    this.code,
    this.status,
    this.wishList,
  });

  factory WishListModel.fromJson(Map<String, dynamic> json) {
    return WishListModel(
      message: json['message'],
      code: json['code'],
      status: json['status'],
      wishList: json['data'] != null ? (json['data'] as List).map((wishListData) => WishList.fromJson(wishListData)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['code'] = this.code;
    data['status'] = this.status;
    if (this.wishList != null) {
      data['data'] = this.wishList!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class WishList {
  String? name;
  String? sku;
  String? proType;
  String? price;
  String? regularPrice;
  String? salePrice;
  String? thumbnail;
  String? full;
  String? createdAt;

  int? proId;
  int? stockQuantity;

  bool? inStock;

  List<ImageModel>? gallery;

  WishList({
    this.name,
    this.sku,
    this.proType,
    this.price,
    this.regularPrice,
    this.salePrice,
    this.thumbnail,
    this.full,
    this.createdAt,
    this.proId,
    this.stockQuantity,
    this.inStock,
    this.gallery,
  });

  factory WishList.fromJson(Map<String, dynamic> json) {
    return WishList(
      name: json['name'],
      sku: json['sku'],
      proType: json['pro_type'],
      price: json['price'],
      regularPrice: json['regular_price'],
      salePrice: json['sale_price'],
      thumbnail: json['thumbnail'],
      full: json['full'],
      createdAt: json['created_at'],
      proId: json['pro_id'],
      stockQuantity: json['stock_quantity'],
      inStock: json['in_stock'],
      gallery: List<ImageModel>.from(json['gallery']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (sku != null) data['sku'] = sku;
    if (proType != null) data['pro_type'] = proType;
    if (price != null) data['price'] = price;
    if (regularPrice != null) data['regular_price'] = regularPrice;
    if (salePrice != null) data['sale_price'] = salePrice;
    if (thumbnail != null) data['thumbnail'] = thumbnail;
    if (full != null) data['full'] = full;
    if (createdAt != null) data['created_at'] = createdAt;
    if (proId != null) data['pro_id'] = proId;
    if (stockQuantity != null) data['stock_quantity'] = stockQuantity;
    if (inStock != null) data['in_stock'] = inStock;
    if (gallery != null) data['gallery'] = gallery;
    return data;
  }
}
