import 'package:KinderConnect/teacher/home/teacherhomecontent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:KinderConnect/widgets/custom_scaffold.dart';
import 'package:KinderConnect/teacher/signup.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  final _formTeacherLoginKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  // Firestore instance
  final CollectionReference teachersRef = FirebaseFirestore.instance.collection('Teachers');

  @override
  void initState() {
    super.initState();
    _loadSavedLoginInfo();
  }

  // Load saved login information if available
  Future<void> _loadSavedLoginInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedUsername = prefs.getString('savedUsername');
    final String? savedPassword = prefs.getString('savedPassword');
    if (savedUsername != null && savedPassword != null) {
      setState(() {
        _usernameController.text = savedUsername;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  // Function to check credentials
  Future<void> _onLogin() async {
    if (_formTeacherLoginKey.currentState!.validate()) {
      try {
        QuerySnapshot query = await teachersRef
            .where('username', isEqualTo: _usernameController.text)
            .where('password', isEqualTo: _passwordController.text)
            .get();

        if (query.docs.isNotEmpty) {
          // If "Remember Me" is checked, save credentials
          if (_rememberMe) {
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('savedUsername', _usernameController.text);
            await prefs.setString('savedPassword', _passwordController.text);
          } else {
            // Clear saved credentials if "Remember Me" is unchecked
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove('savedUsername');
            await prefs.remove('savedPassword');
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const TeacherHomePage(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid Username or Password')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
  flex: 7,
  child: Container(
    padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
    decoration: const BoxDecoration(
      color: Color.fromARGB(255, 98, 204, 112),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(40.0),
        topRight: Radius.circular(40.0),
      ),
    ),
    child: Form(
      key: _formTeacherLoginKey,
      child: ListView(
        children: [
          const Text(
            'Teacher',
            style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Username input
          TextFormField(
            controller: _usernameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Username';
              }
              return null;
            },
            decoration: InputDecoration(
              label: const Text('Username'),
              labelStyle: const TextStyle(color: Colors.white),
              hintText: 'Enter Username',
              hintStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Password input
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            obscuringCharacter: '*',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Password';
              }
              return null;
            },
            decoration: InputDecoration(
              label: const Text('Password'),
              labelStyle: const TextStyle(color: Colors.white),
              hintText: 'Enter Password',
              hintStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Remember Me checkbox
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (bool? value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),
              const Text(
                'Remember Me',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          // Login button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onLogin,
              child: const Text('Log In'),
            ),
          ),
          const SizedBox(height: 30),
          // Sign Up option
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Don\'t have an account?',
                style: TextStyle(color: Colors.black, fontSize: 20.0),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (e) => const TeacherSignUpScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
),

        ],
      ),
    );
  }
}
