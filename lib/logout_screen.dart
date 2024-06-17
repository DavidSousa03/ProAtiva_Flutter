import 'package:flutter/material.dart';

class LogoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Text('Configurações', style: TextStyle(fontSize: 24)),
            SizedBox(width: 10),
            Icon(Icons.settings, size: 24),
          ],
        ),
        backgroundColor: Color(0xFF303972),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text('Configurações', style: TextStyle(fontSize: 24)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: Text('Sair'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
