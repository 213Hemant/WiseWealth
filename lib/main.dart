import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/profile_provider.dart';
import 'providers/asset_provider.dart';
import 'providers/transaction_provider.dart';
import 'launch/splash_screen.dart';
import 'launch/routes.dart';
import 'theme/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> connectToServer() async {
  String url = "http://127.0.0.1:5000/"; // Replace with actual server IP
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['message'];
    } else {
      return "Error: Server responded with status code ${response.statusCode}";
    }
  } catch (e) {
    return "Connecting...";
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String connectionMessage = await connectToServer();

  // Initialize TransactionProvider DB
  final transactionProvider = TransactionProvider();
  await transactionProvider.initDb();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => AssetProvider()),
        ChangeNotifierProvider(create: (_) => transactionProvider),
      ],
      child: MyApp(connectionMessage: connectionMessage),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String connectionMessage;

  const MyApp({super.key, required this.connectionMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Finance Manager",
      theme: AppTheme.themeData,
      initialRoute: SplashScreen.routeName,
      onGenerateRoute: (settings) {
        if (settings.name == SplashScreen.routeName) {
          return MaterialPageRoute(
            builder: (context) =>
                SplashScreen(connectionMessage: connectionMessage),
          );
        }
        if (appRoutes.containsKey(settings.name)) {
          return MaterialPageRoute(builder: appRoutes[settings.name]!);
        }
        return null;
      },
    );
  }
}
