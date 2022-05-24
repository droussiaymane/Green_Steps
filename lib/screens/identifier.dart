import 'package:app/models/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';

class Identifier extends StatelessWidget {
  Identifier({Key? key}) : super(key: key);
  
  static MaterialPage page() {
  return MaterialPage(
      name: "/identifier",
      key: const ValueKey("/identifier"),
      child: Identifier(),
  );
}
  final _emailController = TextEditingController();
  // 2
  final _passwordController = TextEditingController();
  // 3
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final appStateManager = Provider.of<AppStateManager>(context, listen: false);
    final user = Provider.of<User>(context);
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 16,
              ),
              Image.asset(
                'assets/icons/um6p.png',
                scale: 10,
              ),
              const Spacer(
                flex: 2,
              ),
              Container(
                width: 250,
                height: 50,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    // ignore: prefer_const_constructors
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextFormField(
                        
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          contentPadding:  EdgeInsets.symmetric( vertical: 0),
                          hintText: 'Adresse mail',
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false,
                        controller: _emailController,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "L'email est obligatoire";
                          }
                          bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                          if (!emailValid){
                            return "L'email n'est pas valide";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              MyTextField(
                hint: 'Mot de passe',
                obscureText: true,
                controller: _passwordController,
              ),
              const Spacer(
                flex: 2,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: kPrimaryColor,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    user.email = _emailController.text;
                    appStateManager.setIndex(0);
                  }
                },
                child: const Text("S'identifier"),
              ),
              const Spacer(
                flex: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}







/////////////custom class
////need some work when linking to um6p database
class MyTextField extends StatefulWidget {
  TextEditingController? controller;
  TextInputType? keyboardType;
  bool obscureText;
  String hint;
  MyTextField({
    this.controller,
    this.keyboardType,
    required this.hint,
    this.obscureText = false,
    Key? key,
  }) : super(key: key);

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 50,
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                contentPadding:  const EdgeInsets.symmetric( vertical: 0),
                hintText: widget.hint,
                border: InputBorder.none,
              ),
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              controller: widget.controller,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Le mot de passe est obligatoire';
                }
                return null;
              },
            ),
          ),
          widget.obscureText
              ? IconButton(
                  splashRadius: 25,
                  onPressed: () {
                    widget.obscureText = false;
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .color!
                        .withOpacity(0.64),
                  ),
                )
              : IconButton(
                  splashRadius: 25,
                  onPressed: () {
                    widget.obscureText = true;
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.remove_red_eye_outlined,
                    color: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .color!
                        .withOpacity(0.64),
                  ),
                ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}



