import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:multipiai_flutter/screens/chat_screen.dart';
import '../services/supabase_client.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({Key? key}) : super(key: key);

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  // 🔁 Replace with your API endpoint
  // final String loginApi = 'http://127.0.0.1:5000/get-user-agents';

  Future<void> login() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    // 🔹 Fetch agents from Supabase
     final response = await supabase
        .from('agent_phone_scope_map_sam')
        .select()
        .eq('phone_e164', _phoneController.text.trim())
        .eq('Status', 'A'); // <-- NO .execute()

    setState(() => _isLoading = false);

    // 🔹 Check for errors
     if (response == null) {
      showError('No agents found for this number');
      return;
    }
    final data = response as List<dynamic>;
    if (data.isEmpty) {
      showError('No agents found for this number');
      return;
    }

    // 🔹 Convert data to List<Map<String, dynamic>>
    final List<Map<String, dynamic>> agents =
        data.map((item) => Map<String, dynamic>.from(item)).toList();

    // 🔹 Navigate to ChatScreen
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ChatScreen(initialData: agents),
      ),
    );
  } catch (e) {
    setState(() => _isLoading = false);
    showError('Something went wrong: $e');
  }
}

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),

                      /// Logo
                      Center(
                        child: Image.asset(
                          'assets/images/MultiplAI_Logo_single.png',
                          width: 92,
                          height: 92,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Welcome back',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w700),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Please enter your details.',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),

                      const SizedBox(height: 28),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            /// Mobile Number
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: 'Mobile number',
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                final phone = value?.trim() ?? '';
                                if (phone.isEmpty)
                                  return 'Phone number required';
                                if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
                                  return 'Enter valid 10-digit number';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            /// Remember Me
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v ?? false),
                                ),
                                const Text('Remember me'),
                              ],
                            ),

                            const SizedBox(height: 16),

                            /// Sign In Button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28)),
                                ),
                                onPressed: _isLoading ? null : login,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Sign in',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// 🔹 Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Powered by © 2026 MultiPiAI',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
