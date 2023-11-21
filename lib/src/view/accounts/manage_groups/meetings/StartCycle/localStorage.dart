import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

import '../../../../models/group_model.dart';
import '../../../../widgets/user_class.dart';

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
    print('Database path: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> initializeDatabase() async {
    final Database db = await database;

    // Check if the positions table is empty
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM positions'));

    if (count == 0) {
      // Insert default positions if the table is empty
      await db
          .rawInsert('INSERT INTO positions (name) VALUES (?)', ['Chairman']);
      await db
          .rawInsert('INSERT INTO positions (name) VALUES (?)', ['Secretary']);
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
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
    sharePurchases TEXT            
  )
''');

    // Create a table for group profiles
    await db.execute('''
      CREATE TABLE group_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
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
        socialFund TEXT
      )
    ''');

    await db.execute('''
  CREATE TABLE constitution_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
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
    selectedCollateralRequirements TEXT,
    FOREIGN KEY (group_id) REFERENCES group_profile (id) ON DELETE CASCADE 
  )
''');

    await db.execute('''
    CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        unique_code TEXT,
        fname TEXT,
        lname TEXT,
        email TEXT,
        phone TEXT,
        sex TEXT,
        country TEXT,
        date_of_birth TEXT,  
        image_path TEXT,
        district TEXT,
        subCounty TEXT,
        village TEXT,
        number_of_dependents TEXT,
        family_information TEXT,
        next_of_kin_name TEXT,
        next_of_kin_has_phone_number INTEGER,
        next_of_kin_phone_number TEXT,
        pwd_type TEXT
    )
''');

    await db.execute('''
  CREATE TABLE user_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
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
    residency_status TEXT
  )
''');
    await db.execute('''
  CREATE TABLE group_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    group_id INTEGER,  
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES group_profile (id) ON DELETE CASCADE  
  )
''');

    await db.execute('''
CREATE TABLE positions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT
)
''');
    await db.execute('''
  CREATE TABLE assigned_positions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_id INTEGER,
    member_id INTEGER,
    group_id INTEGER,  
    FOREIGN KEY (position_id) REFERENCES positions (id),
    FOREIGN KEY (member_id) REFERENCES group_members (id),
    FOREIGN KEY (group_id) REFERENCES group_profile (id)  
  )
''');

    await db.execute('''CREATE TABLE cycle_schedules (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    group_id INTEGER,
    meeting_duration TEXT,
    number_of_meetings INTEGER,
    meeting_frequency TEXT,
    day_of_week TEXT,
    start_date TEXT,
    share_out_date TEXT,
    FOREIGN KEY (group_id) REFERENCES group_profile (id) ON DELETE CASCADE 
  )''');

    await db.execute('''
  CREATE TABLE group_link (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    group_id INTEGER,  
    group_name TEXT,
    group_image_path TEXT,
    constitution_id INTEGER,
    cycle_schedule_id INTEGER,
    group_members_id INTEGER,
    assigned_positions_id INTEGER,
    FOREIGN KEY (group_id) REFERENCES group_profile (id)  
    FOREIGN KEY (constitution_id) REFERENCES constitution_table (id),
    FOREIGN KEY (cycle_schedule_id) REFERENCES cycle_schedules (id),
    FOREIGN KEY (group_members_id) REFERENCES group_members (id),
    FOREIGN KEY (assigned_positions_id) REFERENCES assigned_positions (id)
  )
''');

    await db.execute('''
  CREATE TABLE group_form (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    group_id INTEGER,
    group_profile_id INTEGER,
    constitution_id INTEGER,
    cycle_schedule_id INTEGER,
    group_member_id INTEGER,
    assigned_position_id INTEGER,
    FOREIGN KEY (group_id) REFERENCES group_profile (id),
    FOREIGN KEY (group_profile_id) REFERENCES group_profile (id),
    FOREIGN KEY (constitution_id) REFERENCES constitution_table (id),
    FOREIGN KEY (cycle_schedule_id) REFERENCES cycle_schedules (id),
    FOREIGN KEY (group_member_id) REFERENCES group_members (id),
    FOREIGN KEY (assigned_position_id) REFERENCES assigned_positions (id)
  )
