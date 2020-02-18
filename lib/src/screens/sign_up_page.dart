import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bundang/src/models/sign_in_model.dart';
import 'package:flutter_bundang/src/screens/home_page.dart';
import 'package:flutter_bundang/src/screens/landing_page.dart';
import 'package:flutter_bundang/src/screens/login_page.dart';
import 'package:flutter_bundang/src/services/auth.dart';
import 'package:flutter_bundang/src/widgets/custom_button_widget.dart';
import 'package:flutter_bundang/src/widgets/custom_form_widget.dart';
import 'package:flutter_bundang/src/widgets/custom_text_widget.dart';
import 'package:flutter_bundang/src/widgets/platform_exception_alert_dialog.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  final SignInModel model;

  SignUpPage({@required this.model});

  static Widget create(BuildContext context) {
    final AuthBase auth = Provider.of<AuthFromCustom>(context, listen: false);
    return ChangeNotifierProvider<SignInModel>(
      create: (context) => SignInModel(
        auth: auth,
      ),
      child: Consumer<SignInModel>(
        builder: (context, model, _) => SignUpPage(
          model: model,
        ),
      ),
    );
  }

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with CustomFormFieldWidget {
  // DateTime _selectedDate;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();

  SignInModel get model => widget.model;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                HeadingOneText(
                  title: 'Awesome App',
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: 80.0,
                      ),
                      child: emailInputField(context, emailController, model),
                    ),
                    wrapInputField(
                      passwordInputField(context, passwordController, model),
                    ),
                    // wrapInputField(
                    //   passwordInputField(context),
                    // ),
                    wrapInputField(
                      birthdayInputField(
                        model: model,
                        context: context,
                        controller: birthdayController,
                        onClick: _onClickInputField,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Transform.scale(
                        scale: 1.06,
                        child: checkBoxField(
                          context: context,
                          ifChecked: model.isChecked,
                          onChecked: model.changeCheckBoxValue,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: CustomButtonWidget(
                    onSubmit: model.isChecked ? _submitWithCustom : null,
                    backgroundColor: Colors.teal,
                    title: 'SIGN UP',
                  ),
                ),
                wrapInputField(
                  CustomMaterialButton(
                    title: 'Already have account? Sign in',
                    onSubmit: _pushToLogin,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onClickInputField() {
    FocusScope.of(context).requestFocus(FocusNode());
    selectDate(context).then((onValue) {
      if (onValue != null) {
        birthdayController.text = DateFormat('yMMd', 'ko').format(onValue);
        model.updateBirthday(birthdayController.text);
      }
    });
  }

  void _pushToLogin() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage.create(context),
        ));
  }

  Future<void> _submitWithFirebase() async {
    try {
      await model.auth.createUserWithEmail(model.email, model.password);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => LandingPage(),
      ));
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: '에러!',
        e: e,
        defaultActionText: '확인',
      ).show(context);
    }
  }

  Future<void> _submitWithCustom() async {
    try {
      await model.auth.createUserWithEmail(model.email, model.password,
          birthday: model.birthday);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => HomePage(),
      ));
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    birthdayController.dispose();
    super.dispose();
  }
}
