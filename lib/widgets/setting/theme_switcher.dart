import 'package:flutter/material.dart';

class ThemeSwitcher extends StatefulWidget {
  const ThemeSwitcher({super.key});

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Theme Mode",style: TextStyle(fontWeight: FontWeight.bold),),
       Switch(value: isChecked, onChanged: (value){
        isChecked =value;
        setState(() {
          
        });

       }),
        
          Text(isChecked ?"Dark Mode" : "Light Mode")
        ],
      ),
    );
  }
}