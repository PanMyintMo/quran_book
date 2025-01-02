import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_book/providers/theme_provider.dart';

class ThemeSwitcher extends StatefulWidget {
  const ThemeSwitcher({super.key});

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  @override
  Widget build(BuildContext context) {

    var themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Theme Mode",style: TextStyle(fontWeight: FontWeight.bold),),
       Switch(value: themeProvider.isDarkModeChecked, onChanged: (value){
      
        themeProvider.updateMode(darkMode: value);
     

       }),
        
          Text(themeProvider.isDarkModeChecked ?"Dark Mode" : "Light Mode")
        ],
      ),
    );
  }
}