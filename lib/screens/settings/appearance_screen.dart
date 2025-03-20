import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  AppearanceScreenState createState() => AppearanceScreenState();
}

class AppearanceScreenState extends State<AppearanceScreen> {
  bool isLightMode = false;
  double fontSize = 14.0;
  Color accentColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _loadPreferences(); // Wczytaj ustawienia po uruchomieniu
  }

  // Pobieranie zapisanych ustawień
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLightMode = prefs.getBool('isLightMode') ?? false;
      fontSize = prefs.getDouble('fontSize') ?? 14.0;
      int savedColor = prefs.getInt('accentColor') ?? 0;
      accentColor = Color(savedColor);
    });
  }

  // Zapis trybu jasnego
  Future<void> _saveLightMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLightMode', value);
  }

  // Zapis rozmiaru czcionki
  Future<void> _saveFontSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('fontSize', value);
  }

  // Zapis koloru akcentu
  Future<void> _saveAccentColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('accentColor', color.value);
  }

  void toggleLightMode() {
    setState(() {
      isLightMode = !isLightMode;
    });
    _saveLightMode(isLightMode);
  }

  void changeFontSize(double newSize) {
    setState(() {
      fontSize = newSize;
    });
    _saveFontSize(newSize);
  }

  void changeAccentColor(Color newColor) {
    setState(() {
      accentColor = newColor;
    });
    _saveAccentColor(newColor);
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor =
        isLightMode ? Colors.white : const Color(0xFF0F172A);
    Color containerColor =
        isLightMode ? Colors.grey.shade200 : const Color(0xFF1F2937);
    Color textColor = isLightMode ? Colors.black : Colors.white;
    Color iconColor = isLightMode ? Colors.black87 : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor:
            isLightMode ? Colors.blueGrey : const Color(0xFF1E3A8A),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Wygląd', style: TextStyle(color: textColor)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildMenuItem(
                Icons.brightness_6,
                'Tryb jasny',
                toggleLightMode,
                iconColor,
                textColor,
              ),
              _buildMenuItem(
                Icons.text_fields,
                'Rozmiar czcionki',
                () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Rozmiar czcionki'),
                        content: StatefulBuilder(
                          builder: (context, setState) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Slider(
                                  value: fontSize,
                                  min: 10.0,
                                  max: 24.0,
                                  divisions: 14,
                                  label: fontSize.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      fontSize = value;
                                    });
                                    changeFontSize(value);
                                  },
                                ),
                                Text(
                                  'Podgląd tekstu',
                                  style: TextStyle(fontSize: fontSize),
                                ),
                              ],
                            );
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
                iconColor,
                textColor,
              ),
              _buildMenuItem(
                Icons.color_lens,
                'Kolor akcentu',
                () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Kolor akcentu'),
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            pickerColor: accentColor,
                            onColorChanged: changeAccentColor,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
                iconColor,
                textColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap,
    Color iconColor,
    Color textColor,
  ) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }
}