''');

    await db.execute('''
  CREATE TABLE loan_applications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    group_id INTEGER,
    submission_date TEXT,
    loan_applicant TEXT,
    group_member_id INTEGER,
    amount_needed REAL,
    loan_purpose TEXT,
    repayment_date TEXT,
    FOREIGN KEY (group_id) REFERENCES group_profile (id) ON DELETE CASCADE,
    FOREIGN KEY (group_member_id) REFERENCES group_members (id) ON DELETE CASCADE
  )
''');

    await db.execute('''
  CREATE TABLE social_fund_applications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    group_id INTEGER,
    submission_date TEXT,
    applicant TEXT,
    group_member_id INTEGER,
    amount_needed REAL,
    social_purpose TEXT,
    repayment_date TEXT,
    FOREIGN KEY (group_id) REFERENCES group_profile (id) ON DELETE CASCADE,
    FOREIGN KEY (group_member_id) REFERENCES group_members (id) ON DELETE CASCADE
  )
''');

    await db.execute('''
  CREATE TABLE cycle_start_meeting (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
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
    share_purchases TEXT
  )
''');

    await db.execute('''
  CREATE TABLE group_cycle_status (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    group_id INTEGER,
    is_cycle_started BOOLEAN,
    FOREIGN KEY (group_id) REFERENCES group_profile (id)
  )
