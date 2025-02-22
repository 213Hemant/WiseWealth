import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'login_page.dart';
import 'signup_page.dart';
import '../home/home_screen.dart';
import '../assets/assets_screen.dart';
import '../assets/add_asset.dart';
import '../transactions/transactions_screen.dart';
import '../transactions/add_transaction.dart';
import '../goals/goals_screen.dart';
import '../home/add_expense.dart';
import '../home/view_bills.dart';

final Map<String, WidgetBuilder> appRoutes = {
  LoginPage.routeName: (context) => const LoginPage(),
  SignupPage.routeName: (context) => const SignupPage(),
  HomeScreen.routeName: (context) => const HomeScreen(),
  AssetsScreen.routeName: (context) => const AssetsScreen(),
  AddAssetScreen.routeName: (context) => const AddAssetScreen(),
  TransactionsScreen.routeName: (context) => const TransactionsScreen(),
  AddTransactionScreen.routeName: (context) => const AddTransactionScreen(),
  GoalsScreen.routeName: (context) => const GoalsScreen(),
  ViewBillsScreen.routeName: (context) => const ViewBillsScreen(),
  AddExpenseScreen.routeName: (context) => const AddExpenseScreen(),
};

// ❌ Removed `SplashScreen` from this map because it needs dynamic arguments
