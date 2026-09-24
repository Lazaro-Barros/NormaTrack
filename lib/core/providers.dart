import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'utils/clock.dart';
import 'utils/id_generator.dart';

final clockProvider = Provider<Clock>((ref) => systemClock);
final idGeneratorProvider = Provider<IdGenerator>((ref) => uuidV7);