''');

// Insert default positions
    await db.rawInsert('INSERT INTO positions (name) VALUES (?)', ['Chairman']);
    await db
        .rawInsert('INSERT INTO positions (name) VALUES (?)', ['Secretary']);
  }

  Future<void> insertGroupCycleStatus(int groupId, bool isCycleStarted) async {
    final db = await database;
    await db.rawInsert('''
      INSERT INTO group_cycle_status (group_id, is_cycle_started)
      VALUES (?, ?)
    ''', [groupId, isCycleStarted]);
  }

  // Define the deleteLoanEntry method
  Future<int> deleteLoanEntry(int id) async {
    Database db = await instance.database;
    return await db
        .delete('loan_applications', where: 'id = ?', whereArgs: [id]);
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

  Future<void> updateLoanEntry(
    int loanId,
    double updatedAmount,
    String updatedLoanPurpose,
    String updatedRepaymentDate,
  ) async {
    final db = await instance.database;
    final updatedLoan = {
      'id': loanId,
      'amount_needed': updatedAmount,
      'loan_purpose': updatedLoanPurpose,
      'repayment_date': updatedRepaymentDate,
    };

    await db.update(
      'loan_applications',
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

  // Add this method to your database helper class
  Future<Map<String, dynamic>?> getUserByPhoneNumberAndUniqueCode(
      String phoneNumber, String uniqueCode) async {
    final Database db = await instance.database;

    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'phone = ? AND unique_code = ?',
      whereArgs: [phoneNumber, uniqueCode],
    );

    if (results.isNotEmpty) {
      return results.first;
    } else {
      return null; // No matching user found
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
      FROM user_data
      WHERE id = ?
    ''', [memberId]);

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
      String memberId, DateTime applicationDate) async {
    final Database db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'loan_applications',
      where: 'group_member_id = ? AND submission_date = ?',
      whereArgs: [memberId, applicationDate.toIso8601String()],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSocialApplicationByDate(
      String memberId, DateTime applicationDate) async {
    final Database db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'social_fund_applications',
      where: 'group_member_id = ? AND submission_date = ?',
      whereArgs: [memberId, applicationDate.toIso8601String()],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  // Method to get recent loan activity data
  Future<List<Map<String, dynamic>>> getRecentSocialActivity() async {
    final Database db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'social_fund_applications',
      orderBy:
          'submission_date DESC', // Sort by submission_date in descending order
    );
    return result;
  }

  // Method to get recent loan activity data
  Future<List<Map<String, dynamic>>> getRecentLoanActivity() async {
    final Database db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'loan_applications',
      orderBy:
          'submission_date DESC', // Sort by submission_date in descending order
    );
    return result;
  }

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

  Future<List<Map<String, dynamic>>> getLinkedDataForUser(User user) async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> linkedData = await db.rawQuery('''
      SELECT group_profile.id as group_id, group_profile.groupName
      FROM group_members
      JOIN group_profile ON group_members.group_id = group_profile.id
      JOIN assigned_positions ON group_members.id = assigned_positions.member_id
      WHERE group_members.user_id = ?
      AND (assigned_positions.position_id = 1 OR assigned_positions.position_id = 2)
    ''', [user.id]);
      return linkedData;
    } catch (e) {
      print('Error retrieving linked data for user: $e');
      return [];
    }
  }

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
      int? groupProfileId,
      int? constitutionId,
      int? cycleScheduleId,
      int? groupMemberId,
      int? assignedPositionId) async {
    final Database db = await database;
    try {
      int insertedRowId = await db.insert('group_form', {
        'group_id': groupId,
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

  Future<int?> getConstitutionId(int groupId) async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> result = await db.query(
        'constitution_table',
        columns: ['id'],
        where: 'group_id = ?',
        whereArgs: [groupId],
      );
      if (result.isNotEmpty) {
        return result.first['id'] as int?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving Constitution ID: $e');
      return null;
    }
  }

  Future<int?> getCycleScheduleId(int groupId) async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> result = await db.query(
        'cycle_schedules',
        columns: ['id'],
        where: 'group_id = ?',
        whereArgs: [groupId],
      );
      if (result.isNotEmpty) {
        return result.first['id'] as int?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving Cycle Schedule ID: $e');
      return null;
    }
  }

  Future<int?> getGroupMemberId(int groupId) async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> result = await db.query(
        'group_members',
        columns: ['id'],
        where: 'group_id = ?',
        whereArgs: [groupId],
      );
      if (result.isNotEmpty) {
        return result.first['id'] as int?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving Group Member ID: $e');
      return null;
    }
  }

  Future<int?> getAssignedPositionId(int groupId) async {
    final Database db = await database;
    try {
      List<Map<String, dynamic>> result = await db.query(
        'assigned_positions',
        columns: ['id'],
        where: 'group_id = ?',
        whereArgs: [groupId],
      );
      if (result.isNotEmpty) {
        return result.first['id'] as int?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving Assigned Position ID: $e');
      return null;
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

  Future<void> insertScheduleData({
    required String meetingDuration,
    required int numberOfMeetings,
    required String meetingFrequency,
    required String dayOfWeek,
    required String startDate,
    required String shareOutDate,
    required int groupId,
  }) async {
    final db = await database;
    await db.insert('cycle_schedules', {
      'meeting_duration': meetingDuration,
      'number_of_meetings': numberOfMeetings,
      'meeting_frequency': meetingFrequency,
      'day_of_week': dayOfWeek,
      'start_date': startDate,
      'share_out_date': shareOutDate,
    });
  }

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
  Future<int> insertCycleStartMeeting(Map<String, dynamic> meeting) async {
    final Database db = await database;
    return await db.insert('meeting', meeting);
  }

  // Retrieve all meetings from the 'meeting' table
  Future<List<Map<String, dynamic>>> getAllCycleStartMeetings() async {
    final Database db = await database;
    return await db.query('meeting');
  }

  // Insert a group profile into the 'group_profile' table
  Future<int?> insertGroupProfile(Map<String, dynamic> groupProfile) async {
    final Database db = await database;
    try {
      int insertedRowId = await db.insert('group_profile', groupProfile);
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
      List<Map<String, dynamic>> groupProfiles =
          await db.query('group_profile');
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

  Future<List<Map<String, dynamic>>> searchUserByUniqueCode(
      String uniqueCode) async {
    final Database db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'unique_code = ?',
      whereArgs: [uniqueCode],
    );
    return results;
  }

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
