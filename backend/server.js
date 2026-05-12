const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const sqlite3 = require('sqlite3').verbose();
const { v4: uuidv4 } = require('uuid');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Database setup
const DB_PATH = process.env.DB_PATH || path.join(__dirname, 'data', 'smart_locker.db');
const db = new sqlite3.Database(DB_PATH, (err) => {
  if (err) {
    console.error('Error opening database:', err.message);
  } else {
    console.log('✅ Connected to SQLite database');
    initDatabase();
  }
});

function initDatabase() {
  db.serialize(() => {
    // Lockers table
    db.run(`CREATE TABLE IF NOT EXISTS lockers (
      id TEXT PRIMARY KEY,
      locker_number TEXT NOT NULL UNIQUE,
      status TEXT DEFAULT 'available',
      size TEXT DEFAULT 'medium',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);

    // Packages table (Send/Receive)
    db.run(`CREATE TABLE IF NOT EXISTS packages (
      id TEXT PRIMARY KEY,
      sender_name TEXT NOT NULL,
      sender_dob TEXT NOT NULL,
      sender_phone TEXT NOT NULL,
      receiver_name TEXT,
      receiver_phone TEXT,
      locker_id TEXT,
      locker_number TEXT,
      pin_code TEXT NOT NULL,
      status TEXT DEFAULT 'stored',
      description TEXT,
      weight REAL,
      sent_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      received_at DATETIME,
      FOREIGN KEY (locker_id) REFERENCES lockers(id)
    )`);

    // Activity logs
    db.run(`CREATE TABLE IF NOT EXISTS activity_logs (
      id TEXT PRIMARY KEY,
      package_id TEXT,
      action TEXT NOT NULL,
      actor_name TEXT,
      actor_phone TEXT,
      timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
      notes TEXT
    )`);

    // Seed lockers if empty
    db.get('SELECT COUNT(*) as count FROM lockers', (err, row) => {
      if (!err && row.count === 0) {
        const sizes = ['small', 'medium', 'large'];
        for (let i = 1; i <= 12; i++) {
          db.run(
            'INSERT INTO lockers (id, locker_number, status, size) VALUES (?, ?, ?, ?)',
            [uuidv4(), `L${String(i).padStart(2, '0')}`, 'available', sizes[i % 3]]
          );
        }
        console.log('✅ Seeded 12 lockers');
      }
    });
  });
}

// ==================== LOCKER ROUTES ====================

// Get all lockers
app.get('/api/lockers', (req, res) => {
  db.all('SELECT * FROM lockers ORDER BY locker_number', (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ success: true, data: rows });
  });
});

// Get available lockers
app.get('/api/lockers/available', (req, res) => {
  db.all('SELECT * FROM lockers WHERE status = "available" ORDER BY locker_number', (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ success: true, data: rows });
  });
});

// ==================== PACKAGE ROUTES ====================

// Send a package (Gửi hàng)
app.post('/api/packages/send', (req, res) => {
  const { sender_name, sender_dob, sender_phone, receiver_name, receiver_phone, description, weight } = req.body;

  if (!sender_name || !sender_dob || !sender_phone) {
    return res.status(400).json({ error: 'Vui lòng điền đầy đủ thông tin người gửi' });
  }

  // Find available locker
  db.get('SELECT * FROM lockers WHERE status = "available" ORDER BY RANDOM() LIMIT 1', (err, locker) => {
    if (err) return res.status(500).json({ error: err.message });
    if (!locker) return res.status(400).json({ error: 'Không còn ô tủ trống' });

    const packageId = uuidv4();
    const pinCode = Math.floor(1000 + Math.random() * 9000).toString();

    db.run(
      `INSERT INTO packages (id, sender_name, sender_dob, sender_phone, receiver_name, receiver_phone, locker_id, locker_number, pin_code, description, weight)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [packageId, sender_name, sender_dob, sender_phone, receiver_name || '', receiver_phone || '', locker.id, locker.locker_number, pinCode, description || '', weight || 0],
      function(err) {
        if (err) return res.status(500).json({ error: err.message });

        // Update locker status
        db.run('UPDATE lockers SET status = "occupied" WHERE id = ?', [locker.id]);

        // Log activity
        db.run(
          'INSERT INTO activity_logs (id, package_id, action, actor_name, actor_phone) VALUES (?, ?, ?, ?, ?)',
          [uuidv4(), packageId, 'SENT', sender_name, sender_phone]
        );

        res.json({
          success: true,
          message: 'Gửi hàng thành công!',
          data: {
            package_id: packageId,
            locker_number: locker.locker_number,
            pin_code: pinCode,
            sender_name,
            sender_phone
          }
        });
      }
    );
  });
});

