import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../../../core/errors/exceptions.dart' as app_exceptions;
import '../../../core/utils/logger.dart';

/// SQLite database helper with singleton pattern
/// Manages database creation, migrations, and connections
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static sqflite.Database? _database;

  // Database configuration
  static const String _databaseName = 'dualify_dashboard.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String tableProfiles = 'profiles';
  static const String tableDailyLogs = 'daily_logs';
  static const String tableQuestions = 'questions';

  // Singleton pattern
  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  /// Gets the database instance, creating it if necessary
  Future<sqflite.Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initializes the database
  Future<sqflite.Database> _initDatabase() async {
    try {
      AppLogger.info('Initializing database...');

      // Get the database path
      final databasesPath = await sqflite.getDatabasesPath();
      final path = join(databasesPath, _databaseName);

      AppLogger.debug('Database path: $path');

      // Open/create the database
      final database = await sqflite.openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: _onDowngrade,
        onOpen: _onOpen,
      );

      AppLogger.info('Database initialized successfully');
      return database;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize database', e, stackTrace);
      throw app_exceptions.DatabaseException(
        'Database initialization failed',
        code: 'DB_004',
        originalError: e,
      );
    }
  }

  /// Creates the database schema
  Future<void> _onCreate(sqflite.Database db, int version) async {
    try {
      AppLogger.info('Creating database schema version $version...');

      await db.transaction((txn) async {
        // Create profiles table
        await txn.execute('''
          CREATE TABLE $tableProfiles (
            id TEXT PRIMARY KEY,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
            trade TEXT NOT NULL,
            apprenticeship_start_date INTEGER NOT NULL,
            apprenticeship_end_date INTEGER NOT NULL,
            company_name TEXT,
            school_name TEXT,
            email TEXT,
            phone TEXT,
            is_company_verified INTEGER NOT NULL DEFAULT 0,
            is_school_verified INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            CONSTRAINT chk_dates CHECK (apprenticeship_end_date > apprenticeship_start_date),
            CONSTRAINT chk_email CHECK (email IS NULL OR email LIKE '%@%.%')
          )
        ''');

        // Create daily logs table
        await txn.execute('''
          CREATE TABLE $tableDailyLogs (
            id TEXT PRIMARY KEY,
            profile_id TEXT NOT NULL,
            date INTEGER NOT NULL,
            status TEXT NOT NULL,
            notes TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            FOREIGN KEY (profile_id) REFERENCES $tableProfiles (id) ON DELETE CASCADE,
            CONSTRAINT chk_status CHECK (status IN ('learning', 'challenging', 'neutral', 'good')),
            CONSTRAINT chk_notes_length CHECK (notes IS NULL OR LENGTH(notes) <= 500)
          )
        ''');

        // Create questions table
        await txn.execute('''
          CREATE TABLE $tableQuestions (
            id TEXT PRIMARY KEY,
            question TEXT NOT NULL,
            category TEXT NOT NULL,
            response TEXT,
            response_date INTEGER,
            created_at INTEGER NOT NULL,
            CONSTRAINT chk_category CHECK (category IN ('learning', 'problem-solving', 'achievement', 'reflection', 'skills', 'teamwork', 'safety', 'goals')),
            CONSTRAINT chk_response CHECK (response IS NULL OR LENGTH(response) >= 10),
            CONSTRAINT chk_response_date CHECK ((response IS NULL AND response_date IS NULL) OR (response IS NOT NULL AND response_date IS NOT NULL))
          )
        ''');

        // Create indexes for better performance
        await txn.execute(
          'CREATE INDEX idx_daily_logs_profile_date ON $tableDailyLogs (profile_id, date)',
        );
        await txn.execute(
          'CREATE INDEX idx_daily_logs_date ON $tableDailyLogs (date)',
        );
        await txn.execute(
          'CREATE INDEX idx_questions_category ON $tableQuestions (category)',
        );
        await txn.execute(
          'CREATE INDEX idx_questions_response_date ON $tableQuestions (response_date)',
        );

        // Create unique constraints
        await txn.execute(
          'CREATE UNIQUE INDEX idx_daily_logs_profile_date_unique ON $tableDailyLogs (profile_id, date)',
        );
      });

      AppLogger.info('Database schema created successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create database schema', e, stackTrace);
      throw app_exceptions.DatabaseException(
        'Schema creation failed for version $version',
        code: 'DB_004',
        originalError: e,
      );
    }
  }

  /// Handles database upgrades
  Future<void> _onUpgrade(
    sqflite.Database db,
    int oldVersion,
    int newVersion,
  ) async {
    try {
      AppLogger.info(
        'Upgrading database from version $oldVersion to $newVersion...',
      );

      // Handle future migrations here
      for (int version = oldVersion + 1; version <= newVersion; version++) {
        await _migrateToVersion(db, version);
      }

      AppLogger.info('Database upgrade completed successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to upgrade database', e, stackTrace);
      throw app_exceptions.DatabaseException.migrationFailed(
        'Database upgrade failed from $oldVersion to $newVersion',
        e,
      );
    }
  }

  /// Handles database downgrades
  Future<void> _onDowngrade(
    sqflite.Database db,
    int oldVersion,
    int newVersion,
  ) async {
    try {
      AppLogger.warning(
        'Downgrading database from version $oldVersion to $newVersion',
      );

      // For now, we'll recreate the database on downgrade
      await _recreateDatabase(db);

      AppLogger.info('Database downgrade completed');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to downgrade database', e, stackTrace);
      throw app_exceptions.DatabaseException.migrationFailed(
        'Database downgrade failed from $oldVersion to $newVersion',
        e,
      );
    }
  }

  /// Called when database is opened
  Future<void> _onOpen(sqflite.Database db) async {
    try {
      AppLogger.debug('Database opened successfully');

      // Enable foreign key constraints
      await db.execute('PRAGMA foreign_keys = ON');

      // Try to set WAL mode, but don't fail if it doesn't work
      try {
        await db.rawQuery('PRAGMA journal_mode = WAL');
        AppLogger.debug('WAL mode enabled');
      } catch (e) {
        AppLogger.warning('Could not enable WAL mode, using default: $e');
      }

      // Set synchronous mode to NORMAL for better performance
      await db.execute('PRAGMA synchronous = NORMAL');

      AppLogger.debug('Database pragmas configured');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to configure database on open', e, stackTrace);
      // Don't throw here as this is not critical
    }
  }

  /// Migrates database to a specific version
  Future<void> _migrateToVersion(sqflite.Database db, int version) async {
    switch (version) {
      case 1:
        // Initial version - no migration needed
        break;
      // Add future migration cases here
      default:
        throw app_exceptions.DatabaseException.migrationFailed(
          'Unknown migration version: $version',
        );
    }
  }

  /// Recreates the database (drops all tables and recreates them)
  Future<void> _recreateDatabase(sqflite.Database db) async {
    await db.transaction((txn) async {
      // Drop all tables
      await txn.execute('DROP TABLE IF EXISTS $tableQuestions');
      await txn.execute('DROP TABLE IF EXISTS $tableDailyLogs');
      await txn.execute('DROP TABLE IF EXISTS $tableProfiles');

      // Recreate schema
      await _onCreate(db, _databaseVersion);
    });
  }

  /// Executes a query with error handling
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await database;
      return await db.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Query failed on table $table', e, stackTrace);
      throw app_exceptions.DatabaseException.queryFailed(
        'SELECT * FROM $table WHERE $where',
        e,
      );
    }
  }

  /// Inserts a record with error handling
  Future<int> insert(String table, Map<String, dynamic> values) async {
    try {
      final db = await database;
      return await db.insert(table, values);
    } catch (e, stackTrace) {
      AppLogger.error('Insert failed on table $table', e, stackTrace);

      if (e.toString().contains('UNIQUE constraint failed')) {
        throw app_exceptions.DatabaseException.constraintViolation(
          'Unique constraint violation on $table',
          e,
        );
      } else if (e.toString().contains('FOREIGN KEY constraint failed')) {
        throw app_exceptions.DatabaseException.constraintViolation(
          'Foreign key constraint violation on $table',
          e,
        );
      } else if (e.toString().contains('CHECK constraint failed')) {
        throw app_exceptions.DatabaseException.constraintViolation(
          'Check constraint violation on $table',
          e,
        );
      }

      throw app_exceptions.DatabaseException.queryFailed(
        'INSERT INTO $table',
        e,
      );
    }
  }

  /// Updates records with error handling
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final db = await database;
      return await db.update(table, values, where: where, whereArgs: whereArgs);
    } catch (e, stackTrace) {
      AppLogger.error('Update failed on table $table', e, stackTrace);

      if (e.toString().contains('UNIQUE constraint failed')) {
        throw app_exceptions.DatabaseException.constraintViolation(
          'Unique constraint violation on $table',
          e,
        );
      } else if (e.toString().contains('CHECK constraint failed')) {
        throw app_exceptions.DatabaseException.constraintViolation(
          'Check constraint violation on $table',
          e,
        );
      }

      throw app_exceptions.DatabaseException.queryFailed(
        'UPDATE $table SET ... WHERE $where',
        e,
      );
    }
  }

  /// Deletes records with error handling
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final db = await database;
      return await db.delete(table, where: where, whereArgs: whereArgs);
    } catch (e, stackTrace) {
      AppLogger.error('Delete failed on table $table', e, stackTrace);
      throw app_exceptions.DatabaseException.queryFailed(
        'DELETE FROM $table WHERE $where',
        e,
      );
    }
  }

  /// Executes raw SQL with error handling
  Future<void> execute(String sql, [List<dynamic>? arguments]) async {
    try {
      final db = await database;
      await db.execute(sql, arguments);
    } catch (e, stackTrace) {
      AppLogger.error('Execute failed for SQL: $sql', e, stackTrace);
      throw app_exceptions.DatabaseException.queryFailed(sql, e);
    }
  }

  /// Executes multiple operations in a transaction
  Future<T> transaction<T>(
    Future<T> Function(sqflite.Transaction txn) action,
  ) async {
    try {
      final db = await database;
      return await db.transaction(action);
    } catch (e, stackTrace) {
      AppLogger.error('Transaction failed', e, stackTrace);
      throw app_exceptions.DatabaseException(
        'Transaction execution failed',
        code: 'DB_006',
        originalError: e,
      );
    }
  }

  /// Gets database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final db = await database;

      // Get table counts
      final profileCount =
          sqflite.Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $tableProfiles'),
          ) ??
          0;

      final dailyLogCount =
          sqflite.Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $tableDailyLogs'),
          ) ??
          0;

      final questionCount =
          sqflite.Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $tableQuestions'),
          ) ??
          0;

      // Get database size
      final dbPath = db.path;
      final dbFile = File(dbPath);
      final dbSize = await dbFile.exists() ? await dbFile.length() : 0;

      return {
        'profileCount': profileCount,
        'dailyLogCount': dailyLogCount,
        'questionCount': questionCount,
        'databaseSize': dbSize,
        'databasePath': dbPath,
        'version': _databaseVersion,
      };
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get database statistics', e, stackTrace);
      throw app_exceptions.DatabaseException.queryFailed(
        'Database statistics query',
        e,
      );
    }
  }

  /// Closes the database connection
  Future<void> close() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
        AppLogger.info('Database connection closed');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to close database', e, stackTrace);
      throw app_exceptions.DatabaseException(
        'Failed to close database connection',
        originalError: e,
      );
    }
  }

  /// Deletes the database file (for testing or reset)
  Future<void> deleteDatabase() async {
    try {
      await close();

      final databasesPath = await sqflite.getDatabasesPath();
      final path = join(databasesPath, _databaseName);

      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        AppLogger.info('Database file deleted: $path');
      }

      _instance = null;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete database', e, stackTrace);
      throw app_exceptions.DatabaseException(
        'Failed to delete database file',
        originalError: e,
      );
    }
  }
}
