import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// --- CONFIGURATION ---
// Set this to 'false' to test with your local Django server
// Set this to 'true' when you are building the APK or using the live server
const bool isProduction = true; 

const String baseUrl = isProduction 
    ? "https://roti-ledger.onrender.com" 
    : "http://127.0.0.1:8000";

void main() {
  runApp(const ProviderScope(child: RotiApp()));
}

class RotiApp extends StatelessWidget {
  const RotiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Roti Ledger',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api-token-auth/'),
        body: {
          'username': _usernameController.text,
          'password': _passwordController.text,
        }
      );
      
      if (response.statusCode == 200) {
        final token = json.decode(response.body)['token'];
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen(token: token)),
          );
        }
      } else {
        throw Exception("Invalid Username or Password");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.indigo.shade900, Colors.indigo.shade500],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 12,
              shadowColor: Colors.black45,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.bakery_dining, size: 64, color: Colors.indigo.shade700),
                    ),
                    const SizedBox(height: 24),
                    Text("Secure Ledger", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigo.shade900)),
                    const SizedBox(height: 48),
                    TextField(controller: _usernameController, decoration: InputDecoration(labelText: "Username", prefixIcon: const Icon(Icons.person_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50)),
                    const SizedBox(height: 16),
                    TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: "Password", prefixIcon: const Icon(Icons.lock_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50)),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : const Text("Sign In", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final String token; 
  const DashboardScreen({super.key, required this.token});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    'Authorization': 'Token ${widget.token}',
  };

  Future<List<dynamic>> _fetchCustomers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/customers/'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Session Expired or Unauthorized');
    }
  }

  // ... [Existing _showAddCustomerDialog, _showAddDeliveryDialog, _showReceivePaymentDialog remain unchanged]
  
  // Note: I am assuming the logic inside those dialogs follows the same pattern. 
  // Ensure you update the Uri.parse calls inside your dialog functions to use '$baseUrl/...' as well!

  @override
  Widget build(BuildContext context) {
    // ... [Build method logic remains the same, Ensure you call _fetchCustomers]
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Dashboard'),),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchCustomers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No customers found.'));
          
          final customers = snapshot.data!;
          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return ListTile(
                title: Text(customer['name']),
                trailing: Text('₹${customer['outstanding_balance']}'),
                onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerHistoryScreen(customer: customer as Map<String, dynamic>, token: widget.token),
                      ),
                    ).then((_) => setState(() {})); 
                  },
              );
            },
          );
        },
      ),
    );
  }
}

class CustomerHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> customer;
  final String token;
  const CustomerHistoryScreen({super.key, required this.customer, required this.token});
  @override
  State<CustomerHistoryScreen> createState() => _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState extends State<CustomerHistoryScreen> {
  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    'Authorization': 'Token ${widget.token}',
  };

  Future<List<Map<String, dynamic>>> _fetchHistory() async {
    final customerId = widget.customer['id'];
    final ordersResponse = await http.get(Uri.parse('$baseUrl/api/orders/?customer=$customerId'), headers: _authHeaders);
    final paymentsResponse = await http.get(Uri.parse('$baseUrl/api/payments/?customer=$customerId'), headers: _authHeaders);
    // ... rest of history logic
    return [];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('${widget.customer['name']}\'s History')), body: Container());
  }
}