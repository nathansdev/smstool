import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_advanced/sms_advanced.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS TOOL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SMS TOOL'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String sms = 'No SMS received';
  String sender = 'No SMS received';
  String time = 'No SMS received';
  final String predefinedNumber = 'provide your number';
  TextEditingController messageController = TextEditingController();
  SmsReceiver receiver = SmsReceiver();

  @override
  void initState() {
    super.initState();
    checkAndRequestPermissions().then((isGranted) {
      if (isGranted) {
        readSms();
      }
    });
  }

  Future<bool> checkAndRequestPermissions() async {
    PermissionStatus status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
    }
    return status.isGranted;
  }

  void readSms() {
    print("Read SMS initiated");
    receiver.onSmsReceived?.listen((SmsMessage message) {
      print("New message received");
      print(message.body.toString());
      setState(() {
        sms = message.body ?? 'No message body';
        sender = message.address ?? 'Unknown sender';
        time = message.date.toString();
      });
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void sendSms() async {
    if (await checkAndRequestPermissions()) {
      SmsSender sender = SmsSender();
      String messageToSend = messageController.text;
      SmsMessage message = SmsMessage(predefinedNumber, messageToSend);
      message.onStateChanged.listen((SmsMessageState state) {
        if (state == SmsMessageState.Sent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('SMS Sent to $predefinedNumber')),
          );
        } else if (state == SmsMessageState.Fail) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send SMS')),
          );
        }
      });
      sender.sendSms(message);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SMS permission not granted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Latest SMS received:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Sender: $sender',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Message: $sms',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Received at: $time',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter message to send',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: sendSms,
                child: const Text('Send SMS'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
