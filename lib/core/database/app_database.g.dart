// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CompaniesTable extends Companies
    with TableInfo<$CompaniesTable, Company> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompaniesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalNameMeta = const VerificationMeta(
    'legalName',
  );
  @override
  late final GeneratedColumn<String> legalName = GeneratedColumn<String>(
    'legal_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tradeNameMeta = const VerificationMeta(
    'tradeName',
  );
  @override
  late final GeneratedColumn<String> tradeName = GeneratedColumn<String>(
    'trade_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cnpjMeta = const VerificationMeta('cnpj');
  @override
  late final GeneratedColumn<String> cnpj = GeneratedColumn<String>(
    'cnpj',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateRegistrationMeta = const VerificationMeta(
    'stateRegistration',
  );
  @override
  late final GeneratedColumn<String> stateRegistration =
      GeneratedColumn<String>(
        'state_registration',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _addressStreetMeta = const VerificationMeta(
    'addressStreet',
  );
  @override
  late final GeneratedColumn<String> addressStreet = GeneratedColumn<String>(
    'address_street',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressNumberMeta = const VerificationMeta(
    'addressNumber',
  );
  @override
  late final GeneratedColumn<String> addressNumber = GeneratedColumn<String>(
    'address_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressComplementMeta = const VerificationMeta(
    'addressComplement',
  );
  @override
  late final GeneratedColumn<String> addressComplement =
      GeneratedColumn<String>(
        'address_complement',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _addressDistrictMeta = const VerificationMeta(
    'addressDistrict',
  );
  @override
  late final GeneratedColumn<String> addressDistrict = GeneratedColumn<String>(
    'address_district',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressCityMeta = const VerificationMeta(
    'addressCity',
  );
  @override
  late final GeneratedColumn<String> addressCity = GeneratedColumn<String>(
    'address_city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressStateMeta = const VerificationMeta(
    'addressState',
  );
  @override
  late final GeneratedColumn<String> addressState = GeneratedColumn<String>(
    'address_state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressPostalCodeMeta = const VerificationMeta(
    'addressPostalCode',
  );
  @override
  late final GeneratedColumn<String> addressPostalCode =
      GeneratedColumn<String>(
        'address_postal_code',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalRepNameMeta = const VerificationMeta(
    'legalRepName',
  );
  @override
  late final GeneratedColumn<String> legalRepName = GeneratedColumn<String>(
    'legal_rep_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalRepCpfMeta = const VerificationMeta(
    'legalRepCpf',
  );
  @override
  late final GeneratedColumn<String> legalRepCpf = GeneratedColumn<String>(
    'legal_rep_cpf',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalRepPhoneMeta = const VerificationMeta(
    'legalRepPhone',
  );
  @override
  late final GeneratedColumn<String> legalRepPhone = GeneratedColumn<String>(
    'legal_rep_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalRepEmailMeta = const VerificationMeta(
    'legalRepEmail',
  );
  @override
  late final GeneratedColumn<String> legalRepEmail = GeneratedColumn<String>(
    'legal_rep_email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    legalName,
    tradeName,
    cnpj,
    stateRegistration,
    addressStreet,
    addressNumber,
    addressComplement,
    addressDistrict,
    addressCity,
    addressState,
    addressPostalCode,
    phone,
    email,
    legalRepName,
    legalRepCpf,
    legalRepPhone,
    legalRepEmail,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'companies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Company> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('legal_name')) {
      context.handle(
        _legalNameMeta,
        legalName.isAcceptableOrUnknown(data['legal_name']!, _legalNameMeta),
      );
    } else if (isInserting) {
      context.missing(_legalNameMeta);
    }
    if (data.containsKey('trade_name')) {
      context.handle(
        _tradeNameMeta,
        tradeName.isAcceptableOrUnknown(data['trade_name']!, _tradeNameMeta),
      );
    }
    if (data.containsKey('cnpj')) {
      context.handle(
        _cnpjMeta,
        cnpj.isAcceptableOrUnknown(data['cnpj']!, _cnpjMeta),
      );
    }
    if (data.containsKey('state_registration')) {
      context.handle(
        _stateRegistrationMeta,
        stateRegistration.isAcceptableOrUnknown(
          data['state_registration']!,
          _stateRegistrationMeta,
        ),
      );
    }
    if (data.containsKey('address_street')) {
      context.handle(
        _addressStreetMeta,
        addressStreet.isAcceptableOrUnknown(
          data['address_street']!,
          _addressStreetMeta,
        ),
      );
    }
    if (data.containsKey('address_number')) {
      context.handle(
        _addressNumberMeta,
        addressNumber.isAcceptableOrUnknown(
          data['address_number']!,
          _addressNumberMeta,
        ),
      );
    }
    if (data.containsKey('address_complement')) {
      context.handle(
        _addressComplementMeta,
        addressComplement.isAcceptableOrUnknown(
          data['address_complement']!,
          _addressComplementMeta,
        ),
      );
    }
    if (data.containsKey('address_district')) {
      context.handle(
        _addressDistrictMeta,
        addressDistrict.isAcceptableOrUnknown(
          data['address_district']!,
          _addressDistrictMeta,
        ),
      );
    }
    if (data.containsKey('address_city')) {
      context.handle(
        _addressCityMeta,
        addressCity.isAcceptableOrUnknown(
          data['address_city']!,
          _addressCityMeta,
        ),
      );
    }
    if (data.containsKey('address_state')) {
      context.handle(
        _addressStateMeta,
        addressState.isAcceptableOrUnknown(
          data['address_state']!,
          _addressStateMeta,
        ),
      );
    }
    if (data.containsKey('address_postal_code')) {
      context.handle(
        _addressPostalCodeMeta,
        addressPostalCode.isAcceptableOrUnknown(
          data['address_postal_code']!,
          _addressPostalCodeMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('legal_rep_name')) {
      context.handle(
        _legalRepNameMeta,
        legalRepName.isAcceptableOrUnknown(
          data['legal_rep_name']!,
          _legalRepNameMeta,
        ),
      );
    }
    if (data.containsKey('legal_rep_cpf')) {
      context.handle(
        _legalRepCpfMeta,
        legalRepCpf.isAcceptableOrUnknown(
          data['legal_rep_cpf']!,
          _legalRepCpfMeta,
        ),
      );
    }
    if (data.containsKey('legal_rep_phone')) {
      context.handle(
        _legalRepPhoneMeta,
        legalRepPhone.isAcceptableOrUnknown(
          data['legal_rep_phone']!,
          _legalRepPhoneMeta,
        ),
      );
    }
    if (data.containsKey('legal_rep_email')) {
      context.handle(
        _legalRepEmailMeta,
        legalRepEmail.isAcceptableOrUnknown(
          data['legal_rep_email']!,
          _legalRepEmailMeta,
        ),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Company map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Company(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      legalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_name'],
      )!,
      tradeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trade_name'],
      ),
      cnpj: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cnpj'],
      ),
      stateRegistration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state_registration'],
      ),
      addressStreet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_street'],
      ),
      addressNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_number'],
      ),
      addressComplement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_complement'],
      ),
      addressDistrict: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_district'],
      ),
      addressCity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_city'],
      ),
      addressState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_state'],
      ),
      addressPostalCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_postal_code'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      legalRepName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_rep_name'],
      ),
      legalRepCpf: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_rep_cpf'],
      ),
      legalRepPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_rep_phone'],
      ),
      legalRepEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_rep_email'],
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $CompaniesTable createAlias(String alias) {
    return $CompaniesTable(attachedDatabase, alias);
  }
}

