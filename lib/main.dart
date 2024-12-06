import 'package:flutter/material.dart';
import 'services/websocket_service.dart';
import 'pages/login_page.dart';
import 'pages/notification_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final WebSocketService _webSocketService = WebSocketService();

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
  }

  Future<void> _initializeWebSocket() async {
    try {
      await _webSocketService.connect();
      _webSocketService.listen((data) {
        print('Received WebSocket message: $data');
        // Handle your WebSocket messages here
      });
    } catch (e) {
      print('Failed to initialize WebSocket: $e');
    }
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farm App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/notifications': (context) => const NotificationPage(),
      },
    );
  }
}
