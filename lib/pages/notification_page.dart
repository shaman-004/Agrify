import 'package:flutter/material.dart';
import '../services/websocket_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final WebSocketService _webSocketService = WebSocketService();
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    _webSocketService.connect();
    _webSocketService.listen((data) {
      setState(() {
        notifications.add(data['message']);
      });
    });
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Disease Notifications"),
        backgroundColor: Colors.teal,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                "No notifications yet.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: Text(notifications[index]),
                );
              },
            ),
    );
  }
}
