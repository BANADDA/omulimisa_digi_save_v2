import 'dart:convert';

import 'package:omulimisa_digi_save_v2/database/positions.dart';
import 'package:omulimisa_digi_save_v2/src/view/accounts/manage_groups/group_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'dart:async';

import '../src/view/accounts/groups/forms/ElectOfficers/ElectOfficersScreen.dart';
import '../src/view/accounts/manage_groups/meetings/start_meeting/Loans/PaymentInfo.dart';
import '../src/view/accounts/manage_groups/meetings/start_meeting/Loans/loan_applications.dart';
import '../src/view/models/group_model.dart';
import '../src/view/widgets/user_class.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String databasePath = await getDatabasesPath();
    final String path = join(databasePath, 'app_database.db');
    // print('Database path: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
      onOpen: (db) {
        db.execute('PRAGMA window_size = 4096;'); // Set window size to 4MB
      },
    );
  }

  // Future<void> initializeDatabase() async {
  //   final Database db = await database;

  //   // Check if the positions table is empty
  //   final count = Sqflite.firstIntValue(
  //       await db.rawQuery('SELECT COUNT(*) FROM positions'));

  //   if (count == 0) {
  //     // Insert default positions if the table is empty
  //     await db
  //         .rawInsert('INSERT INTO positions (name) VALUES (?)', ['Chairman']);
  //     await db
  //         .rawInsert('INSERT INTO positions (name) VALUES (?)', ['Secretary']);
  //   }
  // }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT ,
        name TEXT,
        email TEXT,
        phone TEXT,
        sex TEXT,
        country TEXT,
        dateOfBirth DATE,
        imagePath TEXT
      )
    ''');
    await db.execute('''
  CREATE TABLE meeting (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    group_id INTEGER,
    cycle_id INTEGER,
    date TEXT,
    time TEXT,
    endTime TEXT,
    location TEXT,
    facilitator TEXT,
    meetingPurpose TEXT,
    latitude REAL,
    longitude REAL,
    address TEXT,
    objectives TEXT,
    attendanceData TEXT,
    representativeData TEXT,
    proposals TEXT,
    socialFundContributions TEXT,  
    sharePurchases TEXT,
    totalLoanFund INTEGER,
    totalSocialFund INTEGER,
    sync_flag INTEGER DEFAULT 0,
    FOREIGN KEY (group_id) REFERENCES group_form(id),
    FOREIGN KEY (cycle_id) REFERENCES cyclemeeting(id)
  )
''');

    await db.execute('''
  CREATE TABLE memberShares (
    id INTEGER PRIMARY KEY AUTOINCREMENT ,
    group_id INTEGER,
    cycle_id INTEGER,
    meetingId INTEGER,
    logged_in_user_id INTEGER,
    date TEXT,  
    sharePurchases TEXT,
    sync_flag INTEGER DEFAULT 0,          
    FOREIGN KEY (meetingId) REFERENCES meeting(id) ON DELETE CASCADE,
    FOREIGN KEY (logged_in_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES group_form(id),
    FOREIGN KEY (cycle_id) REFERENCES cyclemeeting(id)
)
''');

    await db.execute('''
  CREATE TABLE cyclemeeting (
    id INTEGER PRIMARY KEY AUTOINCREMENT ,
    group_id INTEGER,
    date TEXT,
    time TEXT,
    endTime TEXT,
    location TEXT,
    facilitator TEXT,
    meetingPurpose TEXT,
    latitude REAL,
    longitude REAL,
    address TEXT,
    objectives TEXT,
    attendanceData TEXT,
    representativeData TEXT,
    proposals TEXT,
    totalLoanFund INTEGER,
    totalSocialFund INTEGER,
    socialFundContributions TEXT,  
    sharePurchases TEXT,
    sync_flag INTEGER DEFAULT 0,
    FOREIGN KEY (group_id) REFERENCES group_form(id)
)
''');

    await db.execute('''
      CREATE TABLE ActiveCycleMeeting (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id INTEGER,
        cycleMeetingID INTEGER,
        sync_flag INTEGER DEFAULT 0,
        FOREIGN KEY (group_id) REFERENCES group_form(id),
        FOREIGN KEY (cycleMeetingID) REFERENCES cyclemeeting(id)
      )
    ''');

    await db.execute('''
  CREATE TABLE shares (
    id INTEGER PRIMARY KEY AUTOINCREMENT ,
    meetingId INTEGER,
    cycle_id INTEGER,
    group_id INTEGER,
    sharePurchases TEXT,     
    sync_flag INTEGER DEFAULT 0,       
    FOREIGN KEY (meetingId) REFERENCES meeting(id),
    FOREIGN KEY (cycle_id) REFERENCES cyclemeeting(id),
    FOREIGN KEY (group_id) REFERENCES group_form(id)
  )
''');
    await db.execute('''
  CREATE TABLE social (
    id INTEGER PRIMARY KEY AUTOINCREMENT ,
    group_id INTEGER,
    meetingId INTEGER,
    socialFund TEXT,    
    sync_flag INTEGER DEFAULT 0,        
    FOREIGN KEY (meetingId) REFERENCES meeting(id),
    FOREIGN KEY (group_id) REFERENCES group_form(id)
  )
''');

    // Create a table for group profiles
    await db.execute('''
      CREATE TABLE group_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT ,
        groupName TEXT,
        countryOfOrigin TEXT,
        meetingLocation TEXT,
        groupStatus TEXT,
        groupLogoPath TEXT,
        partnerID TEXT,
        workingWithPartner TEXT,
        isWorkingWithPartner INTEGER,
        numberOfCycles TEXT,
        numberOfMeetings TEXT,
        loanFund TEXT,
        socialFund TEXT,
        sync_flag INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
  CREATE TABLE constitution_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT ,
    group_id INTEGER,
    hasConstitution INTEGER,
    constitutionFiles BLOB, 
    usesGroupShares INTEGER,
    shareValue REAL,
    maxSharesPerMember INTEGER,
    minSharesRequired INTEGER,
    frequencyOfContributions TEXT,
    offersLoans INTEGER,
    maxLoanAmount REAL,
    interestRate REAL,
    interestMethod TEXT,
    loanTerms TEXT,
    registrationFee TEXT,
    selectedCollateralRequirements TEXT,
    sync_flag INTEGER DEFAULT 0,
    FOREIGN KEY (group_id) REFERENCES group_profile(id) ON DELETE CASCADE
  )
''');

    await db.execute('''
    CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT ,
        unique_code TEXT,
        fname TEXT,
        lname TEXT,
        email TEXT,
        phone TEXT,
        sex TEXT,
        country TEXT,
        date_of_birth TEXT,  
        image TEXT,
        district TEXT,
        subCounty TEXT,
        village TEXT,
        number_of_dependents TEXT,
        family_information TEXT,
        next_of_kin_name TEXT,
        next_of_kin_has_phone_number INTEGER,
        next_of_kin_phone_number TEXT,
        pwd_type TEXT,
        sync_flag INTEGER DEFAULT 0
    )
''');

    await db.execute('''
  CREATE TABLE user_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT ,
    unique_code TEXT,
    first_name TEXT,
    last_name TEXT,
    gender TEXT,
    phone_number TEXT,
    date_of_birth TEXT,
    dependents TEXT,
    family_info TEXT,
    location TEXT,
    next_of_kin TEXT,
    next_of_kin_phone_number TEXT,
    pwd_status TEXT,
    pwd_type TEXT,
    sync_flag INTEGER DEFAULT 0,
    residency_status TEXT
  )
''');
    await db.execute('''
  CREATE TABLE group_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT ,
    user_id INTEGER,
    group_id INTEGER,  
    sync_flag INTEGER DEFAULT 0,  
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES group_profile(id) ON DELETE CASCADE
  )
