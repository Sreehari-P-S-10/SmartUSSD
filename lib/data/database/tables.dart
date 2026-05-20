const String createTransactionsTable = '''
  CREATE TABLE transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    merchant TEXT NOT NULL,
    amount REAL NOT NULL,
    type TEXT NOT NULL,
    timestamp INTEGER NOT NULL,
    reference TEXT,
    ussd_code TEXT,
    icon_key TEXT
  )
''';

const String createContactsTable = '''
  CREATE TABLE contacts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    phone TEXT NOT NULL UNIQUE,
    is_favorite INTEGER DEFAULT 0,
    avatar_path TEXT,
    upi_id TEXT,
    bank TEXT
  )
''';

const String createProfileTable = '''
  CREATE TABLE profile (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    upi_id TEXT,
    bank TEXT,
    avatar_path TEXT,
    is_verified INTEGER DEFAULT 0
  )
''';
