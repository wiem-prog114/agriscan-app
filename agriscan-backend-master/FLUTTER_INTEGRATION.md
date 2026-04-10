# Flutter Backend Integration Guide

**Simple Setup for Android Emulator Development**

---

## Getting Started

### Step 1: Run Your Backend
```bash
python manage.py runserver 0.0.0.0:8000
```

### Step 2: Important - Use Correct URL for Emulator
The Android emulator accesses your host machine using `10.0.2.2` instead of `localhost`.

So your API base URL should be: **`http://10.0.2.2:8000/api`**

---

## Add Dependencies

In your Flutter project's `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.0
```

Run: `flutter pub get`

---

## Simple API Service

Create `lib/services/api.dart`:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  static const baseUrl = 'http://10.0.2.2:8000/api';

  // Sign up (sends OTP to email)
  static Future<Map> signup(String fullName, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
        'confirm_password': password,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Signup failed');
  }

  // Verify OTP (completes signup)
  static Future<Map> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access']);
      return data;
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'OTP verification failed');
  }

  // Login
  static Future<Map> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access']);
      return data;
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Login failed');
  }

  // Resend OTP
  static Future<Map> resendOtp(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/resend-otp/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Resend failed');
  }

  // Get saved token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Make authenticated request
  static Future<http.Response> getWithAuth(String endpoint) async {
    final token = await getToken();
    return http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }
}
```

---

## API Endpoints Reference

---

### 1. Sign Up
**POST** `/auth/signup/`

Request:
```json
{
  "full_name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "confirm_password": "password123"
}
```

Response:
```json
{
  "message": "OTP sent to your email",
  "email": "john@example.com"
}
```

---

### 2. Verify OTP
**POST** `/auth/verify-otp/`

Request:
```json
{
  "email": "john@example.com",
  "otp": "123456"
}
```

Response:
```json
{
  "access": "eyJ0eXAi...",
  "refresh": "eyJ0eXAi..."
}
```

---

### 3. Login
**POST** `/auth/login/`

Request:
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

Response:
```json
{
  "access": "eyJ0eXAi...",
  "refresh": "eyJ0eXAi..."
}
```

---

### 4. Resend OTP
**POST** `/auth/resend-otp/`

Request:
```json
{
  "email": "john@example.com"
}
```

Response:
```json
{
  "message": "OTP resent to your email"
}
```

---

## Example: Simple Login Screen

```dart
import 'package:flutter/material.dart';
import 'services/api.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLoading = false;
  String? error;

  void login() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      await Api.login(emailCtrl.text, passCtrl.text);
      // Navigate to home page
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() => error = e.toString());
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(hintText: 'Email'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: InputDecoration(hintText: 'Password'),
            ),
            SizedBox(height: 20),
            if (error != null)
              Text(error!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : login,
              child: isLoading
                  ? CircularProgressIndicator()
                  : Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Troubleshooting

**Can't reach backend from emulator?**
- Make sure backend is running: `python manage.py runserver 0.0.0.0:8000`
- Use `http://10.0.2.2:8000/api` (not localhost or 127.0.0.1)
- Check Windows firewall isn't blocking port 8000

**Getting "Connection refused"?**
- Verify backend is actually running
- Check your backend IP isn't restricted to localhost

**OTP not arriving?**
- Check your email settings in `backend/settings.py`
- OTP defaults sent via console (check terminal output)

**Token issues?**
- Tokens automatically expire - users need to login again
- Token is saved to `shared_preferences` after login