''');

    await db.execute('''
  CREATE TABLE group_form (
    id INTEGER PRIMARY KEY AUTOINCREMENT ,
    group_profile_id INTEGER,
    group_id INTEGER,
    logged_in_user_id INTEGER,
    constitution_id INTEGER,
    cycle_schedule_id INTEGER,
    group_member_id INTEGER,
    assigned_position_id INTEGER,
    sync_flag INTEGER DEFAULT 0,
    FOREIGN KEY (logged_in_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES group_profile(id) ON DELETE CASCADE,
    FOREIGN KEY (group_profile_id) REFERENCES group_profile(id) ON DELETE CASCADE,
    FOREIGN KEY (constitution_id) REFERENCES constitution_table(id) ON DELETE CASCADE,
    FOREIGN KEY (cycle_schedule_id) REFERENCES cycle_schedules(id) ON DELETE CASCADE,
    FOREIGN KEY (group_member_id) REFERENCES group_members(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_position_id) REFERENCES assigned_positions(id) ON DELETE CASCADE
  )
''');

    await db.execute('''
  CREATE TABLE savings_account (
    id INTEGER PRIMARY KEY AUTOINCREMENT ,
    group_id INTEGER,
    logged_in_user_id INTEGER,
    date TEXT,
    purpose TEXT,
    amount REAL,
    sync_flag INTEGER DEFAULT 0,
    FOREIGN KEY (group_id) REFERENCES group_form(id) ON DELETE CASCADE,
    FOREIGN KEY (logged_in_user_id) REFERENCES users(id) ON DELETE CASCADE
  )
''');

    await db.execute('''
  CREATE TABLE welfare_account (
    id INTEGER PRIMARY KEY AUTOINCREMENT ,
    group_id INTEGER,
    logged_in_user_id INTEGER,
    meeting_id INTEGER,
    cycle_id INTEGER,
    amount REAL,
    sync_flag INTEGER DEFAULT 0,
    FOREIGN KEY (group_id) REFERENCES group_form(id) ON DELETE CASCADE,
    FOREIGN KEY (logged_in_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (meeting_id) REFERENCES meeting(id) ON DELETE CASCADE,
    FOREIGN KEY (cycle_id) REFERENCES cyclemeeting(id) ON DELETE CASCADE
  )
''');

    await db.execute('''CREATE TABLE group_fees (
  id INTEGER PRIMARY KEY AUTOINCREMENT ,
  member_id INTEGER,
  group_id INTEGER,
  registration_fee REAL,
  sync_flag INTEGER DEFAULT 0,
  FOREIGN KEY (member_id) REFERENCES group_members(id) ON DELETE CASCADE,
  FOREIGN KEY (group_id) REFERENCES group_form(id) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE positions (
  id INTEGER PRIMARY KEY AUTOINCREMENT ,
  name TEXT,
  sync_flag INTEGER DEFAULT 0
)
''');
    await db.execute('''
  CREATE TABLE assigned_positions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_name TEXT,
    member_id INTEGER,
    group_id INTEGER,
    sync_flag INTEGER DEFAULT 0,
    FOREIGN KEY (member_id) REFERENCES group_members(id),
    FOREIGN KEY (group_id) REFERENCES group_profile(id)
  )
''');

    await db.execute('''CREATE TABLE cycle_schedules (
    id INTEGER PRIMARY KEY AUTOINCREMENT ,
    group_id INTEGER,
    meeting_duration TEXT,
    number_of_meetings INTEGER,
    meeting_frequency TEXT,
    day_of_week TEXT,
    start_date TEXT,
    share_out_date TEXT,
    sync_flag INTEGER DEFAULT 0, 
    FOREIGN KEY (group_id) REFERENCES group_profile(id) ON DELETE CASCADE
  )''');

    await db.execute('''
  CREATE TABLE group_link (
    id INTEGER PRIMARY KEY AUTOINCREMENT ,
    group_id INTEGER,  
    group_name TEXT,
    group_image_path TEXT,
    constitution_id INTEGER,
    cycle_schedule_id INTEGER,
    group_members_id INTEGER,
    assigned_positions_id INTEGER,
    sync_flag INTEGER DEFAULT 0,
    FOREIGN KEY (group_id) REFERENCES group_profile(id)  
    FOREIGN KEY (constitution_id) REFERENCES constitution_table(id),
    FOREIGN KEY (cycle_schedule_id) REFERENCES cycle_schedules(id),
    FOREIGN KEY (group_members_id) REFERENCES group_members(id),
    FOREIGN KEY (assigned_positions_id) REFERENCES assigned_positions(id)
  )
''');

    await db.execute('''
  CREATE TABLE loan_applications (
    id INTEGER PRIMARY KEY AUTOINCREMENT ,
    group_id INTEGER,
    cycle_id INTEGER,
    meetingId INTEGER,
    submission_date TEXT,
    loan_applicant TEXT,
    group_member_id INTEGER,
    amount_needed REAL,
    loan_purpose TEXT,
    repayment_date TEXT,
    sync_flag INTEGER DEFAULT 0,           
    FOREIGN KEY (meetingId) REFERENCES meeting(id) ON DELETE CASCADE,
    FOREIGN KEY (cycle_id) REFERENCES cyclemeeting(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES group_form(id) ON DELETE CASCADE,
    FOREIGN KEY (group_member_id) REFERENCES group_members(id) ON DELETE CASCADE
  )
''');

    await db.execute('''
  CREATE TABLE social_fund_applications (
    id INTEGER PRIMARY KEY AUTOINCREMENT ,
    group_id INTEGER,
    cycle_id INTEGER,
    meeting_id INTEGER,
    submission_date TEXT,
    applicant TEXT,
    group_member_id INTEGER,
    amount_needed REAL,
    social_purpose TEXT,
    repayment_date TEXT,  
    sync_flag INTEGER DEFAULT 0,       
    FOREIGN KEY (meeting_id) REFERENCES meeting(id) ON DELETE CASCADE,
    FOREIGN KEY (cycle_id) REFERENCES cyclemeeting(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES group_form (id) ON DELETE CASCADE,
    FOREIGN KEY (group_member_id) REFERENCES group_members(id) ON DELETE CASCADE
  )
''');

    await db.execute('''
  CREATE TABLE cycle_start_meeting (
    id INTEGER PRIMARY KEY AUTOINCREMENT ,
    date TEXT,
    time TEXT,
    location TEXT,
    facilitator TEXT,
    meeting_purpose TEXT,
    latitude REAL,
    longitude REAL,
    address TEXT,
    objectives TEXT,
    attendance_data TEXT,
    representative_data TEXT,
    proposals TEXT,
    end_time TEXT,
    assigned_funds TEXT,
    social_fund_bag TEXT,
    social_fund_contributions TEXT,
    share_purchases TEXT,
    sync_flag INTEGER DEFAULT 0
  )
''');

    await db.execute('''
  CREATE TABLE payment_info (
    id INTEGER PRIMARY KEY AUTOINCREMENT ,
    group_id INTEGER,
    cycle_id INTEGER,
    meeting_id INTEGER,
    member_id INTEGER,
    payment_amount REAL,
    payment_date TEXT,
    sync_flag INTEGER DEFAULT 0,
    FOREIGN KEY (group_id) REFERENCES group_form(id) ON DELETE CASCADE,
    FOREIGN KEY (cycle_id) REFERENCES cyclemeeting(id) ON DELETE CASCADE,
    FOREIGN KEY (meeting_id) REFERENCES meeting(id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES group_members(id) ON DELETE CASCADE
  )
''');

    await db.execute('''
  CREATE TABLE fines (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    memberId INTEGER,
    amount INTEGER,
    reason TEXT,
    groupId INTEGER,
    cycleId INTEGER,
    meetingId INTEGER, 
    savingsAccountId INTEGER,
    sync_flag INTEGER DEFAULT 0,
    FOREIGN KEY (savingsAccountId) REFERENCES savings_account(id) ON DELETE CASCADE,
    FOREIGN KEY (memberId) REFERENCES group_members(id) ON DELETE CASCADE,
    FOREIGN KEY (groupId) REFERENCES group_form(id) ON DELETE CASCADE,
    FOREIGN KEY (cycleId) REFERENCES cyclemeeting(id) ON DELETE CASCADE,
    FOREIGN KEY (meetingId) REFERENCES meeting(id) ON DELETE CASCADE
  )
''');

    await db.execute('''
  CREATE TABLE group_cycle_status (
    id INTEGER PRIMARY KEY AUTOINCREMENT ,
    group_id INTEGER,
    cycleId INTEGER,
    sync_flag INTEGER DEFAULT 0,
    is_cycle_started BOOLEAN DEFAULT FALSE, 
    FOREIGN KEY (group_id) REFERENCES group_profile (id),
    FOREIGN KEY (cycleId) REFERENCES cyclemeeting(id) ON DELETE CASCADE
  )
''');

    await db.execute('''
CREATE TABLE loan_disbursement (
  id INTEGER PRIMARY KEY AUTOINCREMENT ,
  member_id INTEGER,
  groupId INTEGER,
  cycleId INTEGER,
  loan_id INTEGER,
  disbursement_amount REAL,
  disbursement_date DATE,
  sync_flag INTEGER DEFAULT 0,
  FOREIGN KEY (groupId) REFERENCES group_form(id) ON DELETE CASCADE,
  FOREIGN KEY (cycleId) REFERENCES cyclemeeting(id) ON DELETE CASCADE,
  FOREIGN KEY (member_id) REFERENCES group_members(id) ON DELETE CASCADE,
  FOREIGN KEY (loan_id) REFERENCES loans(id) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE loan_payments (
  id INTEGER PRIMARY KEY AUTOINCREMENT ,
  member_id INTEGER,
  groupId INTEGER,
  loan_id INTEGER,
  payment_amount REAL,
  payment_date TEXT,
  sync_flag INTEGER DEFAULT 0,
  FOREIGN KEY (groupId) REFERENCES group_form(id) ON DELETE CASCADE,
  FOREIGN KEY (member_id) REFERENCES group_members(id) ON DELETE CASCADE,
  FOREIGN KEY (loan_id) REFERENCES loans(id) ON DELETE CASCADE
)
''');

    await db.execute('''
  CREATE TABLE share_out (
    id INTEGER PRIMARY KEY AUTOINCREMENT ,
    group_id INTEGER,
    cycleId INTEGER, 
    user_id INTEGER,
    share_value REAL, 
    sync_flag INTEGER DEFAULT 0,
    FOREIGN KEY (cycleId) REFERENCES cyclemeeting(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES group_profile(id) ON DELETE CASCADE  
  )
''');

    await db.execute(''' 
CREATE TABLE loans (
  id INTEGER PRIMARY KEY AUTOINCREMENT ,
  member_id INTEGER,
  loan_applicant TEXT,
  groupId INTEGER,
  loan_purpose TEXT,
  loan_amount REAL,
  interest_rate REAL,
  start_date TEXT,
  end_date TEXT,
  status TEXT,
  sync_flag INTEGER DEFAULT 0,
  FOREIGN KEY (groupId) REFERENCES group_form(id) ON DELETE CASCADE,
  FOREIGN KEY (member_id) REFERENCES group_members(id) ON DELETE CASCADE
)
''');

    await db.execute('''
  CREATE TABLE reversed_transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT ,
    group_id INTEGER,
    savings_account_id INTEGER,
    logged_in_user_id INTEGER,
    reversed_amount REAL,
    date TEXT,
    purpose TEXT,
    reversed_data TEXT,
    sync_flag INTEGER DEFAULT 0,
    FOREIGN KEY (savings_account_id) REFERENCES savings_account(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES group_form(id)ON DELETE CASCADE,
    FOREIGN KEY (logged_in_user_id) REFERENCES users(id) ON DELETE CASCADE
  )
''');

// Insert default positions
    // await db.rawInsert('INSERT INTO positions (name) VALUES (?)', ['Chairman']);
    // await db
    //     .rawInsert('INSERT INTO positions (name) VALUES (?)', ['Secretary']);

    // await db.rawInsert(
    //     'INSERT INTO positions (name) VALUES (?)', ['Money counter 1']);
    // await db.rawInsert(
    //     'INSERT INTO positions (name) VALUES (?)', ['Money counter 2']);
  }

  // Return user details for which synced is 0
  Future<List<Map<String, dynamic>>> getUnsyncedUser() async {
    final Database db = await database;
    final List<Map<String, dynamic>> unsyncedUsers =
        await db.query('users', where: 'sync_flag = 1', columns: [
      'unique_code',
      'fname',
      'lname',
      'email',
      'phone',
      'sex',
      'country',
      'date_of_birth',
      'district',
      'subCounty',
      'village',
      'number_of_dependents',
      'family_information',
      'next_of_kin_name',
      'next_of_kin_has_phone_number',
      'next_of_kin_phone_number',
      'pwd_type',
      'sync_flag'
    ]);

    for (final user in unsyncedUsers) {
      print(user);
    }

    return unsyncedUsers;
  }

  // Function to get member names and positions for a given group profile ID
  Future<List<Map<String, dynamic>>> getMembersWithPositions(
      int groupProfileId) async {
    final Database db = await database;

    // SQL query to retrieve member names and positions
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT u.fname, u.lname, ap.position_name
      FROM users u
      INNER JOIN group_members gm ON u.id = gm.user_id
      INNER JOIN assigned_positions ap ON gm.id = ap.member_id
      WHERE gm.group_id = ?
    ''', [groupProfileId]);

    return result;
  }

  Future<List<Map<String, dynamic>>> getGroupMembersAndPositions(
      int groupId) async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT u.fname, u.lname, ap.position_name
      FROM users u
      INNER JOIN group_members gm ON u.id = gm.user_id
      LEFT JOIN assigned_positions ap ON gm.id = ap.member_id AND gm.group_id = ap.group_id
      WHERE gm.group_id = ?
    ''', [groupId]);
  }

  // Future<List<Map<String, dynamic>>> getGroupMembersAndPositions(
  //     int groupId) async {
  //   final Database db = await database;
  //   String sql = '''
  //   SELECT u.fname || ' ' || u.lname AS user_name, ap.position_name AS position_name
  //   FROM group_members gm
  //   JOIN users u ON gm.user_id = u.id
  //   JOIN assigned_positions ap ON gm.id = ap.member_id
  //   WHERE gm.group_id = ?
  // ''';

  //   List<Map<String, dynamic>> userNamesAndPositions =
  //       await db.rawQuery(sql, [groupId]);

  //   return userNamesAndPositions;
  // }

  Future<List<int>> getGroupFormIds(List<int> groupIds) async {
    final Database db = await database;
    try {
      String placeholders = groupIds.map((_) => '?').join(', ');
      List<Map<String, dynamic>> groupFormIds = await db.rawQuery('''
      SELECT id
      FROM group_form
      WHERE group_id IN ($placeholders)
    ''', groupIds);

      List<int> formIds =
          groupFormIds.map<int>((groupForm) => groupForm['id'] as int).toList();
      return formIds;
    } catch (e) {
      print('Error retrieving group form IDs: $e');
      return [];
    }
  }

  // Function to retrieve all data from the 'group_form' table
  Future<List<Map<String, dynamic>>> getAllGroupFormData() async {
    final db = await database;
    return await db.query('group_form');
  }

// Function to get unsynced user records
  // Future<List<Map<String, dynamic>>> getUnsyncedUsers() async {
  //   final Database db = await database;

  //   // Check if the 'synced' column exists in the 'users' table
  //   final List<Map<String, dynamic>> tableInfo =
  //       await db.rawQuery("PRAGMA table_info(users)");

  //   bool syncedColumnExists = false;
  //   for (final columnInfo in tableInfo) {
  //     final columnName = columnInfo['name'];
  //     if (columnName == 'synced') {
  //       syncedColumnExists = true;
  //       break;
  //     }
  //   }

  //   if (!syncedColumnExists) {
  //     // Handle the case where the 'synced' column doesn't exist
  //     return [];
  //   }

  //   // If the 'synced' column exists, proceed with the query
  //   final List<Map<String, dynamic>> users =
  //       await db.query('users', where: 'synced = 0');
  //   return users;
  // }

  Future<int?> getUserIdFromUniqueCode(String uniqueCode) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['id'],
      where: 'unique_code = ?',
      whereArgs: [uniqueCode],
    );
    if (result.isNotEmpty) {
      return result.first['id'] as int?;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> GroupFormData() async {
    final Database db = await database;
    return await db.query('group_form');
  }

  Future<List<Map<String, dynamic>>> getUnsyncedUsers() async {
    final Database db = await database;
    final List<Map<String, dynamic>> users =
        await db.query('users', where: 'sync_flag = 0');
    return users;
  }

  Future<void> updateSyncedStatus(int userId) async {
    final Database db = await database;
    await db.update('users', {'sync_flag': 1},
        where: 'id = ?', whereArgs: [userId]);
  }

// Clear savings account
  Future<int> deleteSavingsAccountsByGroupId(int groupId) async {
    final db = await database;
    return await db.delete(
      'savings_account',
      where: 'group_id = ?',
      whereArgs: [groupId],
    );
  }

// Shareout
  Future<int?> getUserIdFromGroupMember(Database db, int groupMemberId) async {
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT user_id FROM group_members WHERE id = ?',
      [groupMemberId],
    );

    if (result.isNotEmpty) {
      return result.first['user_id'] as int;
    } else {
      return null; // Group member ID not found or no associated user ID.
    }
  }

  Future<int> insertShareOut(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('share_out', data);
  }

  // Loan Payments
  Future<double> getTotalPaymentsForLoan(
      int groupId, int memberId, int loanId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
    SELECT IFNULL(SUM(payment_amount), 0) as total_paid
    FROM loan_payments
    WHERE groupId = ? AND member_id = ? AND loan_id = ?
  ''', [groupId, memberId, loanId]);

    if (result.isNotEmpty) {
      final totalPaid = double.tryParse(result.first['total_paid'].toString());
      if (totalPaid != null) {
        return totalPaid;
      }
    }
    return 0.0; // Return 0.0 if no payments found for the loan or if conversion fails
  }

  // Interest
  Future<double> getTotalLoanDisbursement(int groupId, int cycleId) async {
    final Database db = await database;

    const query = '''
      SELECT SUM(disbursement_amount) AS totalDisbursement
      FROM loan_disbursement
      WHERE groupId = ? AND cycleId = ? 
      AND loan_id IN (SELECT id FROM loans WHERE status = 'Cleared')
    ''';

    final result = await db.rawQuery(query, [groupId, cycleId]);

    if (result.isNotEmpty && result[0]['totalDisbursement'] != null) {
      final totalDisbursement = result[0]['totalDisbursement'] as double;
      print('Loan disbursement: $totalDisbursement');
      return totalDisbursement;
    } else {
      // No cleared loan disbursements found, return 0 or another appropriate default value.
      return 0.0;
    }
  }

  Future<void> printPositions() async {
    final Database db = await database;
    final List<Map<String, dynamic>> positions = await db.query('positions');

    if (positions.isNotEmpty) {
      print('Positions:');
      positions.forEach((position) {
        final int id = position['id'];
        final String name = position['name'];
        print('ID: $id, Name: $name');
      });
    } else {
      print('No positions found.');
    }
  }

  // Future<List<Map<String, dynamic>>> getGroupIdsAndPositionsForUser(
  //     int userId) async {
  //   final db = await database;
  //   final result = await db.rawQuery(
  //     '''
  //   SELECT g.id AS group_id, p.name AS position_name
  //   FROM group_members gm
  //   JOIN assigned_positions ap ON gm.id = ap.member_id
  //   JOIN positions p ON ap.position_id = p.id
  //   WHERE gm.user_id = ?
  //   ''',
  //     [userId],
  //   );
  //   return result
  //       .map((row) => {
  //             'group_id': row['group_id'],
  //             'position_name': row['position_name']
  //           })
  //       .toList();
  // }

  Future<List<Map<String, dynamic>>> getGroupIdsAndPositionsForUser(
      int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
    SELECT gm.id AS group_id, p.name AS position_name
    FROM group_members gm
    JOIN assigned_positions ap ON gm.id = ap.member_id
    JOIN positions p ON ap.position_id = p.id
    WHERE gm.user_id = ?
    ''',
      [userId],
    );
    return result
        .map((row) => {
              'group_id': row['group_id'],
              'position_name': row['position_name']
            })
        .toList();
  }

  // Future<List<Object?>> getGroupIdsForUser(int userId) async {
  //   final db = await database;
  //   final result = await db.query(
  //     'group_members',
  //     where: 'user_id = ?',
  //     whereArgs: [userId],
  //   );
  //   return result.map((row) => row['group_id']).toList();
  // }

  // Active Loans for shareout
  Future<double> getSumOfActiveLoans(int groupId) async {
    final Database db = await database;

    const query = '''
      SELECT SUM(loan_amount) AS totalLoanAmount
      FROM loans
      WHERE groupId = ? AND status = 'Active'
    ''';

    final result = await db.rawQuery(query, [groupId]);

    if (result.isNotEmpty && result[0]['totalLoanAmount'] != null) {
      final totalLoanAmount = result[0]['totalLoanAmount'] as double;
      return totalLoanAmount;
    } else {
      // No active loans found, return 0 or another appropriate default value.
      return 0.0;
    }
  }

  // Get shares
  Future<String?> cycleMemberSharePurchases(
      int cycleMeetingId, int groupId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'cyclemeeting',
      columns: ['sharePurchases'],
      where: 'id = ? AND group_id = ?',
      whereArgs: [cycleMeetingId, groupId],
    );

    if (results.isNotEmpty) {
      return results.first['sharePurchases'];
    } else {
      return null;
    }
  }

  Future<double> getTotalFinesAmount(int groupId, int cycleId) async {
    final Database db = await database;

    // Define the SQL query to calculate the sum of fines for the specified group and cycle ID
    const query = '''
    SELECT SUM(amount) AS totalAmount
    FROM fines
    WHERE groupId = ? AND cycleId = ?
  ''';

    // Execute the query with the provided groupId and cycleId
    final result = await db.rawQuery(query, [groupId, cycleId]);

    // Extract the total amount from the result
    double? totalAmount;

    try {
      totalAmount = double.tryParse(result[0]['totalAmount'].toString());
      print('Fines totalAmount: $totalAmount');
    } catch (e) {
      // Handle the error.
      print('Error getting total fines amount: $e');
    }

    // Check if the total amount is null. If it is, return 0.0.
    if (totalAmount == null) {
      return 0.0;
    }

    // Return the total amount.
    return totalAmount;
  }

  Future<String?> memberSharePurchases(int cycleId, int groupId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'memberShares',
      columns: ['sharePurchases'],
      where: 'cycle_id = ? AND group_id = ?',
      whereArgs: [cycleId, groupId],
    );

    if (results.isNotEmpty) {
      return results.first['sharePurchases'];
    } else {
      return null;
    }
  }

  // Shares
  Future<void> insertMemberShare(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('memberShares', data);
  }

  // Function to fetch data from the "memberShares" table
  Future<List<Map<String, dynamic>>?> getMemberShares(
      int groupId, int cycleId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'memberShares',
      where: 'group_id = ? AND cycle_id = ?',
      whereArgs: [groupId, cycleId],
    );
    print('New results = $results');
    return results;
  }

  // Future<List<Map<String, dynamic>>> getMemberShares(
  //     int groupId, int cycleId) async {
  //   final db = await database;
  //   final results = await db.query('memberShares',
  //       where: 'group_id = ? AND cycle_id = ?', whereArgs: [groupId, cycleId]);
  //   final newresults =
  //       results.map((result) => Map<String, dynamic>.from(result)).toList();
  //   print('New results = $newresults');
  //   return newresults;
  // }

  // Cycle status

  Future<void> updateGroupCycleStatus(
      int groupId, int cycleId, bool isCycleStarted) async {
    final Database db = await instance.database;

    // Get the current status before updating
    final List<Map<String, dynamic>> currentStatus = await db.query(
      'group_cycle_status',
      columns: ['is_cycle_started'],
      where: 'group_id = ? AND cycleId = ?',
      whereArgs: [groupId, cycleId],
    );

    if (currentStatus.isNotEmpty) {
      final int currentStatusValue = currentStatus[0]['is_cycle_started'];
      print('Current status for group $groupId: $currentStatusValue');
    }

    // Update the status
    await db.update(
      'group_cycle_status',
      {'is_cycle_started': isCycleStarted ? 1 : 0}, // 1 for true, 0 for false
      where: 'group_id = ?',
      whereArgs: [groupId],
    );

    print('Updated status for group $groupId to: ${isCycleStarted ? 1 : 0}');
  }

  Future<void> deleteGroupData(int groupId) async {
    Database db = await instance.database;
    await db.execute(
      'DELETE FROM group_cycle_status WHERE group_id = ?',
      [groupId],
    );
  }

  Future<void> insertCycleStatus(
      int groupId, int cycleId, bool isCycleStarted) async {
    Database db = await instance.database;
    db.insert('group_cycle_status', {
      'group_id': groupId,
      'cycleId': cycleId,
      'is_cycle_started': isCycleStarted ? 1 : 0,
    });
  }

  Future<bool> getGroupCycleStatus(int groupId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      'group_cycle_status',
      where: 'group_id = ?',
      whereArgs: [groupId],
      columns: ['is_cycle_started'],
    );
    return result.isNotEmpty ? result[0]['is_cycle_started'] == 1 : false;
  }

  Future<int> groupProfileId(int groupFormId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT group_profile_id FROM group_form WHERE id = ?',
      [groupFormId],
    );

    if (result.isNotEmpty) {
      return result[0]['group_profile_id'];
    } else {
      // Handle the case when the group_form_id is not found.
      return -1; // You can return an appropriate value or throw an exception.
    }
  }

  Future<Map<String, dynamic>> areFundsPresent(int groupProfileId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT socialFund, loanFund FROM group_profile WHERE id = ?',
      [groupProfileId],
    );

    if (result.isNotEmpty) {
      int removeCommasAndConvertToInt(String text) {
        final withoutCommas = text.replaceAll(',', '');
        return int.parse(withoutCommas);
      }

      final String? socialFund = result[0]['socialFund'];
      final String? loanFund = result[0]['loanFund'];

      int socialFundAmount = removeCommasAndConvertToInt(socialFund!);
      int loanFundAmount = removeCommasAndConvertToInt(loanFund!);

      // Check if either socialFund or loanFund is not null or empty.
      if (socialFundAmount > 0 || loanFundAmount > 0) {
        print("'socialFund': $socialFund, 'loanFund': $loanFund");
        return {'socialFund': socialFund, 'loanFund': loanFund};
      } else {
        return {'socialFund': null, 'loanFund': null};
      }
    } else {
      // Handle the case when the groupProfileId is not found.
      return {'socialFund': null, 'loanFund': null};
    }
  }

  Future<int> insertFundsIntoCycleMeeting(
    int groupId,
    int totalLoanFund,
    int totalSocialFund,
  ) async {
    final Map<String, dynamic> data = {
      'group_id': groupId,
      'totalLoanFund': totalLoanFund,
      'totalSocialFund': totalSocialFund,
    };
    final Database db = await database;

    final int id = await db.insert('cyclemeeting', data);

    return id;
  }

  // Payment Info
  // Loan Payments
  Future<void> savePaymentInfo(PaymentInfo paymentInfo) async {
    final Database db = await database;
    await db.insert(
      'loan_payments',
      <String, dynamic>{
        'groupId': paymentInfo.groupId,
        'loan_id': paymentInfo.loanId,
        'member_id': paymentInfo.memberID,
        'payment_amount': paymentInfo.amount,
        'payment_date': paymentInfo.paymentDate.toIso8601String(),
      },
    );
  }

  // Fetch active loans
  Future<double> getTotalActiveLoanAmountForGroup(int groupId) async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT SUM(loan_amount) AS total_loan_amount
    FROM loans
    WHERE groupId = ? AND status = "Active"
  ''', [groupId]);

    if (result.isNotEmpty) {
      final totalLoanAmount =
          (result.first['total_loan_amount'] as double?) ?? 0.0;
      return totalLoanAmount;
    } else {
      return 0.0; // Return 0 if no active loans are found for the group
    }
  }

  // Get Interest
  Future<double?> getInterestRate(int groupFormId) async {
    final db = await database;

    // First, retrieve the constitution_id using the group_form_id
    final result = await db.query(
      'group_form',
      columns: ['constitution_id'],
      where: 'id = ?',
      whereArgs: [groupFormId],
    );

    if (result.isNotEmpty) {
      final constitutionId = result.first['constitution_id'] as int;

      // Next, use the constitution_id to access the constitution_table
      final constitutionResult = await db.query(
        'constitution_table',
        columns: ['interestRate'],
        where: 'id = ?',
        whereArgs: [constitutionId],
        limit: 1,
      );

      if (constitutionResult.isNotEmpty) {
        return constitutionResult.first['interestRate'] as double?;
      }
    }

    return null;
  }

  // Get payment details
  Future<List<Map<String, dynamic>>> getAllPaymentForGroup(int groupId) async {
    final db = await database;

    // Get all the loans for the given groupId.
    final payments = await db
        .query('loan_payments', where: 'groupId = ?', whereArgs: [groupId]);

    // Return the list of loans.
    return payments;
  }

  // Get loan details
  Future<List<Map<String, dynamic>>> getAllLoansForGroup(int groupId) async {
    final db = await database;

    // Get all the loans for the given groupId.
    final loans =
        await db.query('loans', where: 'groupId = ?', whereArgs: [groupId]);

    // Return the list of loans.
    return loans;
  }

  // Check loans
  Future<bool> doesMemberHaveActiveLoan(int groupId, int memberId) async {
    final db = await database;

    // Get the loan for the given groupId and memberId.
    final loan = await db.query('loans',
        where: 'groupId = ? AND member_id = ?', whereArgs: [groupId, memberId]);

    // If there is no loan for the given groupId and memberId, return false.
    if (loan.isEmpty) {
      return false;
    }

    // Get the loan status.
    final loanStatus = loan[0]['status'];

    // If the loan status is Active, return true, otherwise return false.
    return loanStatus == 'Active';
  }

  Future<List<int>> getGroupsForUser(int userId) async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> groups = await db.rawQuery('''
      SELECT DISTINCT group_members.group_id
      FROM assigned_positions
      JOIN group_members ON assigned_positions.member_id = group_members.id
      WHERE group_members.user_id = ? AND 
        (assigned_positions.position_name = 'Chairman' OR assigned_positions.position_name = 'Secretary')
    ''', [userId]);

      List<int> groupIds =
          groups.map<int>((group) => group['group_id'] as int).toList();
      return groupIds;
    } catch (e) {
      print('Error retrieving groups for user: $e');
      return [];
    }
  }

  // Future<bool> doesMemberHaveActiveLoan(int memberId, int groupId) async {
  //   final db = await database;
  //   final result = await db.rawQuery('''
  //   SELECT COUNT(*) FROM loans
  //   WHERE member_id = ? AND groupId = ? AND status = 'Active'
  // ''', [memberId, groupId]);

  //   if (result.isNotEmpty) {
  //     final count = Sqflite.firstIntValue(result);
  //     return count! > 0; // Return true if there are active loans.
  //   } else {
  //     return false;
  //   }
  // }
  Future<Map<String, dynamic>> getMemberName(int groupMemberId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> memberData = await db.rawQuery('''
      SELECT users.fname, users.lname
      FROM users
      INNER JOIN group_members ON users.id = group_members.user_id
      WHERE group_members.id = ?
    ''', [groupMemberId]);

    if (memberData.isNotEmpty) {
      return memberData.first;
    }

    return {}; // Return an empty map if no data is found
  }

  // Future<String?> getMemberName(int user) async {
  //   final Database db = await database;
  //   try {
  //     final linkedData = await db.rawQuery('''
  //     SELECT CONCAT(users.fname, ' ', users.lname) AS full_name
  //     FROM group_members
  //     JOIN users ON group_members.user_id = users.id
  //     WHERE group_members.id = ?
  //   ''', [user]);

  //     if (linkedData.isNotEmpty) {
  //       return linkedData.first['full_name'] as String?;
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     print('Error retrieving linked data for user: $e');
  //     return null;
  //   }
  // }

  // Future<String?> getMemberName(int memberId) async {
  //   try {
  //     final db = await instance.database;
  //     final result = await db.rawQuery(
  //         'SELECT u.fname, u.lname FROM users u JOIN group_members gm ON u.id = gm.user_id WHERE gm.id = $memberId');

  //     if (result.isNotEmpty && result.first != null) {
  //       // Check if the first element exists
  //       return '${result.first['fname']} ${result.first['lname']}';
  //     } else {
  //       // Additional check for record existence in group_members table
  //       final memberExists = await db
  //           .rawQuery('SELECT 1 FROM group_members WHERE id = $memberId');
  //       if (memberExists.isNotEmpty) {
  //         // Member ID exists in group_members table but has no corresponding user in users table
  //         return 'No Name Available';
  //       } else {
  //         // Member ID does not exist in group_members table
  //         return 'Member ID Not Found';
  //       }
  //     }
  //   } catch (e) {
  //     print('Error retrieving full name: $e');
  //     return null;
  //   }
  // }

  Future<List<Object?>> getGroupNamesForGroupIds(List<int> groupIds) async {
    final db = await database;
    final groupNames = await db.query(
      'group_profile',
      where: 'id IN ?',
      whereArgs: [groupIds],
    );
    return groupNames.map((row) => row['groupName']).toList();
  }

  // Insert Loans
  Future<int> insertLoan(Map<String, dynamic> loan) async {
    final db = await database;
    return await db.insert('loans', loan);
  }

  Future<Map<String, dynamic>> getGroupMemberFullNames(
      int groupMemberId) async {
    Database db = await DatabaseHelper.instance.database;

    List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT users.fname, users.lname
    FROM group_members
    INNER JOIN users ON group_members.user_id = users.id
    WHERE group_members.id = ?
  ''', [groupMemberId]);

    if (result.isNotEmpty) {
      // Return the first matching group member
      return result.first;
    }

    // Return an empty map if no matching group member is found
    return {};
  }

  Future<List<Position>> loadPositions() async {
    final db = await database;
    final results = await db.query('positions', orderBy: 'name');
    return results.map((row) => Position.fromMap(row)).toList();
  }

  Future<List<GroupMember>> loadGroupMembers(int groupId) async {
    final db = await database;
    final results = await db
        .query('group_members', where: 'group_id = ?', whereArgs: [groupId]);
    List<GroupMember> groupMembers =
        results.map((row) => GroupMember.fromMap(row)).toList();

    // Fetch and update names from the 'users' table
    for (var member in groupMembers) {
      final userResult =
          await db.query('users', where: 'id = ?', whereArgs: [member.userId]);
      if (userResult.isNotEmpty) {
        final user = userResult.first;
        member.name = '${user['fname']} ${user['lname']}';
      }
    }
    return groupMembers;
  }

  Future<void> saveAssignedPositions(
      List<AssignedPosition> assignedPositions) async {
    final db = await database;
    for (AssignedPosition assignedPosition in assignedPositions) {
      await db.insert('assigned_positions', assignedPosition.toMap());
    }
  }

  Future<List<LoanApplication>> getLoanApplicationsForGroupAndCycle(
      int groupId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT loans.*, 
           IFNULL(SUM(loan_payments.payment_amount), 0) as total_paid
    FROM loans
    LEFT JOIN loan_payments ON loans.id = loan_payments.loan_id
    WHERE loans.groupId = ? 
    GROUP BY loans.id
  ''', [groupId]);

    return List.generate(maps.length, (index) {
      return LoanApplication(
        id: maps[index]['id'],
        groupId: maps[index]['groupId'],
        submissionDate: maps[index]['start_date'],
        loanApplicant: maps[index]['loan_applicant'],
        groupMemberId: maps[index]['member_id'],
        amountNeeded: maps[index]['loan_amount'],
        // amountNeeded: maps[index]['loan_amount'] - maps[index]['total_paid'],
        loanPurpose: maps[index]['loan_purpose'],
        repaymentDate: maps[index]['end_date'],
        LoanStatus: maps[index]['status'],
      );
    });
  }

  Future<double> getTotalPaidForLoan(int loanId, int groupId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
    SELECT IFNULL(SUM(payment_amount), 0) as total_paid
    FROM loan_payments
    WHERE loan_id = ? AND groupId = ?
  ''', [loanId, groupId]);

    if (result.isNotEmpty) {
      print('Result $result');
      final totalPaid = double.tryParse(result.first['total_paid'].toString());
      if (totalPaid != null) {
        return totalPaid;
      }
    }
    return 0.0; // Return 0.0 if no payments found for the loan or if conversion fails
  }

  Future<void> updateLoanStatus(
      int groupId, int loanId, int memberId, String status) async {
    final Database db = await database;

    final query = '''
    UPDATE loans
    SET status = ?
    WHERE id = ? AND groupId = ? AND member_id = ?
  ''';

    await db.execute(query, [status, loanId, groupId, memberId]);
  }

  // Future<void> updateLoanStatus(
  //     int groupId, int loanId, String newStatus) async {
  //   final db = await database;
  //   await db.update(
  //     'loans',
  //     {'status': newStatus},
  //     where: 'id = ? AND groupId = ?',
  //     whereArgs: [loanId, groupId],
  //   );
  // }

  // Function to check if there are any loan details present
  Future<bool> hasLoanDetails(int groupId) async {
    final Database db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'loans',
      where: 'groupId = ?',
      whereArgs: [groupId],
    );

    return result.isNotEmpty;
  }

  // Method to get recent social activity data for a specific group, meeting, and cycle
  Future<List<Map<String, dynamic>>> getRecentSocialActivity(
      int groupId, int cycleId, int meetingId) async {
    try {
      final Database db = await instance.database;
      final List<Map<String, dynamic>> result = await db.query(
        'social_fund_applications',
        where: 'group_id = ? AND meeting_id = ? AND cycle_id = ?',
        whereArgs: [groupId, meetingId, cycleId],
        orderBy:
            'submission_date DESC', // Sort by submission_date in descending order
      );
      return result;
    } catch (e) {
      print('Error in getRecentSocialActivity: $e');
      return []; // Return an empty list or handle the error as needed.
    }
  }

  Future<Map<String, dynamic>?> getPaymentInfo(
      int memberId, int groupId) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query('loan_payments',
        columns: ['payment_amount', 'payment_date'],
        where: 'member_id = ? AND groupId = ?',
        whereArgs: [memberId, groupId]);

    if (results.isNotEmpty) {
      return results.first;
    } else {
      return null;
    }
  }

  Future<List<int>> getMemberIds(int groupId) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query('loans',
        columns: ['member_id'], where: 'groupId = ?', whereArgs: [groupId]);

    if (results.isNotEmpty) {
      return results.map((result) => result['member_id'] as int).toList();
    } else {
      return [];
    }
  }

  // Check for loans
  Future<bool> doesMemberHaveLoans(int groupId, int memberId) async {
    final Database db = await database;

    List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT 1
    FROM loans
    WHERE groupId = ? AND member_id = ?
  ''', [groupId, memberId]);

    return result.isNotEmpty;
  }

  // Method to get recent loan activity data for a specific group, meeting, and cycle
  Future<List<Map<String, dynamic>>> getRecentLoanActivity(int groupId) async {
    final Database db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'loans',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'start_date DESC', // Sort by submission_date in descending order
    );
    return result;
  }

  Future<void> updateSharesAndSavingsForMemberInGroup(int groupId, int memberId,
      int updatedShares, double updatedSavings) async {
    // Get the database instance
    final db = await DatabaseHelper.instance.database;

    // Get the current sharePurchases data as a JSON string
    String currentSharePurchasesJson = (await db.query(
      'memberShares',
      columns: ['sharePurchases'],
      where: 'group_id = ?',
      whereArgs: [groupId],
    ))[0]['sharePurchases'] as String;

    // Decode the JSON string into a list of maps
    List<Map<String, dynamic>> currentSharePurchases =
        List<Map<String, dynamic>>.from(jsonDecode(currentSharePurchasesJson));

    // Find and update the shareQuantity for the given memberId
    for (Map<String, dynamic> purchase in currentSharePurchases) {
      if (purchase['memberId'] == memberId) {
        purchase['shareQuantity'] = updatedShares;
        break; // Break out of the loop once the member is found and updated
      }
    }

    // Encode the modified list back to a JSON string
    String updatedSharePurchasesJson = jsonEncode(currentSharePurchases);

    // Update the shares and savings for the given member and group ID
    await db.update(
      'memberShares',
      {
        'sharePurchases': updatedSharePurchasesJson,
      },
      where: 'group_id = ?',
      whereArgs: [groupId],
    );
  }

  Future<List<Map<String, dynamic>>> getLoanApplicationDetails(
      int groupId) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query('loans',
        columns: [
          'start_date',
          'loan_applicant',
          'member_id',
          'loan_amount',
          'loan_purpose',
          'end_date'
        ],
        where: 'groupId = ?',
        whereArgs: [groupId]);

    return results;
  }

  Future<Map<String, dynamic>> deleteLoanEntry(int id) async {
    Database db = await instance.database;

    // Query the data to be deleted before deleting it
    List<Map<String, dynamic>> deletedData =
        await db.query('loans', where: 'id = ?', whereArgs: [id]);

    if (deletedData.isEmpty) {
      // No data found to delete, return an empty map or handle as needed
      return {};
    }

    // Check the status of the loan before proceeding with the reversal
    final String status = deletedData.first['status'];

    if (status != 'Active') {
      // Loan status is not "Active", return null or handle as needed
      return {};
    }

    // Delete the data
    int rowsDeleted =
        await db.delete('loans', where: 'id = ?', whereArgs: [id]);

    if (rowsDeleted > 0) {
      // Data was successfully deleted, and deletedData contains the deleted details
      return deletedData.first;
    } else {
      // Data was not deleted, return an empty map or handle as needed
      return {};
    }
  }

  // Future<Map<String, dynamic>> deleteLoanEntry(int id) async {
  //   Database db = await instance.database;

  //   // Query the data to be deleted before deleting it
  //   List<Map<String, dynamic>> deletedData =
  //       await db.query('loans', where: 'id = ?', whereArgs: [id]);

  //   // Delete the data
  //   int rowsDeleted =
  //       await db.delete('loans', where: 'id = ?', whereArgs: [id]);

  //   if (rowsDeleted > 0 && deletedData.isNotEmpty) {
  //     // Data was successfully deleted, and deletedData contains the deleted details
  //     return deletedData.first;
  //   } else {
  //     // Return an empty map if no data was found to delete
  //     return {};
  //   }
  // }

  // Update Loan
  Future<void> updateLoanEntry(
    int loanId,
    double updatedAmount,
    String updatedLoanPurpose,
    String updatedRepaymentDate,
  ) async {
    final db = await instance.database;
    final updatedLoan = {
      'id': loanId,
      'loan_amount': updatedAmount,
      'loan_purpose': updatedLoanPurpose,
      'end_date': updatedRepaymentDate,
    };

    await db.update(
      'loans',
      updatedLoan,
      where: 'id = ?',
      whereArgs: [loanId],
    );
  }

  // Insert disbursement
  Future<int> insertDisbursement(Map<String, dynamic> disbursement) async {
    final db = await database;
    return await db.insert('loan_disbursement', disbursement);
  }

  // Insert payment
  Future<int> insertPayment(Map<String, dynamic> payment) async {
    final db = await database;
    return await db.insert('loan_payments', payment);
  }

  // Loans

  // Function to retrieve all data by ID
  Future<Map<String, dynamic>?> getUserDataById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    // If no data is found for the provided ID, you can return null or handle it as needed.
    return null;
  }

  Future<Map<int, String>> getPositionsForUserInGroups(int userId) async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> positions = await db.rawQuery('''
      SELECT group_id, position_name
      FROM assigned_positions
      WHERE member_id = ?
    ''', [userId]);

      Map<int, String> userPositions = {};
      for (var position in positions) {
        final int groupId = position['group_id'] as int;
        final String positionName = position['position_name'] as String;
        userPositions[groupId] = positionName;
      }

      return userPositions;
    } catch (e) {
      print('Error retrieving positions for user in groups: $e');
      return {};
    }
  }

  // Future<List<int>> getGroupsUser(int userId) async {
  //   final Database db = await database;
  //   final results = await db.rawQuery('''
  //   SELECT DISTINCT assigned_positions.group_id
  //   FROM assigned_positions
  //   JOIN group_members ON assigned_positions.member_id = group_members.id
  //   WHERE group_members.user_id = ? AND assigned_positions.position_name IN (?, ?)
  // ''', [userId, 'Secretary', 'Chairman']);
  //   return results.map((row) => row['group_id'] as int).toList();
  // }

  Future<List<Map<String, dynamic>>> getGroupsUser(int userId) async {
    final Database db = await database;
    final results = await db.rawQuery('''
    SELECT group_members.group_id, assigned_positions.position_name
    FROM group_members
    JOIN assigned_positions ON group_members.id = assigned_positions.member_id
    WHERE group_members.user_id = ?
  ''', [userId]);
    return results.map((row) => row).toList();
  }

  // Future<List<int>> getGroupsUser(int userId) async {
  //   final Database db = await database;
  //   final results = await db.rawQuery('''
  //   SELECT DISTINCT group_id
  //   FROM group_members
  //   WHERE user_id = ?
  // ''', [userId]);
  //   return results.map((row) => row['group_id'] as int).toList();
  // }

  // Future<List<int>> getGroupsUser(int userId) async {
  //   final Database db = await database;
  //   final results = await db.rawQuery('''
  //   SELECT DISTINCT group_id
  //   FROM assigned_positions
  //   JOIN group_members ON assigned_positions.member_id = group_members.id
  //   WHERE group_members.user_id = ? AND assigned_positions.position_name IN (?, ?)
  // ''', [userId, 'secretary', 'chairman']);
  //   return results.map((row) => row['group_id'] as int).toList();
  // }

  // Future<List<int>> getGroupsUser(int userId) async {
  //   final Database db = await database;
  //   try {
  //     List<Map<String, dynamic>> groups = await db.rawQuery('''
  //     SELECT DISTINCT group_id
  //     FROM assigned_positions
  //     WHERE member_id IN (
  //       SELECT id FROM group_members WHERE user_id = ?
  //     ) AND (position_name = 'Chairman' OR position_name = 'Secretary')
  //   ''', [userId]);

  //     List<int> groupIds =
  //         groups.map<int>((group) => group['group_id'] as int).toList();
  //     return groupIds;
  //   } catch (e) {
  //     print('Error retrieving groups for user: $e');
  //     return [];
  //   }
  // }

  // Future<List<int>> getGroupsUser(int userId) async {
  //   final Database db = await database;
  //   try {
  //     List<Map<String, dynamic>> groups = await db.rawQuery('''
  //     SELECT DISTINCT group_id
  //     FROM assigned_positions
  //     WHERE member_id = ? AND
  //       (position_name = 'Chairman' OR position_name = 'Secretary')
  //   ''', [userId]);

  //     List<int> groupIds =
  //         groups.map<int>((group) => group['group_id'] as int).toList();
  //     return groupIds;
  //   } catch (e) {
  //     print('Error retrieving groups for user: $e');
  //     return [];
  //   }
  // }

  // User Details
  Future<Map<String, dynamic>?> getUserDetails(int userId) async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return result[0];
    } else {
      return null;
    }
  }

  // Social
  Future<int> insertSocial(int meetingId, String sharePurchasesJson) async {
    final db = await database;
    return await db.insert('social', {
      'meetingId': meetingId,
      'socialFund': sharePurchasesJson,
    });
  }

  // Savings
  Future<int> insertSavingsAccount(Map<String, dynamic> savingsData) async {
    final db = await database;
    int result = await db.insert('savings_account', savingsData);
    return result;
  }

  // Reversed_transactions
  Future<int> inserReversedTransactions(
      Map<String, dynamic> reversedData) async {
    final db = await database;
    int result = await db.insert('reversed_transactions', reversedData);
    return result;
  }

  Future<double> getTotalGroupSavings(int groupId) async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT SUM(amount) AS total_savings
    FROM savings_account
    WHERE group_id = $groupId
  ''');
    return (result.isNotEmpty) ? result.first['total_savings'] as double : 0.0;
  }

  // Registration fees
  Future<double?> getRegistrationFee(int constitutionId) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'constitution_table',
      where: 'id = ?',
      whereArgs: [constitutionId],
      columns: ['registrationFee'],
    );

    if (results.isNotEmpty) {
      return double.tryParse(results[0]['registrationFee'] ?? '0.0');
    } else {
      return null;
    }
  }

  Future<List<int>> getUserIdsForGroupProfile(int groupProfileId) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'group_members',
      where: 'group_id = ?',
      whereArgs: [groupProfileId],
      columns: ['user_id'],
    );

    List<int> userIDs =
        results.map((result) => result['user_id'] as int).toList();
    return userIDs;
  }

  Future<int> insertGroupFee(Map<String, dynamic> groupFee) async {
    final db = await database;
    return await db.insert('group_fees', groupFee);
  }

  Future<double> getTotalRegistrationFeesForGroup(int groupId) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'group_fees',
      where: 'group_id = ?',
      whereArgs: [groupId],
      columns: ['registration_fee'],
    );

    double totalFees = 0.0;

    for (var result in results) {
      totalFees += result['registration_fee'] ?? 0.0;
    }

    return totalFees;
  }

  Future<int?> getGroupUserId(int groupId, int loggedInUserId) async {
    final db = await database;

    List<Map<String, dynamic>> result = await db.query(
      'group_form',
      columns: ['group_member_id'],
      where: 'group_id = ? AND logged_in_user_id = ?',
      whereArgs: [groupId, loggedInUserId],
    );

    if (result.isNotEmpty) {
      return result[0]['group_member_id'] as int;
    } else {
      return null; // Return null if no matching record is found
    }
  }

// Cycles
  Future<List<Map<String, dynamic>>> getCycleScheduleInfo(int groupId) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> results = await db.query(
        'cycle_schedules',
        where: 'group_id = ?',
        whereArgs: [groupId],
      );

      return results;
    } catch (e) {
      print('Error retrieving cycle schedule data: $e');
      return [];
    }
  }

  // Image
  Future<Map<int, int>> getAllMemberIdsAndUserIds() async {
    final db = await database;
    final result = await db.query('group_members');
    final memberIdsAndUserIds = <int, int>{};
    for (final row in result) {
      final memberId = row['id'] as int;
      final userId = row['user_id'] as int;
      memberIdsAndUserIds[memberId] = userId;
    }
    return memberIdsAndUserIds;
  }

  Future<int?> getUserIdForId(int memberId) async {
    final db = await database;
    final result = await db.query(
      'group_members',
      columns: ['user_id'],
      where: 'id = ?',
      whereArgs: [memberId],
    );
    if (result.isNotEmpty) {
      return result.first['user_id'] as int?;
    }
    return null;
  }

  // Future<int?> getUserIdForId(int id) async {
  //   final db = await database;
  //   final maps = await db.query(
  //     'group_members',
  //     columns: ['user_id'],
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );

  //   if (maps.isEmpty) {
  //     return null; // Return null if no matching record is found.
  //   }

  //   return maps[0]['user_id'] as int?;
  // }

  // Fines
  Future<void> insertFine(String memberId, int amount, String reason,
      int groupId, int cycleId, int meetingId, int savingsAccount) async {
    final db = await database;
    await db.insert(
      'fines',
      {
        'memberId': memberId,
        'amount': amount,
        'reason': reason,
        'groupId': groupId,
        'cycleId': cycleId,
        'meetingId': meetingId,
        'savingsAccountId': savingsAccount,
      },
    );
  }

  Future<List<Map<String, dynamic>>?> getFinesByCriteria(
      int groupId, int cycleId, int meetingId) async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT * FROM fines
    WHERE groupId = ? AND cycleId = ? AND meetingId = ?
  ''', [groupId, cycleId, meetingId]);

    return result;
  }

  // Position
  Future<int> getPositionID(int memberId, int groupId) async {
    final db = await database;

    try {
      final List<Map<String, dynamic>> result = await db.query(
        'assigned_positions',
        columns: ['position_id'],
        where: 'member_id = ? AND group_id = ?',
        whereArgs: [memberId, groupId],
      );

      if (result.isNotEmpty) {
        return result[0]['position_id'] as int;
      } else {
        throw Exception('Position not found for the given member and group.');
      }
    } catch (e) {
      throw Exception('Error retrieving position ID: $e');
    }
  }

  Future<Map<String, dynamic>?> getPositionInfoForMember(
      int memberId, int groupId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT assigned_positions.position_id, positions.name AS position_name
    FROM assigned_positions
    INNER JOIN positions ON assigned_positions.position_id = positions.id
    WHERE assigned_positions.member_id = ? AND assigned_positions.group_id = ?
  ''', [memberId, groupId]);

    if (results.isNotEmpty) {
      return results.first; // Return a map with position_id and position_name
    } else {
      return null; // Return null if no matching record is found
    }
  }

  // Future<void> savePaymentInfo(int groupId, int cycleId, int meetingId,
  //     int memberId, double paymentAmount, DateTime paymentDate) async {
  //   final Database db = await this.database;
  //   await db.insert(
  //     'payment_info',
  //     <String, dynamic>{
  //       'group_id': groupId,
  //       'cycle_id': cycleId,
  //       'meeting_id': meetingId,
  //       'member_id': memberId,
  //       'payment_amount': paymentAmount,
  //       'payment_date':
  //           paymentDate.toIso8601String(), // Convert DateTime to a string
  //     },
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  //Return positions
  Future<int?> getGroupIdFromFormId(int formId) async {
    final db = await database;
    final result = await db.query(
      'group_form',
      where: 'id = ?',
      whereArgs: [formId],
      columns: ['group_id'],
    );

    if (result.isNotEmpty) {
      return result.first['group_id'] as int;
    }

    return null; // Return null if no result is found
  }

  Future<List<Map<String, dynamic>>?> getMemberAndPositionNames(
      int groupId) async {
    final db = await database;
    final results = await db.rawQuery('''
    SELECT gm.id as member_id, gm.user_id, p.id as position_id, p.name as position_name, u.fname, u.lname
    FROM assigned_positions ap
    INNER JOIN group_members gm ON ap.member_id = gm.id
    INNER JOIN positions p ON ap.position_id = p.id
    INNER JOIN users u ON gm.user_id = u.id
    WHERE ap.group_id = ?
  ''', [groupId]);

    return results;
  }

  // CycleData
  Future<int> insertActiveCycleMeeting(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('ActiveCycleMeeting', data);
  }

  Future<int?> getCycleIdForGroup(int groupId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'ActiveCycleMeeting',
      columns: ['cycleMeetingID'],
      where: 'group_id = ?',
      whereArgs: [groupId],
    );

    if (result.isNotEmpty) {
      return result[0]['cycleMeetingID'] as int?;
    } else {
      return null; // Return null if no cycleMeetingID is found for the provided group_id
    }
  }

  // Function to get active cycle meeting ID
  Future<int?> getActiveCycleMeetingID() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('ActiveCycleMeeting');
    if (result.isNotEmpty) {
      print('Cycle');
      print(result.first['cycleMeetingID']);
      return result.first['cycleMeetingID'];
    }
    return null;
  }

  // Update normal meetings
  Future<int> updateMeeting(
      int id, Map<String, dynamic> updatedMeetingData) async {
    final db = await database;

    try {
      int rowsUpdated = await db.update(
        'meeting',
        updatedMeetingData,
        where: 'id = ?',
        whereArgs: [id],
      );

      return rowsUpdated;
    } catch (e) {
      print('Error updating meeting: $e');
      return 0; // Return 0 to indicate an error occurred.
    }
  }

  Future<List<Map<String, dynamic>>> getGroupMembersForGroup(
      int groupId) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT gm.id, u.fname, u.lname
      FROM group_members gm
      INNER JOIN users u ON gm.user_id = u.id
      WHERE gm.group_id = ?
    ''', [groupId]);

    return results;
  }

  Future<void> reassignPosition(
      int groupId, int positionId, int newMemberId) async {
    final db = await database;

    // Update the assigned_positions table with the new member_id
    await db.rawUpdate('''
    UPDATE assigned_positions
    SET member_id = ?
    WHERE group_id = ? AND position_id = ?
  ''', [newMemberId, groupId, positionId]);
  }

  // Share Purchase Fund
  Future<Map<String, dynamic>> getSharePurchase(int groupId) async {
    print('Invoked');
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT constitution_table.maxSharesPerMember AS maxSharesPerMember, constitution_table.minSharesRequired AS minSharesRequired
    FROM group_form
    INNER JOIN constitution_table ON group_form.constitution_id = constitution_table.id
    WHERE group_form.id = ?
  ''', [groupId]);

    if (results.isEmpty) {
      return Future.value({}); // Return a Future with a value of null
    } else {
      return Future.value(results.first); // Return a Future with the result
    }
  }

  // Obatianing specific user shares
  Future<num> getTotalShareQuantityForMemberInCycle(
      int cycleId, String memberId) async {
    try {
      final Database db = await instance.database;

      // Query the 'meeting' table to get the sharePurchases JSON data for the specified cycleId and memberId.
      final List<Map<String, dynamic>> meetingDataList = await db.query(
        'memberShares',
        columns: ['sharePurchases'],
        where: 'cycle_id = ?',
        whereArgs: [cycleId],
      );

      num totalShareQuantity = 0;
      print('Meetint DataList: $meetingDataList');
      print('Cycle Id: $cycleId');

      // Iterate through the meeting data and calculate the total shareQuantity for the specified memberId.
      for (final meetingData in meetingDataList) {
        final sharePurchasesJson = json.decode(meetingData['sharePurchases']);
        if (sharePurchasesJson is List) {
          for (final sharePurchase in sharePurchasesJson) {
            final memberIdInt = int.parse(memberId);
            print('Member Id in db: $memberId');
            if (sharePurchase['memberId'] == memberIdInt) {
              totalShareQuantity += sharePurchase['shareQuantity'];
              print('Total Shares Value: $totalShareQuantity');
            }
          }
        } else {
          print('Not list');
        }
      }
      print('Real Total Shares Value: $totalShareQuantity');
      return totalShareQuantity;
    } catch (e) {
      // Handle exceptions, such as JSON decoding errors or database queries failing
      print('Error calculating total share quantity: $e');
      return 0; // Return a default value or handle the error appropriately
    }
  }

  // Loan & Social Fund
  Future<Map<String, dynamic>> getLoanAndSocialFunds(int groupId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT group_profile.loanFund AS loanFund, group_profile.socialFund AS socialFund
    FROM group_form
    INNER JOIN group_profile ON group_form.group_profile_id = group_profile.id
    WHERE group_form.id = ?
  ''', [groupId]);

    if (results.isEmpty) {
      return Future.value(null); // Return a Future with a value of null
    } else {
      return Future.value(results.first); // Return a Future with the result
    }
  }
  // Future<void> deleteCycleDataForGroup(int groupId, int cycleMeetingID) async {
  //   final db = await database;
  //   await db.execute(
  //     'DELETE FROM ActiveCycleMeeting WHERE group_id = ? AND cycleMeetingID = ?',
  //     [groupId, cycleMeetingID],
  //   );
  // }

  // Function to remove active cycle meeting ID and effectively empty the table
  Future<int> removeActiveCycleMeeting(int groupId, int cycleMeetingID) async {
    final db = await database;
    return await db.delete(
      'ActiveCycleMeeting',
      where: 'group_id = ? AND cycleMeetingID = ?',
      whereArgs: [groupId, cycleMeetingID],
    );
  }

  // Future<void> removeActiveCycleMeeting(int groupId) async {
  //   Database db = await database;
  //   await db.delete(
  //       'ActiveCycleMeeting',
  //       where: 'group_id = ?',
  //       [groupId]); // This deletes all rows
  // }

  Future<int> countMeetingsForGroup(int groupId, int cycleId) async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM meeting WHERE group_id = ? AND cycle_id = ?',
        [groupId, cycleId]));
    return count ?? 0;
  }

  // Shares
  Future<void> insertShare(Map<String, dynamic> shareData) async {
    Database db = await database;
    await db.insert('shares', shareData);
  }
  // Future<int> insertShare(int meetingId, String sharePurchasesJson) async {
  //   final db = await database;
  //   return await db.insert('shares', {
  //     'meetingId': meetingId,
  //     'sharePurchases': sharePurchasesJson,
  //   });
  // }

  // loan_applicant TEXT,
  // groupId INTEGER,
  // loan_purpose TEXT,
  // loan_amount REAL,
  // interest_rate REAL,
  // start_date TEXT,
  // end_date TEXT,

  Future<List<Map<String, dynamic>>> getMemberActiveLoans(int groupId) async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> loans = await db.rawQuery('''
      SELECT id, loans.loan_applicant, loans.interest_rate, loans.loan_amount, loans.loan_purpose, loans.member_id, loans.status
      FROM loans
      WHERE groupId = ? AND status = "Active"
    ''', [
        groupId,
      ]);

      return loans;
    } catch (e) {
      print('Error retrieving members for group: $e');
      return [];
    }
  }

  // Future<List<Map<String, dynamic>>?> getMemberActiveLoans(
  //     int groupId, int cycleId) async {
  //   final Database db = await database;
  //   final List<Map<String, dynamic>> loans = await db.query(
  //     SELECT gm.id, gm.user_id,
  //     'loan_applications',
  //     where: 'group_id = ? AND cycle_id = ? AND status = Active',
  //     whereArgs: [
  //       groupId,
  //       cycleId,
  //     ], // Use both groupId and memberId as parameters
  //   );

  //   return loans;
  // }

  Future<List<Map<String, dynamic>>?> getMemberLoans(
      int groupId, int memberId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> loans = await db.query(
      'loan_applications',
      where: 'group_id = ? AND group_member_id = ?',
      whereArgs: [
        groupId,
        memberId
      ], // Use both groupId and memberId as parameters
    );

    return loans;
  }

  Future<double> getTotalLoanAmount(int groupId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(amount_needed) as total FROM loan_applications WHERE group_id = ?',
      [groupId],
    );

    double totalLoanAmount =
        result.isNotEmpty ? result.first['total'] as double : 0.0;
    return totalLoanAmount;
  }

  Future<String?> getImagePathForMember(int memberId) async {
    final Database db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['image'],
      where: 'id = ?',
      whereArgs: [memberId],
    );

    if (result.isNotEmpty) {
      return result.first['image'] as String?;
    }

    return null;
  }

  Future<String?> getphoneNumber(int memberId) async {
    final Database db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['phone'],
      where: 'id = ?',
      whereArgs: [memberId],
    );

    if (result.isNotEmpty) {
      return result.first['phone'] as String?;
    }

    return null;
  }

  Future<List<Map<String, dynamic>>?> getAllShares() async {
    final db = await instance.database;
    return await db.query('shares');
  }

  Future<List<Map<String, dynamic>>> getSharePurchases(int meetingId) async {
    final db = await database;
    return await db
        .query('shares', where: 'meetingId = ?', whereArgs: [meetingId]);
  }

  Future<List<Map<String, dynamic>>?> getSharesForMeeting(int meetingId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'shares',
      where: 'meetingId = ?',
      whereArgs: [meetingId],
    );
    return maps;
  }

  Future<void> insertGroupCycleStatus(
    int groupId,
    bool isCycleStarted,
    int cycleId,
  ) async {
    final db = await database;
    await db.rawInsert('''
      INSERT INTO group_cycle_status (group_id, is_cycle_started, cycleId)
      VALUES (?, ?, ?)
    ''', [groupId, isCycleStarted, cycleId]);
  }

  Future<int?> isCycleStarted(int groupId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'group_cycle_status',
      where: 'group_id = ?',
      whereArgs: [groupId],
    );

    if (results.isNotEmpty) {
      final bool isCycleStarted = results.first['is_cycle_started'] == 1;

      if (isCycleStarted) {
        return results
            .first['cycleId']; // Return the cycle ID if the cycle has started.
      } else {
        return null; // Return null if the cycle has not started.
      }
    } else {
      return null; // Default to returning null if no record is found.
    }
  }

  // Future<bool> isCycleStartedForGroup(int groupId) async {
  //   final db = await database;

  //   // Execute a query to check if a cycle has started for the given group_id
  //   final List<Map<String, dynamic>> result = await db.query(
  //     'group_cycle_status',
  //     columns: ['is_cycle_started'],
  //     where: 'group_id = ?',
  //     whereArgs: [groupId],
  //   );

  //   await db.close();

  //   // If there is a row with the specified group_id, print and return its 'is_cycle_started' value as a boolean
  //   if (result.isNotEmpty) {
  //     bool isCycleStarted = result[0]['is_cycle_started'] == 1;
  //     print(
  //         'is_cycle_started for group $groupId: $isCycleStarted'); // Print the is_cycle_started value
  //     return isCycleStarted;
  //   } else {
  //     // If no row exists, the cycle hasn't started, so return false
  //     print(
  //         'No cycle information found for group $groupId'); // Print when no cycle information is found
  //     return false;
  //   }
  // }

  // Future<bool> isCycleStartedForGroup(int groupId) async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> result = await db.query(
  //     'group_cycle_status',
  //     columns: ['is_cycle_started'],
  //     where: 'group_id = ?',
  //     whereArgs: [groupId],
  //     limit: 1,
  //   );
  //   await db.close();
  //   if (result.isEmpty) {
  //     return false; // Assuming the default value for is_cycle_started is 0
  //   }
  //   return result.first['is_cycle_started'] == 1;
  // }

  Future<bool> isCycleStartedForGroup(int groupId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT is_cycle_started
      FROM group_cycle_status
      WHERE group_id = ?
    ''', [groupId]);

    if (result.isNotEmpty) {
      final isCycleStarted = result[0]['is_cycle_started'];
      return isCycleStarted == 1; // Convert 1/0 to true/false
    }
    return false; // Default to false if no record is found
  }

  // Define the deleteLoanEntry method
  Future<int> deleteSocialEntry(int id) async {
    Database db = await instance.database;
    return await db
        .delete('social_fund_applications', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateSocialEntry(
    int loanId,
    double updatedAmount,
    String updatedLoanPurpose,
    String updatedRepaymentDate,
  ) async {
    final db = await instance.database;
    final updatedLoan = {
      'id': loanId,
      'amount_needed': updatedAmount,
      'social_purpose': updatedLoanPurpose,
      'repayment_date': updatedRepaymentDate,
    };

    await db.update(
      'social_fund_applications',
      updatedLoan,
      where: 'id = ?',
      whereArgs: [loanId],
    );
  }

// Insert loan applications
  Future<int> insertLoanApplication(
      Map<String, dynamic> loanApplication) async {
    final db = await database;
    return await db.insert('loan_applications', loanApplication);
  }

// Insert Social Loan
  Future<int> insertSocialApplication(
      Map<String, dynamic> loanApplication) async {
    final db = await database;
    return await db.insert('social_fund_applications', loanApplication);
  }

  // Function to add user data to the "users" table and return the inserted user ID
  Future<int> addUser(Map<String, dynamic> userData) async {
    final Database db = await database;
    final id = await db.insert('users', userData);
    return id;
  }

  // Function to retrieve user data from the "users" table
  Future<List<Map<String, dynamic>>> getUsers() async {
    final Database db = await database;
    final List<Map<String, dynamic>> userList = await db.query('users');
    return userList;
  }

  // Future<Map<String, dynamic>?> getUserByPhoneNumberAndUniqueCode(
  //     String phoneNumber, String uniqueCode) async {
  //   final Database db = await instance.database;

  //   final List<Map<String, dynamic>> results = await db.query(
  //     'users',
  //     columns: ['fname', 'lname', 'phone', 'id'],
  //     where: 'phone = ? AND unique_code = ?',
  //     whereArgs: [phoneNumber, uniqueCode],
  //   );

  //   if (results.isNotEmpty) {
  //     return results.first;
  //   } else {
  //     return null; // No matching user found
  //   }
  // }

  // Delete Meeting

  Future<int> deleteCurrentMeeting(
      int groupId, int cycleId, int meetingId) async {
    final db = await database;

    try {
      int rowsDeleted = await db.delete(
        'meeting',
        where: 'id = ? AND group_id = ? AND cycle_id = ?',
        whereArgs: [meetingId, groupId, cycleId],
      );

      return rowsDeleted;
    } catch (e) {
      print('Error deleting meeting: $e');
      return 0; // Return 0 to indicate an error occurred.
    }
  }

  Future<void> updateMemberDetails(
      int memberId, Map<String, dynamic> newDetails) async {
    final Database db = await database;
    try {
      await db.update(
        'user_data',
        newDetails,
        where: 'id = ?',
        whereArgs: [memberId],
      );
    } catch (e) {
      print('Error updating member details: $e');
      rethrow; // You can handle the error as needed
    }
  }

  Future<List<Map<String, dynamic>>> getUserData(int memberId) async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> userData = await db.rawQuery('''
      SELECT *
      FROM users
      WHERE id = ?
    ''', [memberId]);
      print('User Data for member $memberId: $userData');
      return userData;
    } catch (e) {
      print('Error retrieving user data: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMembersForGroup(int groupId) async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> members = await db.rawQuery('''
      SELECT users.fname, users.lname, users.phone, users.id
      FROM group_members
      JOIN users ON group_members.user_id = users.id
      WHERE group_members.group_id = ?
    ''', [groupId]);

      return members;
    } catch (e) {
      print('Error retrieving members for group: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getMemberDetails(int memberId) async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> memberDetails = await db.query(
        'user_data',
        where: 'id = ?',
        whereArgs: [memberId],
      );

      if (memberDetails.isNotEmpty) {
        return memberDetails.first;
      } else {
        return {}; // Return an empty map if member not found
      }
    } catch (e) {
      print('Error retrieving member details: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getGroupMembersByGroupId(
      int groupId) async {
    final db = await instance.database;
    return await db.rawQuery('''
    SELECT gm.id, gm.user_id, gm.group_id, ud.fname, ud.lname
    FROM group_members gm
    INNER JOIN users ud ON gm.user_id = ud.id
    WHERE gm.group_id = ?
  ''', [groupId]);
  }

  Future<Map<String, dynamic>?> getLoanApplicationByDate(
      int groupId,
      int cycleId,
      int meetingId,
      String memberId,
      DateTime applicationDate) async {
    final Database db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'loan_applications',
      where:
          'group_id = ? AND cycle_id = ? AND meetingId = ? AND group_member_id = ? AND submission_date = ?',
      whereArgs: [
        groupId,
        cycleId,
        meetingId,
        memberId,
        applicationDate.toIso8601String()
      ],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  // Future<Map<String, dynamic>?> getLoanApplicationByDate(
  //     String memberId, DateTime applicationDate) async {
  //   final Database db = await instance.database;
  //   final List<Map<String, dynamic>> result = await db.query(
  //     'loan_applications',
  //     where: 'group_member_id = ? AND submission_date = ?',
  //     whereArgs: [memberId, applicationDate.toIso8601String()],
  //   );

  //   if (result.isNotEmpty) {
  //     return result.first;
  //   } else {
  //     return null;
  //   }
  // }

  Future<int?> getUserIdByMemberId(int memberId) async {
    final Database db = await database;
    try {
      var result = await db.rawQuery(
        'SELECT user_id FROM group_members WHERE id = ?',
        [memberId],
      );

      if (result.isNotEmpty) {
        return result.first['user_id'] as int?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving user ID by member ID: $e');
      return null;
    }
  }

  Future<String?> getFullNameForUserId(int userId) async {
    final Database db = await database;
    try {
      var result = await db.rawQuery(
        'SELECT fname, lname FROM users WHERE id = ?',
        [userId],
      );

      if (result.isNotEmpty) {
        var firstName = result.first['fname'] as String?;
        var lastName = result.first['lname'] as String?;

        if (firstName != null && lastName != null) {
          return '$firstName $lastName';
        } else {
          return null; // Handle null values as needed
        }
      } else {
        return null; // No user found with the given ID
      }
    } catch (e) {
      print('Error retrieving full name for user ID: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSocialApplicationByDetails(
      int groupId,
      int cycleId,
      int meetingId,
      String memberId,
      DateTime applicationDate) async {
    final Database db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'social_fund_applications',
      where:
          'group_id = ? AND cycle_id = ? AND meeting_id = ? AND group_member_id = ? AND submission_date = ?',
      whereArgs: [
        groupId,
        cycleId,
        meetingId,
        memberId,
        applicationDate.toIso8601String()
      ],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  // // Method to get recent loan activity data
  // Future<List<Map<String, dynamic>>> getRecentSocialActivity() async {
  //   final Database db = await instance.database;
  //   final List<Map<String, dynamic>> result = await db.query(
  //     'social_fund_applications',
  //     orderBy:
  //         'submission_date DESC', // Sort by submission_date in descending order
  //   );
  //   return result;
  // }

  // // Method to get recent loan activity data
  // Future<List<Map<String, dynamic>>> getRecentLoanActivity() async {
  //   final Database db = await instance.database;
  //   final List<Map<String, dynamic>> result = await db.query(
  //     'loan_applications',
  //     orderBy:
  //         'submission_date DESC', // Sort by submission_date in descending order
  //   );
  //   return result;
  // }

  // Future<List<Map<String, dynamic>>> getLinkedDataForUser(User user) async {
  //   final Database db = await database;
  //   try {
  //     List<Map<String, dynamic>> linkedData = await db.rawQuery('''
  //     SELECT group_profile.id as group_id, group_profile.groupName
  //     FROM assigned_positions
  //     JOIN group_profile ON assigned_positions.group_id = group_profile.id
  //     JOIN positions ON assigned_positions.position_id = positions.id
  //     WHERE assigned_positions.member_id = ?
  //     AND (positions.name = 'Chairman' OR positions.name = 'Secretary')
  //   ''', [user.id]);
  //     // Print the SQL query
  //     return linkedData;
  //   } catch (e) {
  //     print('Error retrieving linked data for user: $e'); // Print any errors
  //     return [];
  //   }
  // }

  // Future<List<Map<String, dynamic>>> getLinkedDataForUser(int id) async {
  //   final Database db = await database;
  //   try {
  //     List<Map<String, dynamic>> linkedData = await db.rawQuery('''
  //     SELECT group_form.group_id, group_profile.groupName
  //     FROM group_members
  //     JOIN group_form ON group_members.group_id = group_form.group_id
  //     JOIN group_profile ON group_form.group_profile_id = group_profile.id
  //     JOIN assigned_positions ON group_members.id = assigned_positions.member_id
  //     WHERE group_members.user_id = ?
  //     AND (assigned_positions.position_id = 1 OR assigned_positions.position_id = 2)
  //   ''', [id]);
  //     return linkedData;
  //   } catch (e) {
  //     print('Error retrieving linked data for user: $e');
  //     return [];
  //   }
  // }

  Future<List<Map<String, dynamic>>> getMemberIdsForGroup(int groupId) async {
    final Database db = await database;

    final memberIds = await db.rawQuery('''
      SELECT member_id, position_name
      FROM assigned_positions
      WHERE assigned_positions.group_id = ?
    ''', [groupId]);

    return memberIds.map((row) => row).toList();
  }

  Future<List<Map<String, dynamic>>> getMemberNamesAndPositions(
      List<int> memberIds) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> memberNamesAndPositions = [];

    for (int memberId in memberIds) {
      final memberData = await db.rawQuery('''
        SELECT users.fname, users.lname, group_members.position_name
        FROM users
        INNER JOIN group_members ON users.id = group_members.user_id
        WHERE group_members.id = ?
      ''', [memberId]);

      if (memberData.isNotEmpty) {
        memberNamesAndPositions.add(memberData.first);
      }
    }

    return memberNamesAndPositions;
  }

  Future<List<int>> getGroupIdsForUser(int userId) async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> groups = await db.rawQuery('''
      SELECT group_id
      FROM group_members
      WHERE user_id = ?
    ''', [userId]);

      List<int> groupIds =
          groups.map<int>((group) => group['group_id'] as int).toList();
      return groupIds;
    } catch (e) {
      print('Error retrieving group IDs for user: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLinkedDataForUser(
      List<int> groupIds) async {
    final Database db = await database;
    List<Map<String, dynamic>> groupNames = [];

    // Assuming your group_profile table has 'id' and 'groupName' columns
    for (int groupId in groupIds) {
      List<Map<String, dynamic>> result = await db.query('group_profile',
          columns: ['id', 'groupName'], where: 'id = ?', whereArgs: [groupId]);

      if (result.isNotEmpty) {
        groupNames.add({
          'group_id': result[0]['id'],
          'groupName': result[0]['groupName'],
        });
      }
    }

    return groupNames;
  }

//   Future<List<Map<String, dynamic>>> getLinkedDataForUser(int id) async {
//     final Database db = await database;
//     try {
//       List<Map<String, dynamic>> linkedData = await db.rawQuery('''
//       SELECT DISTINCT group_members.group_id, group_profile.groupName
// FROM group_members
// JOIN group_profile ON group_members.group_id = group_profile.id
// JOIN assigned_positions ON group_members.id = assigned_positions.member_id
// WHERE group_members.user_id = ? AND
//   assigned_positions.position_name IN ('Secretary', 'Chairman')

//     ''', [id]);
//       return linkedData;
//     } catch (e) {
//       print('Error retrieving linked data for user: $e');
//       return [];
//     }
//   }

  // Future<List<Map<String, dynamic>>> getLinkedDataForUser(User user) async {
  //   final Database db = await database;
  //   try {
  //     List<Map<String, dynamic>> linkedData = await db.rawQuery('''
  //     SELECT group_profile.id as group_id, group_profile.groupName
  //     FROM group_members
  //     JOIN group_profile ON group_members.group_id = group_profile.id
  //     JOIN positions ON group_members.user_id = positions.member_id
  //     WHERE group_members.user_id = ?
  //     AND (positions.name = 'Chairman' OR positions.name = 'Secretary')
  //   ''', [user.id]);
  //     return linkedData;
  //   } catch (e) {
  //     print('Error retrieving linked data for user: $e');
  //     return [];
  //   }
  // }

  Future<int?> insertLinkedData(
      int groupId,
      int loggedInUserId,
      int? groupProfileId,
      int? constitutionId,
      int? cycleScheduleId,
      int? groupMemberId,
      int? assignedPositionId) async {
    final Database db = await database;
    try {
      int insertedRowId = await db.insert('group_form', {
        'group_id': groupId,
        'logged_in_user_id': loggedInUserId,
        'group_profile_id': groupProfileId,
        'constitution_id': constitutionId,
        'cycle_schedule_id': cycleScheduleId,
        'group_member_id': groupMemberId,
        'assigned_position_id': assignedPositionId,
      });
      return insertedRowId;
    } catch (e) {
      print('Error inserting linked data: $e');
      return null;
    }
  }

  Future<int?> getGroupProfileId(int groupId) async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> result = await db.query(
        'group_profile',
        columns: ['id'],
        where: 'id = ?',
        whereArgs: [groupId],
      );
      if (result.isNotEmpty) {
        return result.first['id'] as int?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving Group Profile ID: $e');
      return null;
    }
  }

  Future<int> getConstitutionId(int groupId) async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> result = await db.query(
        'constitution_table',
        columns: ['id'],
        where: 'group_id = ?',
        whereArgs: [groupId],
      );
      if (result.isNotEmpty) {
        return result.first['id'] as int;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error retrieving Constitution ID: $e');
      return 0;
    }
  }

  Future<int> getCycleScheduleId(int groupId) async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> result = await db.query(
        'cycle_schedules',
        columns: ['id'],
        where: 'group_id = ?',
        whereArgs: [groupId],
      );
      if (result.isNotEmpty) {
        return result.first['id'] as int;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error retrieving Cycle Schedule ID: $e');
      return 0;
    }
  }

  Future<int> getGroupMemberId(int groupId) async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> result = await db.query(
        'group_members',
        columns: ['id'],
        where: 'group_id = ?',
        whereArgs: [groupId],
      );
      if (result.isNotEmpty) {
        return result.first['id'] as int;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error retrieving Group Member ID: $e');
      return 0;
    }
  }

  Future<int> getAssignedPositionId(int groupId) async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> result = await db.query(
        'assigned_positions',
        columns: ['id'],
        where: 'group_id = ?',
        whereArgs: [groupId],
      );
      if (result.isNotEmpty) {
        return result.first['id'] as int;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error retrieving Assigned Position ID: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>>
      getAllGroupProfilesWithConstitution() async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> groupProfilesWithConstitution =
          await db.rawQuery('''
      SELECT group_profile.*, constitution_table.*
      FROM group_profile
      INNER JOIN constitution_table ON group_profile.id = constitution_table.group_id
    ''');
      return groupProfilesWithConstitution;
    } catch (e) {
      print('Error retrieving group profiles with constitution: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllAssignedPositions() async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> assignedPositions =
          await db.query('assigned_positions');
      return assignedPositions;
    } catch (e) {
      print('Error retrieving assigned positions: $e');
      return [];
    }
  }

  Future<int> insertGroupLink(Map<String, dynamic> groupLinkData) async {
    final Database db = await database;
    final int insertedId = await db.insert('group_link', groupLinkData);
    return insertedId;
  }

  Future<List<Map<String, dynamic>>> retAllGroupMembers() async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> groupMembers = await db.query('group_members');
      return groupMembers;
    } catch (e) {
      print('Error retrieving group members: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllCycleSchedules() async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> cycleSchedules =
          await db.query('cycle_schedules');
      return cycleSchedules;
    } catch (e) {
      print('Error retrieving cycle schedules: $e');
      return [];
    }
  }

  Future<List<Group>> getGroupsFromDatabase() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('group_link');

    return List.generate(maps.length, (index) {
      return Group(
        id: maps[index]['group_id'],
        name: maps[index]['group_name'],
      );
    });
  }

  // Check if the data is not already present in the 'group_link' table
  Future<bool> isDataNotInGroupLinkTable(Map<String, dynamic> data) async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query('group_link',
        where: 'group_name = ? AND group_profile_id = ?',
        whereArgs: [data['group_name'], data['group_profile_id']]);
    return result.isEmpty;
  }

  // /// Function to insert data into the 'group_link' table
  // Future<int> insertGroupLink(Map<String, dynamic> data) async {
  //   final Database db = await database;

  //   // Check if the data is not already present in the table
  //   if (await isDataNotInGroupLinkTable(data)) {
  //     final int insertedRows = await db.insert('group_link', data);
  //     print('Data inserted into the group_link table successfully.');
  //     return insertedRows;
  //   } else {
  //     print('Data already exists in the group_link table. Skipping insertion.');
  //     return 0; // Return 0 to indicate that no rows were inserted
  //   }
  // }

  // Form Verification
  Future<bool> checkGroupProfileData(int groupId) async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM group_profile WHERE id = ?',
      [groupId],
    ));
    return count! > 0;
  }

  Future<bool> checkConstitutionData(int groupId) async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM constitution_table WHERE group_id = ?',
      [groupId],
    ));
    return count! > 0;
  }

  Future<bool> checkCycleScheduleData(int groupId) async {
    try {
      final db = await instance.database;
      final count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM cycle_schedules WHERE group_id = ?',
        [groupId],
      ));
      return count! > 0;
    } catch (e) {
      print('Error in checkCycleScheduleData: $e');
      return false; // Return false to indicate an error occurred
    }
  }

  Future<bool> checkGroupMembersData(int groupId) async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM group_members WHERE group_id = ?',
      [groupId],
    ));
    return count! > 0;
  }

  Future<bool> checkAssignedPositionsData(int groupId) async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM assigned_positions WHERE group_id = ?',
      [groupId],
    ));
    return count! > 0;
  }

  // Retrieve the group ID from the 'group_link' table
  Future<int?> getGroupId() async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query('group_link');
    if (result.isNotEmpty) {
      final Map<String, dynamic> data = result.first;
      return data['id'] as int;
    }
    return null; // Return null if no data is found
  }

  // Retrieve the ID from the 'constitution_table' table
  Future<int?> getConstitutionTableId() async {
    final Database db = await database;
    final List<Map<String, dynamic>> result =
        await db.query('constitution_table');
    if (result.isNotEmpty) {
      return result.first['id'];
    }
    return null; // Return null if no data is found
  }

