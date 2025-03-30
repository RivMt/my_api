library my_api;

import 'package:flutter/material.dart';
import 'package:my_api/core/model/base_model.dart';
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/finance/model/finance_model.dart';
import 'package:my_api/finance/model/transaction.dart';

class Category extends FinanceModel {

  static const String endpoint = "api/finance/categories";

  static final Category unknown = Category({
    ModelKeys.keyUuid: BaseModel.unknownUuid,
    ModelKeys.keyType: TransactionType.expense.code,
    ModelKeys.keyIncluded: true,
    ModelKeys.keyIcon: -1,
    ModelKeys.keyName: "unknown",
  });

  Category(super.map);

  /// Is this valid or not
  bool get isValid {
    // Pid
    if (uuid == BaseModel.unknownUuid) {
      return false;
    }
    // Type
    if (type == TransactionType.unknown) {
      return false;
    }
    // Name
    if (name.isEmpty) {
      return false;
    }
    // Icon
    if (icon == CategorySymbol.unknown) {
      return false;
    }
    return true;
  }

  /// Type
  ///
  /// Default value is [TransactionType.expense]
  TransactionType get type => TransactionType.fromCode(getValue(ModelKeys.keyType, 0));

  set type(TransactionType value) => map[ModelKeys.keyType] = value.code;

  /// Included
  ///
  /// Default value is `true`
  bool get isIncluded => getValue(ModelKeys.keyIncluded, true);

  set isIncluded(bool value) => map[ModelKeys.keyIncluded] = value;

  /// Icon
  CategorySymbol get icon => CategorySymbol.fromId(getValue(ModelKeys.keyIcon, CategorySymbol.unknown.id));

  set icon(CategorySymbol icon) => map[ModelKeys.keyIcon] = icon.id;

}

enum CategorySymbol {
  unknown(-1, Icons.circle_outlined),
  arrowDown(0, Icons.arrow_downward_rounded),
  beverage(1, Icons.emoji_food_beverage_outlined),
  book(2, Icons.book_outlined),
  cake(3, Icons.cake_outlined),
  beach(4, Icons.beach_access_outlined),
  assistant(5, Icons.assistant_outlined),
  medicalService(6, Icons.medical_services_outlined),
  wallet(7, Icons.account_balance_wallet_outlined),
  homeWork(8, Icons.home_work_outlined),
  phone(9, Icons.phone_outlined),
  equipment(10, Icons.category_outlined),
  child(11, Icons.child_care),
  trendDown(12, Icons.trending_down_outlined),
  shopping(13, Icons.shopping_cart_outlined),
  train(14, Icons.train_outlined),
  activity(15, Icons.local_activity_outlined),
  download(16, Icons.download_outlined),
  car(17, Icons.directions_car_outlined),
  arrowUp(18, Icons.arrow_upward_outlined),
  face(19, Icons.face_outlined),
  bank(20, Icons.account_balance_outlined),
  education(21, Icons.school_outlined),
  support(22, Icons.support_outlined),
  achievement(23, Icons.military_tech_outlined),
  schedule(24, Icons.schedule_outlined),
  trendUp(25, Icons.trending_up_outlined),
  loyalty(26, Icons.loyalty_outlined),
  requestedPage(27, Icons.request_page_outlined),
  share(28, Icons.share_outlined),
  favorite(29, Icons.favorite_outline),
  fingerprint(30, Icons.fingerprint_outlined),
  filter(31, Icons.filter_alt_outlined),
  coin(32, Icons.paid_outlined),
  shoppingBag(33, Icons.shopping_bag_outlined),
  lightbulb(34, Icons.lightbulb_outline),
  increase(35, Icons.north_east),
  decrease(36, Icons.south_east),
  factCheck(37, Icons.fact_check_outlined),
  work(38, Icons.work_outline_outlined),
  print(39, Icons.print_outlined),
  pets(40, Icons.pets_outlined),
  compass(41, Icons.explore_outlined),
  shoppingBasket(42, Icons.shopping_basket_outlined),
  rocket(43, Icons.rocket_launch_outlined),
  percent(44, Icons.percent_outlined),
  theater(45, Icons.theaters_outlined),
  transportation(46, Icons.commute_outlined),
  tour(47, Icons.tour_outlined),
  anchor(48, Icons.anchor_outlined),
  balance(49, Icons.balance_outlined),
  token(50, Icons.token_outlined),
  swipeUp(51, Icons.swipe_up_alt_outlined),
  swipeDown(52, Icons.swipe_down_alt_outlined),
  campaign(53, Icons.campaign_outlined),
  construction(54, Icons.construction_outlined),
  health(55, Icons.health_and_safety_outlined),
  game(56, Icons.sports_esports_outlined),
  receipt(57, Icons.history_edu_outlined),
  virus(58, Icons.coronavirus_outlined),
  premium(59, Icons.workspace_premium_outlined),
  architecture(60, Icons.architecture_outlined),
  luggage(61, Icons.luggage_outlined),
  tennis(62, Icons.sports_tennis_outlined),
  mail(63, Icons.mail_outline),
  bolt(64, Icons.bolt_outlined),
  abort(65, Icons.block_outlined),
  palette(66, Icons.palette_outlined),
  key(67, Icons.key_outlined),
  park(68, Icons.park_outlined),
  airplaneTicket(69, Icons.airplane_ticket_outlined),
  chart(70, Icons.ssid_chart_outlined),
  fitness(71, Icons.fitness_center_outlined),
  business(72, Icons.business_center_outlined),
  checkroom(73, Icons.checkroom_outlined),
  upload(74, Icons.upload_outlined),
  food(75, Icons.restaurant_outlined);

  const CategorySymbol(this.id, this.icon);

  /// Unique value
  final int id;

  /// [IconData]
  final IconData icon;

  /// Find category icon using [id]
  factory CategorySymbol.fromId(int id) {
    // Check id value range
    if (id < -1 || id >= CategorySymbol.values.length-1) {
      return CategorySymbol.unknown;
    }
    return CategorySymbol.values[id + 1];
  }
}