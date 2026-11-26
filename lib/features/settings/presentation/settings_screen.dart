import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/band_title.dart';
import '../../../app/widgets/nav_row.dart';
import '../../../app/widgets/section_card.dart';
import '../../../app/widgets/switch_row.dart';
import '../../../core/notifications/notification_providers.dart';

/// Ajustes: por enquanto só a seção Alertas (RF-PRZ-03). Backup e "Sobre"
/// entram com a task de backup (RNF-04).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Ao voltar das configurações do aparelho, relê a permissão.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(notificationPermissionProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _toggle(bool value) async {
    await ref.read(notificationsEnabledProvider.notifier).set(value);
    if (!value) return;
    final scheduler = ref.read(notificationSchedulerProvider);
    if (!await scheduler.areEnabled()) {
      await ref.read(notificationSettingsProvider).markPermissionAsked();
      await scheduler.requestPermission();
    }
    ref.invalidate(notificationPermissionProvider);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(notificationsEnabledProvider);
    final permission = ref.watch(notificationPermissionProvider);
    final isEnabled = enabled.value;
    final blocked = isEnabled == true && permission.value == false;

    return Scaffold(
      appBar: AppBar(title: const BandTitle(title: 'Ajustes', large: true)),
      body: ListView(
        padding: AppSpacing.screen.copyWith(
          top: AppSpacing.lg,
          bottom: AppSpacing.xl,
        ),
        children: [
          SectionCard(
            title: 'Alertas',
            children: [
              SwitchRow(
                leadingIcon: Icons.notifications_outlined,
                title: 'Notificações de vencimento',
                subtitle:
                    'Às 8h, nos dias de lembrete e toda semana depois de '
                    'vencido',
                value: isEnabled ?? true,
                onChanged: isEnabled == null ? (_) {} : _toggle,
              ),
              if (blocked)
                NavRow(
                  leadingIcon: Icons.notifications_off_outlined,
                  title: 'Bloqueadas no Android',
                  subtitle: 'Toque para permitir nas configurações do aparelho',
                  onTap: () => ref
                      .read(notificationSchedulerProvider)
                      .openSystemSettings(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
