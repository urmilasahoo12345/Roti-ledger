import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      // 1. Send actual credentials to the new Django Token endpoint
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api-token-auth/'),
        body: {
          'username': _usernameController.text,
          'password': _passwordController.text,
        }
      );
      
      if (response.statusCode == 200) {
        // 2. Extract the secure token from the response
        final token = json.decode(response.body)['token'];
        
        if (mounted) {
          // 3. Pass the token to the Dashboard securely!
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
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    Text(
                      "Secure Ledger", 
                      style: TextStyle(
                        fontSize: 32, 
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: "Username", 
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password", 
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
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
  final String token; // NEW: The Dashboard now holds the secure token

  const DashboardScreen({super.key, required this.token});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  // Helper method to easily get our secure headers
  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    'Authorization': 'Token ${widget.token}', // <--- This proves we are logged in!
  };

  Future<List<dynamic>> _fetchCustomers() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/customers/'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Session Expired or Unauthorized');
    }
  }

  Future<void> _showAddCustomerDialog() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Add New Customer', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Customer Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Price per Roti (₹)',
                      prefixIcon: const Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey.shade700)),
                ),
                FilledButton(
                  onPressed: isSaving ? null : () async {
                    if (nameController.text.isEmpty || priceController.text.isEmpty) return;
                    final price = double.tryParse(priceController.text);
                    if (price == null) return;

                    setDialogState(() => isSaving = true);

                    try {
                      final response = await http.post(
                        Uri.parse('http://127.0.0.1:8000/api/customers/'),
                        headers: _authHeaders, // Secure Header
                        body: json.encode({
                          "name": nameController.text,
                          "custom_price_per_roti": price,
                        }),
                      );

                      if (response.statusCode == 201) {
                        if (context.mounted) Navigator.pop(context, true);
                      } else {
                        throw Exception('Server error ${response.statusCode}: ${response.body}');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(e.toString().replaceAll('Exception: ', '')),
                          backgroundColor: Colors.red.shade800,
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                      setDialogState(() => isSaving = false);
                    }
                  },
                  child: isSaving 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Customer'),
                ),
              ],
            );
          }
        );
      }
    ).then((wasSaved) {
      if (wasSaved == true) setState(() {}); 
    });
  }

  Future<void> _showAddDeliveryDialog(Map<String, dynamic> customer) async {
    final quantityController = TextEditingController();
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Deliver to ${customer['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Text("Rate: ₹${customer['custom_price_per_roti']} / roti", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Total Rotis Delivered',
                      prefixIcon: const Icon(Icons.bakery_dining),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey.shade700)),
                ),
                FilledButton(
                  onPressed: isSaving ? null : () async {
                    final quantity = int.tryParse(quantityController.text);
                    if (quantity == null || quantity <= 0) return;

                    setDialogState(() => isSaving = true);
                    final today = DateTime.now();
                    final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
                    final timeStr = "${today.toIso8601String()}Z";

                    try {
                      final response = await http.post(
                        Uri.parse('http://127.0.0.1:8000/api/orders/'),
                        headers: _authHeaders, // Secure Header
                        body: json.encode({
                          "customer": customer['id'],
                          "date": dateStr,
                          "created_at": timeStr,
                          "quantity": quantity,
                          "status": "DELIVERED"
                        }),
                      );

                      if (response.statusCode == 201) {
                        if (context.mounted) Navigator.pop(context, true);
                      } else {
                        throw Exception('Server error ${response.statusCode}: ${response.body}');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(e.toString().replaceAll('Exception: ', '')),
                          backgroundColor: Colors.red.shade800,
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                      setDialogState(() => isSaving = false);
                    }
                  },
                  child: isSaving 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Delivery'),
                ),
              ],
            );
          }
        );
      }
    ).then((wasSaved) {
      if (wasSaved == true) setState(() {}); 
    });
  }

  Future<void> _showReceivePaymentDialog(Map<String, dynamic> customer) async {
    final amountController = TextEditingController();
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Receive Cash: ${customer['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_wallet, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Text("Balance: ₹${customer['outstanding_balance']}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount Received (₹)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.currency_rupee),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey.shade700)),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.green.shade600),
                  onPressed: isSaving ? null : () async {
                    final amount = double.tryParse(amountController.text);
                    if (amount == null || amount <= 0) return;

                    setDialogState(() => isSaving = true);
                    final today = DateTime.now();
                    final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
                    final timeStr = "${today.toIso8601String()}Z";

                    try {
                      final response = await http.post(
                        Uri.parse('http://127.0.0.1:8000/api/payments/'),
                        headers: _authHeaders, // Secure Header
                        body: json.encode({
                          "customer": customer['id'],
                          "date": dateStr,
                          "created_at": timeStr,
                          "amount_received": amount
                        }),
                      );

                      if (response.statusCode == 201) {
                        if (context.mounted) Navigator.pop(context, true);
                      } else {
                        throw Exception('Server error ${response.statusCode}: ${response.body}');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(e.toString().replaceAll('Exception: ', '')),
                          backgroundColor: Colors.red.shade800,
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                      setDialogState(() => isSaving = false);
                    }
                  },
                  child: isSaving 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Payment'),
                ),
              ],
            );
          }
        );
      }
    ).then((wasSaved) {
      if (wasSaved == true) setState(() {}); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard', style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // Logout button!
            tooltip: "Log Out",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCustomerDialog,
        elevation: 4,
        icon: const Icon(Icons.person_add),
        label: const Text("New Customer", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchCustomers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No customers found.', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          final customers = snapshot.data!;

          return ListView.builder(
            itemCount: customers.length,
            padding: const EdgeInsets.only(top: 16, bottom: 100, left: 12, right: 12),
            itemBuilder: (context, index) {
              final customer = customers[index];
              final balance = double.parse(customer['outstanding_balance'].toString());

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // Pass the token to the history screen!
                        builder: (context) => CustomerHistoryScreen(customer: customer as Map<String, dynamic>, token: widget.token),
                      ),
                    ).then((_) => setState(() {})); 
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.indigo.shade300, Colors.indigo.shade600],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: Center(
                            child: Text(
                              customer['name'][0].toUpperCase(), 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(customer['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.3)),
                              const SizedBox(height: 4),
                              Text('View full history \u2192', style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("Balance", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            Text(
                              '₹${balance.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: balance > 0 ? Colors.red.shade600 : Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 1,
                          height: 48,
                          color: Colors.grey.shade200,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                              icon: const Icon(Icons.local_shipping),
                              color: Colors.blue.shade600,
                              tooltip: "Add Delivery",
                              onPressed: () => _showAddDeliveryDialog(customer as Map<String, dynamic>),
                            ),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                              icon: const Icon(Icons.payments),
                              color: Colors.green.shade600,
                              tooltip: "Receive Cash",
                              onPressed: () => _showReceivePaymentDialog(customer as Map<String, dynamic>),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
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
  final String token; // NEW: History Screen holds the token

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
    
    // Pass secure headers here
    final ordersResponse = await http.get(Uri.parse('http://127.0.0.1:8000/api/orders/?customer=$customerId'), headers: _authHeaders);
    final paymentsResponse = await http.get(Uri.parse('http://127.0.0.1:8000/api/payments/?customer=$customerId'), headers: _authHeaders);

    if (ordersResponse.statusCode != 200 || paymentsResponse.statusCode != 200) {
      throw Exception('Failed to load history');
    }

    final List<dynamic> orders = json.decode(ordersResponse.body);
    final List<dynamic> payments = json.decode(paymentsResponse.body);

    List<Map<String, dynamic>> combinedHistory = [];

    for (var order in orders) {
      combinedHistory.add({
        'id': order['id'],
        'endpoint': 'orders',
        'type': 'Order',
        'date': order['date'],             
        'created_at': order['created_at'],
        'amount': order['total_cost'],
        'details': '${order['quantity']} rotis',
        'is_positive': false, 
      });
    }

    for (var payment in payments) {
      combinedHistory.add({
        'id': payment['id'],
        'endpoint': 'payments',
        'type': 'Payment',
        'date': payment['date'],
        'created_at': payment['created_at'],
        'amount': payment['amount_received'],
        'details': 'Cash Received',
        'is_positive': true,
      });
    }

    combinedHistory.sort((a, b) {
      DateTime timeA = DateTime.parse(a['created_at'] ?? "${a['date']}T00:00:00.000Z");
      DateTime timeB = DateTime.parse(b['created_at'] ?? "${b['date']}T00:00:00.000Z");
      return timeB.compareTo(timeA); 
    });

    return combinedHistory;
  }

  Future<void> _deleteTransaction(Map<String, dynamic> item) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Record?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to delete this transaction?\n\nThe customer's balance will instantly fix itself."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: Text("Cancel", style: TextStyle(color: Colors.grey.shade700))
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete Forever")
          ),
        ],
      )
    );

    if (confirm == true) {
      final String endpoint = item['endpoint']; 
      final int id = item['id'];

      try {
        final response = await http.delete(
          Uri.parse('http://127.0.0.1:8000/api/$endpoint/$id/'),
          headers: _authHeaders // Secure Header!
        );
        
        if (response.statusCode == 204) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Record deleted and balance updated."), behavior: SnackBarBehavior.floating,)
            );
            setState(() {}); 
          }
        } else {
          throw Exception("Server returned ${response.statusCode}: ${response.body}");
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.customer['name']}\'s History', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No history found.', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                ],
              )
            );
          }

          final history = snapshot.data!;

          return ListView.builder(
            itemCount: history.length,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            itemBuilder: (context, index) {
              final item = history[index];
              final isPositive = item['is_positive'] as bool;
              final amountStr = double.parse(item['amount'].toString()).toStringAsFixed(2);

              String displayDate = item['date'];
              if (item['created_at'] != null) {
                final dt = DateTime.parse(item['created_at']).toLocal();
                final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
                final amPm = dt.hour >= 12 ? 'PM' : 'AM';
                final min = dt.minute.toString().padLeft(2, '0');
                displayDate = "${item['date']} • $hour:$min $amPm";
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPositive ? Colors.green.shade50 : Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPositive ? Icons.payments : Icons.local_shipping,
                      color: isPositive ? Colors.green.shade700 : Colors.blue.shade700,
                    ),
                  ),
                  title: Text(item['details'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(displayDate, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, 
                    children: [
                      Text(
                        isPositive ? '+ ₹$amountStr' : '- ₹$amountStr',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.grey.shade400,
                        splashColor: Colors.red.shade100,
                        tooltip: "Delete this record",
                        onPressed: () => _deleteTransaction(item),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}