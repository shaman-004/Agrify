import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  final String _url = "ws://10.0.2.2:8000/ws";
  WebSocketChannel? _channel;
  bool _isConnected = false;
  StreamSubscription? _subscription;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  bool get isConnected => _isConnected;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  Future<void> connect() async {
    if (_isConnected) return;
    
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_url));
      _isConnected = true;
      print('WebSocket connected successfully');
      
      // Set up the subscription
      _subscription = _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            _messageController.add(data);
          } catch (e) {
            print('Error processing WebSocket message: $e');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          _isConnected = false;
        },
        onDone: () {
          print('WebSocket connection closed');
          _isConnected = false;
        },
      );
    } catch (e) {
      _isConnected = false;
      print('WebSocket connection failed: $e');
      throw Exception('Failed to connect to WebSocket: $e');
    }
  }

  void listen(Function(Map<String, dynamic>) onMessage) {
    if (_channel == null) {
      throw Exception('WebSocket not connected. Call connect() first.');
    }
    messageStream.listen(onMessage);
  }

  void disconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _isConnected = false;
    _channel = null;
    print('WebSocket disconnected');
  }

  @override
  void dispose() {
    _messageController.close();
    disconnect();
  }
}