class Company extends DataClass implements Insertable<Company> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String legalName;
  final String? tradeName;
  final String? cnpj;
  final String? stateRegistration;
  final String? addressStreet;
  final String? addressNumber;
  final String? addressComplement;
  final String? addressDistrict;
  final String? addressCity;

  /// `BrazilianState.code`.
  final String? addressState;
  final String? addressPostalCode;
  final String? phone;
  final String? email;
  final String? legalRepName;
  final String? legalRepCpf;
  final String? legalRepPhone;
  final String? legalRepEmail;
  final DateTime? archivedAt;
  const Company({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.legalName,
    this.tradeName,
    this.cnpj,
    this.stateRegistration,
    this.addressStreet,
    this.addressNumber,
    this.addressComplement,
    this.addressDistrict,
    this.addressCity,
    this.addressState,
    this.addressPostalCode,
    this.phone,
    this.email,
    this.legalRepName,
    this.legalRepCpf,
    this.legalRepPhone,
    this.legalRepEmail,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['legal_name'] = Variable<String>(legalName);
    if (!nullToAbsent || tradeName != null) {
      map['trade_name'] = Variable<String>(tradeName);
    }
    if (!nullToAbsent || cnpj != null) {
      map['cnpj'] = Variable<String>(cnpj);
    }
    if (!nullToAbsent || stateRegistration != null) {
      map['state_registration'] = Variable<String>(stateRegistration);
    }
    if (!nullToAbsent || addressStreet != null) {
      map['address_street'] = Variable<String>(addressStreet);
    }
    if (!nullToAbsent || addressNumber != null) {
      map['address_number'] = Variable<String>(addressNumber);
    }
    if (!nullToAbsent || addressComplement != null) {
      map['address_complement'] = Variable<String>(addressComplement);
    }
    if (!nullToAbsent || addressDistrict != null) {
      map['address_district'] = Variable<String>(addressDistrict);
    }
    if (!nullToAbsent || addressCity != null) {
      map['address_city'] = Variable<String>(addressCity);
    }
    if (!nullToAbsent || addressState != null) {
      map['address_state'] = Variable<String>(addressState);
    }
    if (!nullToAbsent || addressPostalCode != null) {
      map['address_postal_code'] = Variable<String>(addressPostalCode);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || legalRepName != null) {
      map['legal_rep_name'] = Variable<String>(legalRepName);
    }
    if (!nullToAbsent || legalRepCpf != null) {
      map['legal_rep_cpf'] = Variable<String>(legalRepCpf);
    }
    if (!nullToAbsent || legalRepPhone != null) {
      map['legal_rep_phone'] = Variable<String>(legalRepPhone);
    }
    if (!nullToAbsent || legalRepEmail != null) {
      map['legal_rep_email'] = Variable<String>(legalRepEmail);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  CompaniesCompanion toCompanion(bool nullToAbsent) {
    return CompaniesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      legalName: Value(legalName),
      tradeName: tradeName == null && nullToAbsent
          ? const Value.absent()
          : Value(tradeName),
      cnpj: cnpj == null && nullToAbsent ? const Value.absent() : Value(cnpj),
      stateRegistration: stateRegistration == null && nullToAbsent
          ? const Value.absent()
          : Value(stateRegistration),
      addressStreet: addressStreet == null && nullToAbsent
          ? const Value.absent()
          : Value(addressStreet),
      addressNumber: addressNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(addressNumber),
      addressComplement: addressComplement == null && nullToAbsent
          ? const Value.absent()
          : Value(addressComplement),
      addressDistrict: addressDistrict == null && nullToAbsent
          ? const Value.absent()
          : Value(addressDistrict),
      addressCity: addressCity == null && nullToAbsent
          ? const Value.absent()
          : Value(addressCity),
      addressState: addressState == null && nullToAbsent
          ? const Value.absent()
          : Value(addressState),
      addressPostalCode: addressPostalCode == null && nullToAbsent
          ? const Value.absent()
          : Value(addressPostalCode),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      legalRepName: legalRepName == null && nullToAbsent
          ? const Value.absent()
          : Value(legalRepName),
      legalRepCpf: legalRepCpf == null && nullToAbsent
          ? const Value.absent()
          : Value(legalRepCpf),
      legalRepPhone: legalRepPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(legalRepPhone),
      legalRepEmail: legalRepEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(legalRepEmail),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory Company.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Company(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      legalName: serializer.fromJson<String>(json['legalName']),
      tradeName: serializer.fromJson<String?>(json['tradeName']),
      cnpj: serializer.fromJson<String?>(json['cnpj']),
      stateRegistration: serializer.fromJson<String?>(
        json['stateRegistration'],
      ),
      addressStreet: serializer.fromJson<String?>(json['addressStreet']),
      addressNumber: serializer.fromJson<String?>(json['addressNumber']),
      addressComplement: serializer.fromJson<String?>(
        json['addressComplement'],
      ),
      addressDistrict: serializer.fromJson<String?>(json['addressDistrict']),
      addressCity: serializer.fromJson<String?>(json['addressCity']),
      addressState: serializer.fromJson<String?>(json['addressState']),
      addressPostalCode: serializer.fromJson<String?>(
        json['addressPostalCode'],
      ),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      legalRepName: serializer.fromJson<String?>(json['legalRepName']),
      legalRepCpf: serializer.fromJson<String?>(json['legalRepCpf']),
      legalRepPhone: serializer.fromJson<String?>(json['legalRepPhone']),
      legalRepEmail: serializer.fromJson<String?>(json['legalRepEmail']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'legalName': serializer.toJson<String>(legalName),
      'tradeName': serializer.toJson<String?>(tradeName),
      'cnpj': serializer.toJson<String?>(cnpj),
      'stateRegistration': serializer.toJson<String?>(stateRegistration),
      'addressStreet': serializer.toJson<String?>(addressStreet),
      'addressNumber': serializer.toJson<String?>(addressNumber),
      'addressComplement': serializer.toJson<String?>(addressComplement),
      'addressDistrict': serializer.toJson<String?>(addressDistrict),
      'addressCity': serializer.toJson<String?>(addressCity),
      'addressState': serializer.toJson<String?>(addressState),
      'addressPostalCode': serializer.toJson<String?>(addressPostalCode),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'legalRepName': serializer.toJson<String?>(legalRepName),
      'legalRepCpf': serializer.toJson<String?>(legalRepCpf),
      'legalRepPhone': serializer.toJson<String?>(legalRepPhone),
      'legalRepEmail': serializer.toJson<String?>(legalRepEmail),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  Company copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? legalName,
    Value<String?> tradeName = const Value.absent(),
    Value<String?> cnpj = const Value.absent(),
    Value<String?> stateRegistration = const Value.absent(),
    Value<String?> addressStreet = const Value.absent(),
    Value<String?> addressNumber = const Value.absent(),
    Value<String?> addressComplement = const Value.absent(),
    Value<String?> addressDistrict = const Value.absent(),
    Value<String?> addressCity = const Value.absent(),
    Value<String?> addressState = const Value.absent(),
    Value<String?> addressPostalCode = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> legalRepName = const Value.absent(),
    Value<String?> legalRepCpf = const Value.absent(),
    Value<String?> legalRepPhone = const Value.absent(),
    Value<String?> legalRepEmail = const Value.absent(),
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => Company(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    legalName: legalName ?? this.legalName,
    tradeName: tradeName.present ? tradeName.value : this.tradeName,
    cnpj: cnpj.present ? cnpj.value : this.cnpj,
    stateRegistration: stateRegistration.present
        ? stateRegistration.value
        : this.stateRegistration,
    addressStreet: addressStreet.present
        ? addressStreet.value
        : this.addressStreet,
    addressNumber: addressNumber.present
        ? addressNumber.value
        : this.addressNumber,
    addressComplement: addressComplement.present
        ? addressComplement.value
        : this.addressComplement,
    addressDistrict: addressDistrict.present
        ? addressDistrict.value
        : this.addressDistrict,
    addressCity: addressCity.present ? addressCity.value : this.addressCity,
    addressState: addressState.present ? addressState.value : this.addressState,
    addressPostalCode: addressPostalCode.present
        ? addressPostalCode.value
        : this.addressPostalCode,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    legalRepName: legalRepName.present ? legalRepName.value : this.legalRepName,
    legalRepCpf: legalRepCpf.present ? legalRepCpf.value : this.legalRepCpf,
    legalRepPhone: legalRepPhone.present
        ? legalRepPhone.value
        : this.legalRepPhone,
    legalRepEmail: legalRepEmail.present
        ? legalRepEmail.value
        : this.legalRepEmail,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  Company copyWithCompanion(CompaniesCompanion data) {
    return Company(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      legalName: data.legalName.present ? data.legalName.value : this.legalName,
      tradeName: data.tradeName.present ? data.tradeName.value : this.tradeName,
      cnpj: data.cnpj.present ? data.cnpj.value : this.cnpj,
      stateRegistration: data.stateRegistration.present
          ? data.stateRegistration.value
          : this.stateRegistration,
      addressStreet: data.addressStreet.present
          ? data.addressStreet.value
          : this.addressStreet,
      addressNumber: data.addressNumber.present
          ? data.addressNumber.value
          : this.addressNumber,
      addressComplement: data.addressComplement.present
          ? data.addressComplement.value
          : this.addressComplement,
      addressDistrict: data.addressDistrict.present
          ? data.addressDistrict.value
          : this.addressDistrict,
      addressCity: data.addressCity.present
          ? data.addressCity.value
          : this.addressCity,
      addressState: data.addressState.present
          ? data.addressState.value
          : this.addressState,
      addressPostalCode: data.addressPostalCode.present
          ? data.addressPostalCode.value
          : this.addressPostalCode,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      legalRepName: data.legalRepName.present
          ? data.legalRepName.value
          : this.legalRepName,
      legalRepCpf: data.legalRepCpf.present
          ? data.legalRepCpf.value
          : this.legalRepCpf,
      legalRepPhone: data.legalRepPhone.present
          ? data.legalRepPhone.value
          : this.legalRepPhone,
      legalRepEmail: data.legalRepEmail.present
          ? data.legalRepEmail.value
          : this.legalRepEmail,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Company(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('legalName: $legalName, ')
          ..write('tradeName: $tradeName, ')
          ..write('cnpj: $cnpj, ')
          ..write('stateRegistration: $stateRegistration, ')
          ..write('addressStreet: $addressStreet, ')
          ..write('addressNumber: $addressNumber, ')
          ..write('addressComplement: $addressComplement, ')
          ..write('addressDistrict: $addressDistrict, ')
          ..write('addressCity: $addressCity, ')
          ..write('addressState: $addressState, ')
          ..write('addressPostalCode: $addressPostalCode, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('legalRepName: $legalRepName, ')
          ..write('legalRepCpf: $legalRepCpf, ')
          ..write('legalRepPhone: $legalRepPhone, ')
          ..write('legalRepEmail: $legalRepEmail, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    deletedAt,
    legalName,
    tradeName,
    cnpj,
    stateRegistration,
    addressStreet,
    addressNumber,
    addressComplement,
    addressDistrict,
    addressCity,
    addressState,
    addressPostalCode,
    phone,
    email,
    legalRepName,
    legalRepCpf,
    legalRepPhone,
    legalRepEmail,
    archivedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Company &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.legalName == this.legalName &&
          other.tradeName == this.tradeName &&
          other.cnpj == this.cnpj &&
          other.stateRegistration == this.stateRegistration &&
          other.addressStreet == this.addressStreet &&
          other.addressNumber == this.addressNumber &&
          other.addressComplement == this.addressComplement &&
          other.addressDistrict == this.addressDistrict &&
          other.addressCity == this.addressCity &&
          other.addressState == this.addressState &&
          other.addressPostalCode == this.addressPostalCode &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.legalRepName == this.legalRepName &&
          other.legalRepCpf == this.legalRepCpf &&
          other.legalRepPhone == this.legalRepPhone &&
          other.legalRepEmail == this.legalRepEmail &&
          other.archivedAt == this.archivedAt);
}

class CompaniesCompanion extends UpdateCompanion<Company> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> legalName;
  final Value<String?> tradeName;
  final Value<String?> cnpj;
  final Value<String?> stateRegistration;
  final Value<String?> addressStreet;
  final Value<String?> addressNumber;
  final Value<String?> addressComplement;
  final Value<String?> addressDistrict;
  final Value<String?> addressCity;
  final Value<String?> addressState;
  final Value<String?> addressPostalCode;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> legalRepName;
  final Value<String?> legalRepCpf;
  final Value<String?> legalRepPhone;
  final Value<String?> legalRepEmail;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const CompaniesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.legalName = const Value.absent(),
    this.tradeName = const Value.absent(),
    this.cnpj = const Value.absent(),
    this.stateRegistration = const Value.absent(),
    this.addressStreet = const Value.absent(),
    this.addressNumber = const Value.absent(),
    this.addressComplement = const Value.absent(),
    this.addressDistrict = const Value.absent(),
    this.addressCity = const Value.absent(),
    this.addressState = const Value.absent(),
    this.addressPostalCode = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.legalRepName = const Value.absent(),
    this.legalRepCpf = const Value.absent(),
    this.legalRepPhone = const Value.absent(),
    this.legalRepEmail = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompaniesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String legalName,
    this.tradeName = const Value.absent(),
    this.cnpj = const Value.absent(),
    this.stateRegistration = const Value.absent(),
    this.addressStreet = const Value.absent(),
    this.addressNumber = const Value.absent(),
    this.addressComplement = const Value.absent(),
    this.addressDistrict = const Value.absent(),
    this.addressCity = const Value.absent(),
    this.addressState = const Value.absent(),
    this.addressPostalCode = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.legalRepName = const Value.absent(),
    this.legalRepCpf = const Value.absent(),
    this.legalRepPhone = const Value.absent(),
    this.legalRepEmail = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       legalName = Value(legalName);
  static Insertable<Company> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? legalName,
    Expression<String>? tradeName,
    Expression<String>? cnpj,
    Expression<String>? stateRegistration,
    Expression<String>? addressStreet,
    Expression<String>? addressNumber,
    Expression<String>? addressComplement,
    Expression<String>? addressDistrict,
    Expression<String>? addressCity,
    Expression<String>? addressState,
    Expression<String>? addressPostalCode,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? legalRepName,
    Expression<String>? legalRepCpf,
    Expression<String>? legalRepPhone,
    Expression<String>? legalRepEmail,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (legalName != null) 'legal_name': legalName,
      if (tradeName != null) 'trade_name': tradeName,
      if (cnpj != null) 'cnpj': cnpj,
      if (stateRegistration != null) 'state_registration': stateRegistration,
      if (addressStreet != null) 'address_street': addressStreet,
      if (addressNumber != null) 'address_number': addressNumber,
      if (addressComplement != null) 'address_complement': addressComplement,
      if (addressDistrict != null) 'address_district': addressDistrict,
      if (addressCity != null) 'address_city': addressCity,
      if (addressState != null) 'address_state': addressState,
      if (addressPostalCode != null) 'address_postal_code': addressPostalCode,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (legalRepName != null) 'legal_rep_name': legalRepName,
      if (legalRepCpf != null) 'legal_rep_cpf': legalRepCpf,
      if (legalRepPhone != null) 'legal_rep_phone': legalRepPhone,
      if (legalRepEmail != null) 'legal_rep_email': legalRepEmail,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompaniesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? legalName,
    Value<String?>? tradeName,
    Value<String?>? cnpj,
    Value<String?>? stateRegistration,
    Value<String?>? addressStreet,
    Value<String?>? addressNumber,
    Value<String?>? addressComplement,
    Value<String?>? addressDistrict,
    Value<String?>? addressCity,
    Value<String?>? addressState,
    Value<String?>? addressPostalCode,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? legalRepName,
    Value<String?>? legalRepCpf,
    Value<String?>? legalRepPhone,
    Value<String?>? legalRepEmail,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return CompaniesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      legalName: legalName ?? this.legalName,
      tradeName: tradeName ?? this.tradeName,
      cnpj: cnpj ?? this.cnpj,
      stateRegistration: stateRegistration ?? this.stateRegistration,
      addressStreet: addressStreet ?? this.addressStreet,
      addressNumber: addressNumber ?? this.addressNumber,
      addressComplement: addressComplement ?? this.addressComplement,
      addressDistrict: addressDistrict ?? this.addressDistrict,
      addressCity: addressCity ?? this.addressCity,
      addressState: addressState ?? this.addressState,
      addressPostalCode: addressPostalCode ?? this.addressPostalCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      legalRepName: legalRepName ?? this.legalRepName,
      legalRepCpf: legalRepCpf ?? this.legalRepCpf,
      legalRepPhone: legalRepPhone ?? this.legalRepPhone,
      legalRepEmail: legalRepEmail ?? this.legalRepEmail,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (legalName.present) {
      map['legal_name'] = Variable<String>(legalName.value);
    }
    if (tradeName.present) {
      map['trade_name'] = Variable<String>(tradeName.value);
    }
    if (cnpj.present) {
      map['cnpj'] = Variable<String>(cnpj.value);
    }
    if (stateRegistration.present) {
      map['state_registration'] = Variable<String>(stateRegistration.value);
    }
    if (addressStreet.present) {
      map['address_street'] = Variable<String>(addressStreet.value);
    }
    if (addressNumber.present) {
      map['address_number'] = Variable<String>(addressNumber.value);
    }
    if (addressComplement.present) {
      map['address_complement'] = Variable<String>(addressComplement.value);
    }
    if (addressDistrict.present) {
      map['address_district'] = Variable<String>(addressDistrict.value);
    }
    if (addressCity.present) {
      map['address_city'] = Variable<String>(addressCity.value);
    }
    if (addressState.present) {
      map['address_state'] = Variable<String>(addressState.value);
    }
    if (addressPostalCode.present) {
      map['address_postal_code'] = Variable<String>(addressPostalCode.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (legalRepName.present) {
      map['legal_rep_name'] = Variable<String>(legalRepName.value);
    }
    if (legalRepCpf.present) {
      map['legal_rep_cpf'] = Variable<String>(legalRepCpf.value);
    }
    if (legalRepPhone.present) {
      map['legal_rep_phone'] = Variable<String>(legalRepPhone.value);
    }
    if (legalRepEmail.present) {
      map['legal_rep_email'] = Variable<String>(legalRepEmail.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompaniesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('legalName: $legalName, ')
          ..write('tradeName: $tradeName, ')
          ..write('cnpj: $cnpj, ')
          ..write('stateRegistration: $stateRegistration, ')
          ..write('addressStreet: $addressStreet, ')
          ..write('addressNumber: $addressNumber, ')
          ..write('addressComplement: $addressComplement, ')
          ..write('addressDistrict: $addressDistrict, ')
          ..write('addressCity: $addressCity, ')
          ..write('addressState: $addressState, ')
          ..write('addressPostalCode: $addressPostalCode, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('legalRepName: $legalRepName, ')
          ..write('legalRepCpf: $legalRepCpf, ')
          ..write('legalRepPhone: $legalRepPhone, ')
          ..write('legalRepEmail: $legalRepEmail, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompanyModulesTable extends CompanyModules
    with TableInfo<$CompanyModulesTable, CompanyModule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompanyModulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _moduleTypeMeta = const VerificationMeta(
    'moduleType',
  );
  @override
  late final GeneratedColumn<String> moduleType = GeneratedColumn<String>(
    'module_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    companyId,
    moduleType,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'company_modules';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompanyModule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('module_type')) {
      context.handle(
        _moduleTypeMeta,
        moduleType.isAcceptableOrUnknown(data['module_type']!, _moduleTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleTypeMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    } else if (isInserting) {
      context.missing(_enabledMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {companyId, moduleType},
  ];
  @override
  CompanyModule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompanyModule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      moduleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module_type'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $CompanyModulesTable createAlias(String alias) {
    return $CompanyModulesTable(attachedDatabase, alias);
  }
}

class CompanyModule extends DataClass implements Insertable<CompanyModule> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String companyId;

  /// `ModuleType.code`.
  final String moduleType;
  final bool enabled;
  const CompanyModule({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.companyId,
    required this.moduleType,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['company_id'] = Variable<String>(companyId);
    map['module_type'] = Variable<String>(moduleType);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  CompanyModulesCompanion toCompanion(bool nullToAbsent) {
    return CompanyModulesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      companyId: Value(companyId),
      moduleType: Value(moduleType),
      enabled: Value(enabled),
    );
  }

  factory CompanyModule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompanyModule(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      companyId: serializer.fromJson<String>(json['companyId']),
      moduleType: serializer.fromJson<String>(json['moduleType']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'companyId': serializer.toJson<String>(companyId),
      'moduleType': serializer.toJson<String>(moduleType),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  CompanyModule copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? companyId,
    String? moduleType,
    bool? enabled,
  }) => CompanyModule(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    companyId: companyId ?? this.companyId,
    moduleType: moduleType ?? this.moduleType,
    enabled: enabled ?? this.enabled,
  );
  CompanyModule copyWithCompanion(CompanyModulesCompanion data) {
    return CompanyModule(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      moduleType: data.moduleType.present
          ? data.moduleType.value
          : this.moduleType,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompanyModule(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('companyId: $companyId, ')
          ..write('moduleType: $moduleType, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    companyId,
    moduleType,
    enabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompanyModule &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.companyId == this.companyId &&
          other.moduleType == this.moduleType &&
          other.enabled == this.enabled);
}

class CompanyModulesCompanion extends UpdateCompanion<CompanyModule> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> companyId;
  final Value<String> moduleType;
  final Value<bool> enabled;
  final Value<int> rowid;
  const CompanyModulesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.companyId = const Value.absent(),
    this.moduleType = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompanyModulesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String companyId,
    required String moduleType,
    required bool enabled,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       companyId = Value(companyId),
       moduleType = Value(moduleType),
       enabled = Value(enabled);
  static Insertable<CompanyModule> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? companyId,
    Expression<String>? moduleType,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (companyId != null) 'company_id': companyId,
      if (moduleType != null) 'module_type': moduleType,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompanyModulesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? companyId,
    Value<String>? moduleType,
    Value<bool>? enabled,
    Value<int>? rowid,
  }) {
    return CompanyModulesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      companyId: companyId ?? this.companyId,
      moduleType: moduleType ?? this.moduleType,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (moduleType.present) {
      map['module_type'] = Variable<String>(moduleType.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompanyModulesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('companyId: $companyId, ')
          ..write('moduleType: $moduleType, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompanyAuthoritiesTable extends CompanyAuthorities
    with TableInfo<$CompanyAuthoritiesTable, CompanyAuthority> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompanyAuthoritiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _authorityMeta = const VerificationMeta(
    'authority',
  );
  @override
  late final GeneratedColumn<String> authority = GeneratedColumn<String>(
    'authority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registrationNumberMeta =
      const VerificationMeta('registrationNumber');
  @override
  late final GeneratedColumn<String> registrationNumber =
      GeneratedColumn<String>(
        'registration_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> validUntil =
      GeneratedColumn<String>(
        'valid_until',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>(
        $CompanyAuthoritiesTable.$convertervalidUntiln,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    companyId,
    authority,
    status,
    registrationNumber,
    validUntil,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'company_authorities';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompanyAuthority> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('authority')) {
      context.handle(
        _authorityMeta,
        authority.isAcceptableOrUnknown(data['authority']!, _authorityMeta),
      );
    } else if (isInserting) {
      context.missing(_authorityMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('registration_number')) {
      context.handle(
        _registrationNumberMeta,
        registrationNumber.isAcceptableOrUnknown(
          data['registration_number']!,
          _registrationNumberMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {companyId, authority},
  ];
  @override
  CompanyAuthority map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompanyAuthority(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      authority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authority'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      registrationNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registration_number'],
      ),
      validUntil: $CompanyAuthoritiesTable.$convertervalidUntiln.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}valid_until'],
        ),
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $CompanyAuthoritiesTable createAlias(String alias) {
    return $CompanyAuthoritiesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertervalidUntil =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $convertervalidUntiln =
      NullAwareTypeConverter.wrap($convertervalidUntil);
}

class CompanyAuthority extends DataClass
    implements Insertable<CompanyAuthority> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String companyId;

  /// `Authority.code`.
  final String authority;

  /// `RegistrationStatus.code`.
  final String status;
  final String? registrationNumber;
  final DateTime? validUntil;
  final String? notes;
  const CompanyAuthority({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.companyId,
    required this.authority,
    required this.status,
    this.registrationNumber,
    this.validUntil,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['company_id'] = Variable<String>(companyId);
    map['authority'] = Variable<String>(authority);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || registrationNumber != null) {
      map['registration_number'] = Variable<String>(registrationNumber);
    }
    if (!nullToAbsent || validUntil != null) {
      map['valid_until'] = Variable<String>(
        $CompanyAuthoritiesTable.$convertervalidUntiln.toSql(validUntil),
      );
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  CompanyAuthoritiesCompanion toCompanion(bool nullToAbsent) {
    return CompanyAuthoritiesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      companyId: Value(companyId),
      authority: Value(authority),
      status: Value(status),
      registrationNumber: registrationNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(registrationNumber),
      validUntil: validUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(validUntil),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory CompanyAuthority.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompanyAuthority(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      companyId: serializer.fromJson<String>(json['companyId']),
      authority: serializer.fromJson<String>(json['authority']),
      status: serializer.fromJson<String>(json['status']),
      registrationNumber: serializer.fromJson<String?>(
        json['registrationNumber'],
      ),
      validUntil: serializer.fromJson<DateTime?>(json['validUntil']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'companyId': serializer.toJson<String>(companyId),
      'authority': serializer.toJson<String>(authority),
      'status': serializer.toJson<String>(status),
      'registrationNumber': serializer.toJson<String?>(registrationNumber),
      'validUntil': serializer.toJson<DateTime?>(validUntil),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  CompanyAuthority copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? companyId,
    String? authority,
    String? status,
    Value<String?> registrationNumber = const Value.absent(),
    Value<DateTime?> validUntil = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => CompanyAuthority(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    companyId: companyId ?? this.companyId,
    authority: authority ?? this.authority,
    status: status ?? this.status,
    registrationNumber: registrationNumber.present
        ? registrationNumber.value
        : this.registrationNumber,
    validUntil: validUntil.present ? validUntil.value : this.validUntil,
    notes: notes.present ? notes.value : this.notes,
  );
  CompanyAuthority copyWithCompanion(CompanyAuthoritiesCompanion data) {
    return CompanyAuthority(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      authority: data.authority.present ? data.authority.value : this.authority,
      status: data.status.present ? data.status.value : this.status,
      registrationNumber: data.registrationNumber.present
          ? data.registrationNumber.value
          : this.registrationNumber,
      validUntil: data.validUntil.present
          ? data.validUntil.value
          : this.validUntil,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompanyAuthority(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('companyId: $companyId, ')
          ..write('authority: $authority, ')
          ..write('status: $status, ')
          ..write('registrationNumber: $registrationNumber, ')
          ..write('validUntil: $validUntil, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    companyId,
    authority,
    status,
    registrationNumber,
    validUntil,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompanyAuthority &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.companyId == this.companyId &&
          other.authority == this.authority &&
          other.status == this.status &&
          other.registrationNumber == this.registrationNumber &&
          other.validUntil == this.validUntil &&
          other.notes == this.notes);
}

class CompanyAuthoritiesCompanion extends UpdateCompanion<CompanyAuthority> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> companyId;
  final Value<String> authority;
  final Value<String> status;
  final Value<String?> registrationNumber;
  final Value<DateTime?> validUntil;
  final Value<String?> notes;
  final Value<int> rowid;
  const CompanyAuthoritiesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.companyId = const Value.absent(),
    this.authority = const Value.absent(),
    this.status = const Value.absent(),
    this.registrationNumber = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompanyAuthoritiesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String companyId,
    required String authority,
    required String status,
    this.registrationNumber = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       companyId = Value(companyId),
       authority = Value(authority),
       status = Value(status);
  static Insertable<CompanyAuthority> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? companyId,
    Expression<String>? authority,
    Expression<String>? status,
    Expression<String>? registrationNumber,
    Expression<String>? validUntil,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (companyId != null) 'company_id': companyId,
      if (authority != null) 'authority': authority,
      if (status != null) 'status': status,
      if (registrationNumber != null) 'registration_number': registrationNumber,
      if (validUntil != null) 'valid_until': validUntil,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompanyAuthoritiesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? companyId,
    Value<String>? authority,
    Value<String>? status,
    Value<String?>? registrationNumber,
    Value<DateTime?>? validUntil,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return CompanyAuthoritiesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      companyId: companyId ?? this.companyId,
      authority: authority ?? this.authority,
      status: status ?? this.status,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      validUntil: validUntil ?? this.validUntil,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (authority.present) {
      map['authority'] = Variable<String>(authority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (registrationNumber.present) {
      map['registration_number'] = Variable<String>(registrationNumber.value);
    }
    if (validUntil.present) {
      map['valid_until'] = Variable<String>(
        $CompanyAuthoritiesTable.$convertervalidUntiln.toSql(validUntil.value),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompanyAuthoritiesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('companyId: $companyId, ')
          ..write('authority: $authority, ')
          ..write('status: $status, ')
          ..write('registrationNumber: $registrationNumber, ')
          ..write('validUntil: $validUntil, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CompaniesTable companies = $CompaniesTable(this);
  late final $CompanyModulesTable companyModules = $CompanyModulesTable(this);
  late final $CompanyAuthoritiesTable companyAuthorities =
      $CompanyAuthoritiesTable(this);
  late final Index companiesCnpjActive = Index(
    'companies_cnpj_active',
    'CREATE UNIQUE INDEX companies_cnpj_active ON companies (cnpj) WHERE cnpj IS NOT NULL AND deleted_at IS NULL',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    companies,
    companyModules,
    companyAuthorities,
    companiesCnpjActive,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$CompaniesTableCreateCompanionBuilder = CompaniesCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String legalName,
  Value<String?> tradeName,
  Value<String?> cnpj,
  Value<String?> stateRegistration,
  Value<String?> addressStreet,
  Value<String?> addressNumber,
  Value<String?> addressComplement,
  Value<String?> addressDistrict,
  Value<String?> addressCity,
  Value<String?> addressState,
  Value<String?> addressPostalCode,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> legalRepName,
  Value<String?> legalRepCpf,
  Value<String?> legalRepPhone,
  Value<String?> legalRepEmail,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});
typedef $$CompaniesTableUpdateCompanionBuilder = CompaniesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> legalName,
  Value<String?> tradeName,
  Value<String?> cnpj,
  Value<String?> stateRegistration,
  Value<String?> addressStreet,
  Value<String?> addressNumber,
  Value<String?> addressComplement,
  Value<String?> addressDistrict,
  Value<String?> addressCity,
  Value<String?> addressState,
  Value<String?> addressPostalCode,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> legalRepName,
  Value<String?> legalRepCpf,
  Value<String?> legalRepPhone,
  Value<String?> legalRepEmail,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});

final class $$CompaniesTableReferences
    extends BaseReferences<_$AppDatabase, $CompaniesTable, Company> {
  $$CompaniesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CompanyModulesTable, List<CompanyModule>>
  _companyModulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.companyModules,
    aliasName: 'companies__id__company_modules__company_id',
  );

  $$CompanyModulesTableProcessedTableManager get companyModulesRefs {
    final manager = $$CompanyModulesTableTableManager(
      $_db,
      $_db.companyModules,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_companyModulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CompanyAuthoritiesTable, List<CompanyAuthority>>
  _companyAuthoritiesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.companyAuthorities,
        aliasName: 'companies__id__company_authorities__company_id',
      );

  $$CompanyAuthoritiesTableProcessedTableManager get companyAuthoritiesRefs {
    final manager = $$CompanyAuthoritiesTableTableManager(
      $_db,
      $_db.companyAuthorities,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _companyAuthoritiesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CompaniesTableFilterComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalName => $composableBuilder(
    column: $table.legalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tradeName => $composableBuilder(
    column: $table.tradeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cnpj => $composableBuilder(
    column: $table.cnpj,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stateRegistration => $composableBuilder(
    column: $table.stateRegistration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressStreet => $composableBuilder(
    column: $table.addressStreet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressNumber => $composableBuilder(
    column: $table.addressNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressComplement => $composableBuilder(
    column: $table.addressComplement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressDistrict => $composableBuilder(
    column: $table.addressDistrict,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressCity => $composableBuilder(
    column: $table.addressCity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressState => $composableBuilder(
    column: $table.addressState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressPostalCode => $composableBuilder(
    column: $table.addressPostalCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalRepName => $composableBuilder(
    column: $table.legalRepName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalRepCpf => $composableBuilder(
    column: $table.legalRepCpf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalRepPhone => $composableBuilder(
    column: $table.legalRepPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalRepEmail => $composableBuilder(
    column: $table.legalRepEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> companyModulesRefs(
    Expression<bool> Function($$CompanyModulesTableFilterComposer f) f,
  ) {
    final $$CompanyModulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.companyModules,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompanyModulesTableFilterComposer(
            $db: $db,
            $table: $db.companyModules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> companyAuthoritiesRefs(
    Expression<bool> Function($$CompanyAuthoritiesTableFilterComposer f) f,
  ) {
    final $$CompanyAuthoritiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.companyAuthorities,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompanyAuthoritiesTableFilterComposer(
            $db: $db,
            $table: $db.companyAuthorities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompaniesTableOrderingComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalName => $composableBuilder(
    column: $table.legalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tradeName => $composableBuilder(
    column: $table.tradeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cnpj => $composableBuilder(
    column: $table.cnpj,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stateRegistration => $composableBuilder(
    column: $table.stateRegistration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressStreet => $composableBuilder(
    column: $table.addressStreet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressNumber => $composableBuilder(
    column: $table.addressNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressComplement => $composableBuilder(
    column: $table.addressComplement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressDistrict => $composableBuilder(
    column: $table.addressDistrict,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressCity => $composableBuilder(
    column: $table.addressCity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressState => $composableBuilder(
    column: $table.addressState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressPostalCode => $composableBuilder(
    column: $table.addressPostalCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalRepName => $composableBuilder(
    column: $table.legalRepName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalRepCpf => $composableBuilder(
    column: $table.legalRepCpf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalRepPhone => $composableBuilder(
    column: $table.legalRepPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalRepEmail => $composableBuilder(
    column: $table.legalRepEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompaniesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get legalName =>
      $composableBuilder(column: $table.legalName, builder: (column) => column);

  GeneratedColumn<String> get tradeName =>
      $composableBuilder(column: $table.tradeName, builder: (column) => column);

  GeneratedColumn<String> get cnpj =>
      $composableBuilder(column: $table.cnpj, builder: (column) => column);

  GeneratedColumn<String> get stateRegistration => $composableBuilder(
    column: $table.stateRegistration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get addressStreet => $composableBuilder(
    column: $table.addressStreet,
    builder: (column) => column,
  );

  GeneratedColumn<String> get addressNumber => $composableBuilder(
    column: $table.addressNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get addressComplement => $composableBuilder(
    column: $table.addressComplement,
    builder: (column) => column,
  );

  GeneratedColumn<String> get addressDistrict => $composableBuilder(
    column: $table.addressDistrict,
    builder: (column) => column,
  );

  GeneratedColumn<String> get addressCity => $composableBuilder(
    column: $table.addressCity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get addressState => $composableBuilder(
    column: $table.addressState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get addressPostalCode => $composableBuilder(
    column: $table.addressPostalCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get legalRepName => $composableBuilder(
    column: $table.legalRepName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalRepCpf => $composableBuilder(
    column: $table.legalRepCpf,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalRepPhone => $composableBuilder(
    column: $table.legalRepPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalRepEmail => $composableBuilder(
    column: $table.legalRepEmail,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  Expression<T> companyModulesRefs<T extends Object>(
    Expression<T> Function($$CompanyModulesTableAnnotationComposer a) f,
  ) {
    final $$CompanyModulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.companyModules,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompanyModulesTableAnnotationComposer(
            $db: $db,
            $table: $db.companyModules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> companyAuthoritiesRefs<T extends Object>(
    Expression<T> Function($$CompanyAuthoritiesTableAnnotationComposer a) f,
  ) {
    final $$CompanyAuthoritiesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.companyAuthorities,
          getReferencedColumn: (t) => t.companyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompanyAuthoritiesTableAnnotationComposer(
                $db: $db,
                $table: $db.companyAuthorities,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CompaniesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompaniesTable,
          Company,
          $$CompaniesTableFilterComposer,
          $$CompaniesTableOrderingComposer,
          $$CompaniesTableAnnotationComposer,
          $$CompaniesTableCreateCompanionBuilder,
          $$CompaniesTableUpdateCompanionBuilder,
          (Company, $$CompaniesTableReferences),
          Company,
          PrefetchHooks Function({
            bool companyModulesRefs,
            bool companyAuthoritiesRefs,
          })
        > {
  $$CompaniesTableTableManager(_$AppDatabase db, $CompaniesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompaniesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompaniesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompaniesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> legalName = const Value.absent(),
                Value<String?> tradeName = const Value.absent(),
                Value<String?> cnpj = const Value.absent(),
                Value<String?> stateRegistration = const Value.absent(),
                Value<String?> addressStreet = const Value.absent(),
                Value<String?> addressNumber = const Value.absent(),
                Value<String?> addressComplement = const Value.absent(),
                Value<String?> addressDistrict = const Value.absent(),
                Value<String?> addressCity = const Value.absent(),
                Value<String?> addressState = const Value.absent(),
                Value<String?> addressPostalCode = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> legalRepName = const Value.absent(),
                Value<String?> legalRepCpf = const Value.absent(),
                Value<String?> legalRepPhone = const Value.absent(),
                Value<String?> legalRepEmail = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompaniesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                legalName: legalName,
                tradeName: tradeName,
                cnpj: cnpj,
                stateRegistration: stateRegistration,
                addressStreet: addressStreet,
                addressNumber: addressNumber,
                addressComplement: addressComplement,
                addressDistrict: addressDistrict,
                addressCity: addressCity,
                addressState: addressState,
                addressPostalCode: addressPostalCode,
                phone: phone,
                email: email,
                legalRepName: legalRepName,
                legalRepCpf: legalRepCpf,
                legalRepPhone: legalRepPhone,
                legalRepEmail: legalRepEmail,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String legalName,
                Value<String?> tradeName = const Value.absent(),
                Value<String?> cnpj = const Value.absent(),
                Value<String?> stateRegistration = const Value.absent(),
                Value<String?> addressStreet = const Value.absent(),
                Value<String?> addressNumber = const Value.absent(),
                Value<String?> addressComplement = const Value.absent(),
                Value<String?> addressDistrict = const Value.absent(),
                Value<String?> addressCity = const Value.absent(),
                Value<String?> addressState = const Value.absent(),
                Value<String?> addressPostalCode = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> legalRepName = const Value.absent(),
                Value<String?> legalRepCpf = const Value.absent(),
                Value<String?> legalRepPhone = const Value.absent(),
                Value<String?> legalRepEmail = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompaniesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                legalName: legalName,
                tradeName: tradeName,
                cnpj: cnpj,
                stateRegistration: stateRegistration,
                addressStreet: addressStreet,
                addressNumber: addressNumber,
                addressComplement: addressComplement,
                addressDistrict: addressDistrict,
                addressCity: addressCity,
                addressState: addressState,
                addressPostalCode: addressPostalCode,
                phone: phone,
                email: email,
                legalRepName: legalRepName,
                legalRepCpf: legalRepCpf,
                legalRepPhone: legalRepPhone,
                legalRepEmail: legalRepEmail,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompaniesTable, Company>(table),
                  $$CompaniesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({companyModulesRefs = false, companyAuthoritiesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (companyModulesRefs) db.companyModules,
                    if (companyAuthoritiesRefs) db.companyAuthorities,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (companyModulesRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          CompanyModule
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._companyModulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).companyModulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (companyAuthoritiesRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          CompanyAuthority
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._companyAuthoritiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).companyAuthoritiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CompaniesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompaniesTable,
      Company,
      $$CompaniesTableFilterComposer,
      $$CompaniesTableOrderingComposer,
      $$CompaniesTableAnnotationComposer,
      $$CompaniesTableCreateCompanionBuilder,
      $$CompaniesTableUpdateCompanionBuilder,
      (Company, $$CompaniesTableReferences),
      Company,
      PrefetchHooks Function({
        bool companyModulesRefs,
        bool companyAuthoritiesRefs,
      })
    >;
typedef $$CompanyModulesTableCreateCompanionBuilder =
    CompanyModulesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String companyId,
      required String moduleType,
      required bool enabled,
      Value<int> rowid,
    });
typedef $$CompanyModulesTableUpdateCompanionBuilder =
    CompanyModulesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> companyId,
      Value<String> moduleType,
      Value<bool> enabled,
      Value<int> rowid,
    });

final class $$CompanyModulesTableReferences
    extends BaseReferences<_$AppDatabase, $CompanyModulesTable, CompanyModule> {
  $$CompanyModulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias('company_modules__company_id__companies__id');

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CompanyModulesTableFilterComposer
    extends Composer<_$AppDatabase, $CompanyModulesTable> {
  $$CompanyModulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moduleType => $composableBuilder(
    column: $table.moduleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompanyModulesTableOrderingComposer
    extends Composer<_$AppDatabase, $CompanyModulesTable> {
  $$CompanyModulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moduleType => $composableBuilder(
    column: $table.moduleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompanyModulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompanyModulesTable> {
  $$CompanyModulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get moduleType => $composableBuilder(
    column: $table.moduleType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompanyModulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompanyModulesTable,
          CompanyModule,
          $$CompanyModulesTableFilterComposer,
          $$CompanyModulesTableOrderingComposer,
          $$CompanyModulesTableAnnotationComposer,
          $$CompanyModulesTableCreateCompanionBuilder,
          $$CompanyModulesTableUpdateCompanionBuilder,
          (CompanyModule, $$CompanyModulesTableReferences),
          CompanyModule,
          PrefetchHooks Function({bool companyId})
        > {
  $$CompanyModulesTableTableManager(
    _$AppDatabase db,
    $CompanyModulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompanyModulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompanyModulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompanyModulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> moduleType = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompanyModulesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                companyId: companyId,
                moduleType: moduleType,
                enabled: enabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String companyId,
                required String moduleType,
                required bool enabled,
                Value<int> rowid = const Value.absent(),
              }) => CompanyModulesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                companyId: companyId,
                moduleType: moduleType,
                enabled: enabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompanyModulesTable, CompanyModule>(table),
                  $$CompanyModulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (companyId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.companyId,
                        referencedTable: $$CompanyModulesTableReferences
                            ._companyIdTable(db),
                        referencedColumn: $$CompanyModulesTableReferences
                            ._companyIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CompanyModulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompanyModulesTable,
      CompanyModule,
      $$CompanyModulesTableFilterComposer,
      $$CompanyModulesTableOrderingComposer,
      $$CompanyModulesTableAnnotationComposer,
      $$CompanyModulesTableCreateCompanionBuilder,
      $$CompanyModulesTableUpdateCompanionBuilder,
      (CompanyModule, $$CompanyModulesTableReferences),
      CompanyModule,
      PrefetchHooks Function({bool companyId})
    >;
typedef $$CompanyAuthoritiesTableCreateCompanionBuilder =
    CompanyAuthoritiesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String companyId,
      required String authority,
      required String status,
      Value<String?> registrationNumber,
      Value<DateTime?> validUntil,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$CompanyAuthoritiesTableUpdateCompanionBuilder =
    CompanyAuthoritiesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> companyId,
      Value<String> authority,
      Value<String> status,
      Value<String?> registrationNumber,
      Value<DateTime?> validUntil,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$CompanyAuthoritiesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CompanyAuthoritiesTable,
          CompanyAuthority
        > {
  $$CompanyAuthoritiesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CompaniesTable _companyIdTable(_$AppDatabase db) => db.companies
      .createAlias('company_authorities__company_id__companies__id');

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CompanyAuthoritiesTableFilterComposer
    extends Composer<_$AppDatabase, $CompanyAuthoritiesTable> {
  $$CompanyAuthoritiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authority => $composableBuilder(
    column: $table.authority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registrationNumber => $composableBuilder(
    column: $table.registrationNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get validUntil =>
      $composableBuilder(
        column: $table.validUntil,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompanyAuthoritiesTableOrderingComposer
    extends Composer<_$AppDatabase, $CompanyAuthoritiesTable> {
  $$CompanyAuthoritiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authority => $composableBuilder(
    column: $table.authority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registrationNumber => $composableBuilder(
    column: $table.registrationNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompanyAuthoritiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompanyAuthoritiesTable> {
  $$CompanyAuthoritiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get authority =>
      $composableBuilder(column: $table.authority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get registrationNumber => $composableBuilder(
    column: $table.registrationNumber,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, String> get validUntil =>
      $composableBuilder(
        column: $table.validUntil,
        builder: (column) => column,
      );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompanyAuthoritiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompanyAuthoritiesTable,
          CompanyAuthority,
          $$CompanyAuthoritiesTableFilterComposer,
          $$CompanyAuthoritiesTableOrderingComposer,
          $$CompanyAuthoritiesTableAnnotationComposer,
          $$CompanyAuthoritiesTableCreateCompanionBuilder,
          $$CompanyAuthoritiesTableUpdateCompanionBuilder,
          (CompanyAuthority, $$CompanyAuthoritiesTableReferences),
          CompanyAuthority,
          PrefetchHooks Function({bool companyId})
        > {
  $$CompanyAuthoritiesTableTableManager(
    _$AppDatabase db,
    $CompanyAuthoritiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompanyAuthoritiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompanyAuthoritiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompanyAuthoritiesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> authority = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> registrationNumber = const Value.absent(),
                Value<DateTime?> validUntil = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompanyAuthoritiesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                companyId: companyId,
                authority: authority,
                status: status,
                registrationNumber: registrationNumber,
                validUntil: validUntil,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String companyId,
                required String authority,
                required String status,
                Value<String?> registrationNumber = const Value.absent(),
                Value<DateTime?> validUntil = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompanyAuthoritiesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                companyId: companyId,
                authority: authority,
                status: status,
                registrationNumber: registrationNumber,
                validUntil: validUntil,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompanyAuthoritiesTable, CompanyAuthority>(
                    table,
                  ),
                  $$CompanyAuthoritiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (companyId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.companyId,
                        referencedTable: $$CompanyAuthoritiesTableReferences
                            ._companyIdTable(db),
                        referencedColumn: $$CompanyAuthoritiesTableReferences
                            ._companyIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CompanyAuthoritiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompanyAuthoritiesTable,
      CompanyAuthority,
      $$CompanyAuthoritiesTableFilterComposer,
      $$CompanyAuthoritiesTableOrderingComposer,
      $$CompanyAuthoritiesTableAnnotationComposer,
      $$CompanyAuthoritiesTableCreateCompanionBuilder,
      $$CompanyAuthoritiesTableUpdateCompanionBuilder,
      (CompanyAuthority, $$CompanyAuthoritiesTableReferences),
      CompanyAuthority,
      PrefetchHooks Function({bool companyId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CompaniesTableTableManager get companies =>
      $$CompaniesTableTableManager(_db, _db.companies);
  $$CompanyModulesTableTableManager get companyModules =>
      $$CompanyModulesTableTableManager(_db, _db.companyModules);
  $$CompanyAuthoritiesTableTableManager get companyAuthorities =>
      $$CompanyAuthoritiesTableTableManager(_db, _db.companyAuthorities);
}
