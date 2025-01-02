import 'package:flutter/material.dart';
import 'package:quran_book/widgets/setting/setting_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quarn Book"),
      actions: [
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return SettingScreen();
            }));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.settings),
          ),
        )
      ],),
      
      
      
    );
  }
}