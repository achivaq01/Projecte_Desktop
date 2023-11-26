import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Login CrazyDisplay'),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LoginForm(),
        ),
      ),
    );
  }

}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    AppData appData = Provider.of<AppData>(context, listen: false);
    String username = _usernameController.text;
    String password = _passwordController.text;
    final message = {
      'platform':'flutter',
      'type': "login",
      'user': username,
      'password':password,
      'id': appData.userId
    };
    print(message);
    appData.sendAnyJson(message);
    print("ESTOY EN LOGIN");
  }

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CupertinoTextField(
        controller: _usernameController,
        placeholder: 'Username',
        keyboardType: TextInputType.emailAddress,
        padding: EdgeInsets.all(12.0),
        clearButtonMode: OverlayVisibilityMode.editing,
      ),
      SizedBox(height: 16.0),
      CupertinoTextField(
        controller: _passwordController,
        placeholder: 'Password',
        obscureText: true,
        padding: EdgeInsets.all(12.0),
        clearButtonMode: OverlayVisibilityMode.editing,
      ),
      SizedBox(height: 16.0),
      CupertinoButton.filled(
        onPressed: _login,
        child: Text('Login'),
      ),
      // Conditionally add another element based on the boolean variable
      if (appData.showErrorLoginMessage)
        Container(
          height: 40.0, // Adjust the height as needed
          color: CupertinoColors.extraLightBackgroundGray,
          child: Center(
            child: Text(
              'Wrong User or Password, try again',
              style: TextStyle(
                color: CupertinoColors.systemRed, // 
              ),
            ),
          ),
        )

        
    ],
  );
  }
}