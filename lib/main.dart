import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MqttServerClient client =
      MqttServerClient('your_mqtt_server_url', 'your_client_id');
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    client.logging(on: true);
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
    client.onUnsubscribed = _onUnsubscribed as UnsubscribeCallback?;
    client.onSubscribeFail = _onSubscribeFail;
    //client.onUnsubscribeFail = _onUnsubscribeFail;
    //client.onMessage = _onMessage;
    final connMessage = MqttConnectMessage()
        .withClientIdentifier('your_client_id')
        .keepAliveFor(60)
        .startClean()
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;
    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }
  }

  void _onDisconnected() {
    print('Disconnected');
  }

  void _onConnected() {
    print('Connected');
    client.subscribe('your_topic', MqttQos.exactlyOnce);
  }

  void _onSubscribed(String topic) {
    print('Subscribed to $topic');
  }

  void _onUnsubscribed(String topic) {
    print('Unsubscribed from $topic');
  }

  void _onSubscribeFail(String topic) {
    print('Failed to subscribe to $topic');
  }

  void _onUnsubscribeFail(String topic) {
    print('Failed to unsubscribe from $topic');
  }

  void _onMessage(String topic, MqttMessage message) {
    setState(() {
      _messages.add(message.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('MQTT Demo'),
        ),
        body: ListView.builder(
          itemCount: _messages.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(_messages[index]),
          ),
        ),
      ),
    );
  }
}
