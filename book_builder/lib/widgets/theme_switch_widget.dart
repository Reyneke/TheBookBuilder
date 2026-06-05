import 'package:book_builder/providers/provider_service.dart';
import 'package:book_builder/providers/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeSwitchWidget extends StatelessWidget {
  const ThemeSwitchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModeNotifier = context.watch<ThemeNotifier>();
    //final settingsNotifier = context.read<SettingProvider>();

    context.read<ProviderService>().saveTheme(
      ((themeModeNotifier.themeModeNotifier.value == ThemeMode.dark) ||
          (ThemeMode.system == ThemeMode.dark)),
    );

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: context.read<ThemeNotifier>().themeModeNotifier,
      builder: (context, themeMode, child) {
        return Row(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ThemeButton(
              icon: Icons.light_mode,
              label: 'Hell',
              isSelected: themeMode == ThemeMode.light,
              onPressed: () =>
                  themeModeNotifier.themeModeNotifier.value = ThemeMode.light,
            ),
            _ThemeButton(
              icon: Icons.dark_mode,
              label: 'Dunkel',
              isSelected: themeMode == ThemeMode.dark,
              onPressed: () =>
                  themeModeNotifier.themeModeNotifier.value = ThemeMode.dark,
            ),
            _ThemeButton(
              icon: Icons.tonality,
              label: 'System',
              isSelected: themeMode == ThemeMode.system,
              onPressed: () =>
                  themeModeNotifier.themeModeNotifier.value = ThemeMode.system,
            ),
          ],
        );
      },
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ThemeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
        Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