// Retrieve the ID from the 'cycle_schedules' table
  Future<int?> getCycleSchedulesId() async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query('cycle_schedules');
    if (result.isNotEmpty) {
      return result.first['id'];
    }
    return null; // Return null if no data is found
  }

// Retrieve the ID from the 'group_members' table
  Future<int?> getGroupMembersId() async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query('group_members');
    if (result.isNotEmpty) {
      return result.first['id'];
    }
    return null; // Return null if no data is found
  }

// Retrieve the ID from the 'assigned_positions' table
  Future<int?> getAssignedPositionsId() async {
    final Database db = await database;
    final List<Map<String, dynamic>> result =
        await db.query('assigned_positions');
    if (result.isNotEmpty) {
      return result.first['id'];
    }
    return null; // Return null if no data is found
  }

// Retrieve the ID, image, and name from the 'group_profile' table
  Future<Map<String, dynamic>?> getGroupProfileData() async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query('group_profile');
    if (result.isNotEmpty) {
      final Map<String, dynamic> data = result.first;
      return {
        'id': data['id'],
        'groupName': data['groupName'],
        'groupLogoPath': data['groupLogoPath'],
      };
    }
    return null; // Return null if no data is found
  }

  // Insert data into cycle_schedules table
  Future<void> insertScheduleData(Map<String, dynamic> scheduleData) async {
    final db = await database;
    await db.insert('cycle_schedules', scheduleData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Future<void> insertScheduleData({
  //   required String meetingDuration,
  //   required int numberOfMeetings,
  //   required String meetingFrequency,
  //   required String dayOfWeek,
  //   required String startDate,
  //   required String shareOutDate,
  //   required int groupId,
  // }) async {
  //   final db = await database;
  //   await db.insert('cycle_schedules', {
  //     'meeting_duration': meetingDuration,
  //     'number_of_meetings': numberOfMeetings,
  //     'meeting_frequency': meetingFrequency,
  //     'day_of_week': dayOfWeek,
  //     'start_date': startDate,
  //     'share_out_date': shareOutDate,
  //   });
  // }

  Future<void> insertPosition(String positionName) async {
    final db = await database;
    await db.insert('positions', {'name': positionName});
  }

  Future<void> removePosition(String positionName) async {
    final db = await database;
    await db.delete('positions', where: 'name = ?', whereArgs: [positionName]);
  }

  Future<void> assignPosition(int positionId, int memberId, int groupId) async {
    final db = await database;
    await db.insert('assigned_positions', {
      'position_id': positionId,
      'member_id': memberId,
      'group_id': groupId,
    });
  }

  Future<void> updatePosition(int positionId, int memberId, int groupId) async {
    final db = await database;
    await db.update(
      'assigned_positions',
      {
        'member_id': memberId,
      },
      where: 'position_id = ? AND group_id = ?',
      whereArgs: [positionId, groupId],
    );
  }

  Future<List<String>> getAllPositions() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('positions');
    return results.map((map) => map['name'] as String).toList();
  }

  Future<void> deassignPosition(int memberId) async {
    final db = await database;
    await db.delete('assigned_positions',
        where: 'member_id = ?', whereArgs: [memberId]);
  }

  // Insert a user into the 'user' table
  Future<int> insertUser(Map<String, dynamic> user) async {
    final Database db = await database;
    return await db.insert('user', user);
  }

  // Retrieve all users from the 'user' table
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final Database db = await database;
    return await db.query('user');
  }

  // Insert a meeting into the 'meeting' table
  Future<int> insertMeeting(Map<String, dynamic> meeting) async {
    final Database db = await database;
    return await db.insert('meeting', meeting);
  }

  // Retrieve all meetings from the 'meeting' table
  Future<List<Map<String, dynamic>>> getAllMeetings() async {
    final Database db = await database;
    return await db.query('meeting');
  }

  // Insert a meeting into the 'meeting' table
  Future<int> insertCycleStartMeeting(Map<String, dynamic> cyclemeeting) async {
    final Database db = await database;
    return await db.insert('cyclemeeting', cyclemeeting);
  }

  // Retrieve all meetings from the 'meeting' table
  Future<List<Map<String, dynamic>>> getAllCycleStartMeetings() async {
    final Database db = await database;
    return await db.query('cyclemeeting');
  }

  // Insert a group profile into the 'group_profile' table
  Future<int?> insertGroupProfile(Map<String, dynamic> groupProfile) async {
    final Database db = await database;
    try {
      int insertedRowId = await db.insert('group_profile', groupProfile);
      print('Success group profile: $insertedRowId');
      return insertedRowId;
    } catch (e) {
      print('Error inserting group profile: $e');
      return null;
    }
  }

  // Function to retrieve group name by group ID
  Future<String?> getGroupNameByGroupId(String groupId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'group_profile',
      columns: ['groupName'],
      where: 'id = ?',
      whereArgs: [groupId],
    );

    if (results.isNotEmpty) {
      return results.first['groupName'] as String;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllGroupProfiles() async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> groupProfiles = await db.query('group_form');
      return groupProfiles;
    } catch (e) {
      print('Error retrieving group profiles: $e');
      return [];
    }
  }

  // Method to insert data into the 'constitution_table'
  Future<int> insertConstitutionData(Map<String, dynamic> data) async {
    final Database db = await database;
    return await db.insert('constitution_table', data);
  }

  // Method to retrieve all data from the 'constitution_table'
  Future<List<Map<String, dynamic>>> getAllConstitutionData() async {
    final Database db = await database;
    return await db.query('constitution_table');
  }

  Future<int> insertUserData(Map<String, dynamic> userData) async {
    final Database db = await database;
    return await db.insert('user_data', userData);
  }

  Future<List<Map<String, dynamic>>> getAllUserData() async {
    final Database db = await database;
    return await db.query('user_data');
  }

  Future<int> addMemberToGroup(int userId, int groupId) async {
    final Database db = await database;
    final Map<String, dynamic> memberData = {
      'user_id': userId,
      'group_id': groupId, // Add group_id
    };
    return await db.insert('group_members', memberData);
  }

  Future<List<Map<String, dynamic>>> retrieveGroupMembers() async {
    final Database db = await database;
    return await db.query('group_members');
  }

  // Future<List<Map<String, dynamic>>> getAllGroupMembers() async {
  //   final db = await database;
  //   return await db.query('group_members');
  // }

  Future<List<Map<String, dynamic>>> getAllGroupMembers() async {
    final db = await database;
    return await db.rawQuery('''
    SELECT gm.id, gm.user_id, ud.first_name, ud.last_name
    FROM group_members gm
    LEFT JOIN user_data ud ON gm.user_id = ud.id
  ''');
  }

  Future<bool> isMemberInGroup(int userId, int groupId) async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM group_members WHERE user_id = ? AND group_id = ?',
        [userId, groupId]));

    return (count ?? 0) > 0;
  }

  Future<Map<String, dynamic>> searchUserByUniqueCode(String uniqueCode) async {
    final Database db = await database;
    try {
      final List<Map<String, dynamic>> results = await db.query(
        'users',
        columns: ['id', 'fname', 'lname'],
        where: 'unique_code = ?',
        whereArgs: [uniqueCode],
      );

      if (results.isNotEmpty) {
        return results.first;
      } else {
        return {}; // Return an empty map when no results are found
      }
    } catch (e) {
      print('Error in searchUserByUniqueCode: $e');
      return {}; // Return an empty map in case of an error
    }
  }

  // Future<List<Map<String, dynamic>>> searchUserByUniqueCode(
  //     String uniqueCode) async {
  //   final Database db = await database;
  //   final List<Map<String, dynamic>> results = await db.query(
  //     'users',
  //     where: 'unique_code = ?',
  //     whereArgs: [uniqueCode],
  //   );
  //   return results;
  // }

  Future<bool> isGroupProfileSaved(int groupId) async {
    final Database db = await database;
    final result = await db.query(
      'group_profile',
      where: 'id = ?',
      whereArgs: [groupId],
    );
    return result.isNotEmpty;
  }

  void getTodo() {}
}
