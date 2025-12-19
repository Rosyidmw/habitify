import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pengaturan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: const Text(
                  "Mode Gelap",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                subtitle: Text(
                  themeProvider.isDarkMode
                      ? "Tampilan gelap aktif"
                      : "Tampilan terang aktif",
                  style: const TextStyle(color: Colors.grey),
                ),
                secondary: Icon(
                  themeProvider.isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text("Tentang Aplikasi"),
            subtitle: const Text("Habitify v1.0.0"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Habitify",
                applicationVersion: "1.0.0",
                applicationLegalese: "Created for Portfolio",
              );
            },
          ),
        ],
      ),
    );
  }
}
