// Ponto de entrada descartável para conferir o Painel no emulador com dados.
// Não é importado por lib/. Uso:
//   flutter run -d emulator-5554 -t tasks/009-painel-vencimentos/prototypes/seed_main.dart
// Só cadastra se ainda não existe a "Indústria Alfa Ltda" (não mexe nos
// dados que já estão no aparelho). Datas relativas a hoje: −3, 12, 45
// e 167 dias (as mesmas situações dos testes), mais uma empresa arquivada e
// uma com o módulo desligado, cujos prazos não podem aparecer.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:normatrack/core/notifications/local_notification_scheduler.dart';
import 'package:normatrack/core/notifications/notification_providers.dart';
import 'package:normatrack/features/companies/data/local_company_repository.dart';
import 'package:normatrack/features/companies/domain/company.dart';
import 'package:normatrack/features/companies/domain/module_type.dart';
import 'package:normatrack/features/deadlines/data/local_deadline_repository.dart';
import 'package:normatrack/features/deadlines/domain/deadline.dart';
import 'package:normatrack/features/deadlines/domain/deadline_category.dart';
import 'package:normatrack/main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final scheduler = await LocalNotificationScheduler.create();
  final container = ProviderContainer(
    overrides: [notificationSchedulerProvider.overrideWithValue(scheduler)],
  );
  final companies = container.read(companyRepositoryProvider);
  final deadlines = container.read(deadlineRepositoryProvider);

  final existing = await companies.watchAll().first;
  if (!existing.any((c) => c.legalName == 'Indústria Alfa Ltda')) {
    final now = DateTime.now();
    DateTime inDays(int n) => DateTime(now.year, now.month, now.day + n);
    DeadlineInput input(String title, int days, DeadlineCategory c) =>
        DeadlineInput(
          module: ModuleType.environmental,
          category: c,
          title: title,
          dueDate: inDays(days),
        );
    const env = {ModuleType.environmental};

    final alfa = await companies.create(
      const CompanyInput(legalName: 'Indústria Alfa Ltda', enabledModules: env),
    );
    final beta = await companies.create(
      const CompanyInput(
        legalName: 'Beta Indústria de Alimentos S.A.',
        tradeName: 'Beta Alimentos',
        enabledModules: env,
      ),
    );
    await deadlines.create(
      alfa.id,
      input('Licença de Operação', -3, DeadlineCategory.license),
    );
    await deadlines.create(
      alfa.id,
      input('Laudo da ETE', 12, DeadlineCategory.labReport),
    );
    await deadlines.create(
      beta.id,
      input('Licença de Instalação', 45, DeadlineCategory.license),
    );
    await deadlines.create(
      beta.id,
      input('Bomba dosadora', 167, DeadlineCategory.maintenance),
    );

    final gama = await companies.create(
      const CompanyInput(legalName: 'Gama Bebidas Ltda', enabledModules: env),
    );
    await deadlines.create(
      gama.id,
      input('Licença da Gama (módulo desligado)', 5, DeadlineCategory.license),
    );
    await companies.update(
      gama.id,
      const CompanyInput(legalName: 'Gama Bebidas Ltda'),
    );
    final delta = await companies.create(
      const CompanyInput(legalName: 'Delta Química Ltda', enabledModules: env),
    );
    await deadlines.create(
      delta.id,
      input('Licença da Delta (arquivada)', 6, DeadlineCategory.license),
    );
    await companies.archive(delta.id);
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const NormaTrackApp(),
    ),
  );
}