// Receive a package (Lấy hàng)
app.post('/api/packages/receive', (req, res) => {
  const { locker_number, pin_code, receiver_phone } = req.body;

  if (!locker_number || !pin_code) {
    return res.status(400).json({ error: 'Vui lòng nhập số ô tủ và mã PIN' });
  }

  db.get(
    'SELECT * FROM packages WHERE locker_number = ? AND pin_code = ? AND status = "stored"',
    [locker_number, pin_code],
    (err, pkg) => {
      if (err) return res.status(500).json({ error: err.message });
      if (!pkg) return res.status(404).json({ error: 'Không tìm thấy gói hàng. Kiểm tra lại số ô và mã PIN' });

      // Update package status
      db.run(
        'UPDATE packages SET status = "received", received_at = CURRENT_TIMESTAMP WHERE id = ?',
        [pkg.id]
      );

      // Free locker
      db.run('UPDATE lockers SET status = "available" WHERE id = ?', [pkg.locker_id]);

      // Log activity
      db.run(
        'INSERT INTO activity_logs (id, package_id, action, actor_name, actor_phone) VALUES (?, ?, ?, ?, ?)',
        [uuidv4(), pkg.id, 'RECEIVED', pkg.receiver_name || pkg.sender_name, receiver_phone || pkg.receiver_phone]
      );

      res.json({
        success: true,
        message: 'Lấy hàng thành công!',
        data: {
          package_id: pkg.id,
          sender_name: pkg.sender_name,
          sender_phone: pkg.sender_phone,
          locker_number: pkg.locker_number,
          sent_at: pkg.sent_at
        }
      });
    }
  );
});

// Get all packages (for management)
app.get('/api/packages', (req, res) => {
  const { status, phone } = req.query;
  let query = 'SELECT * FROM packages WHERE 1=1';
  const params = [];

  if (status) { query += ' AND status = ?'; params.push(status); }
  if (phone) { query += ' AND (sender_phone = ? OR receiver_phone = ?)'; params.push(phone, phone); }

  query += ' ORDER BY sent_at DESC';

  db.all(query, params, (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ success: true, data: rows });
  });
});

// Get package by ID
app.get('/api/packages/:id', (req, res) => {
  db.get('SELECT * FROM packages WHERE id = ?', [req.params.id], (err, row) => {
    if (err) return res.status(500).json({ error: err.message });
    if (!row) return res.status(404).json({ error: 'Không tìm thấy gói hàng' });
    res.json({ success: true, data: row });
  });
});

// Get activity logs
app.get('/api/logs', (req, res) => {
  db.all(
    'SELECT * FROM activity_logs ORDER BY timestamp DESC LIMIT 100',
    (err, rows) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ success: true, data: rows });
    }
  );
});

// Stats dashboard
app.get('/api/stats', (req, res) => {
  db.serialize(() => {
    const stats = {};
    db.get('SELECT COUNT(*) as total FROM lockers', (err, r) => { stats.total_lockers = r?.total || 0; });
    db.get('SELECT COUNT(*) as available FROM lockers WHERE status="available"', (err, r) => { stats.available_lockers = r?.available || 0; });
    db.get('SELECT COUNT(*) as stored FROM packages WHERE status="stored"', (err, r) => { stats.packages_stored = r?.stored || 0; });
    db.get('SELECT COUNT(*) as received FROM packages WHERE status="received"', (err, r) => {
      stats.packages_received = r?.received || 0;
      res.json({ success: true, data: stats });
    });
  });
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Smart Locker API running on port ${PORT}`);
});
