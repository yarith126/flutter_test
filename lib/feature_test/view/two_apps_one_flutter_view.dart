import 'package:flutter/material.dart';
import 'package:flutter_demo/feature_test/view/my_material_app_two.dart';
import 'package:hive/hive.dart';

class TwoAppsOneFlutterView extends StatefulWidget {
  const TwoAppsOneFlutterView({super.key});

  @override
  State<TwoAppsOneFlutterView> createState() => _TwoAppsOneFlutterViewState();
}

class _TwoAppsOneFlutterViewState extends State<TwoAppsOneFlutterView> {
  final _cntKey = TextEditingController();
  final _cntValue = TextEditingController();
  final _boxData = Hive.box('data');
  String hiveData = '';

  @override
  void initState() {
    super.initState();
    hiveData = _boxData.toMap().toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('App 1')),
        body: Stack(
          children: [
            SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Key:  '),
                      SizedBox(
                        width: 100,
                        child: TextField(controller: _cntKey),
                      ),
                      const SizedBox(width: 20),
                      const Text('Value:  '),
                      SizedBox(
                        width: 100,
                        child: TextField(controller: _cntValue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      _boxData.put(_cntKey.text, _cntValue.text);
                      setState(() {
                        _cntKey.text = '';
                        _cntValue.text = '';
                        hiveData = _boxData.toMap().toString();
                      });
                    },
                    child: const Text('Save to Hive'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _boxData.clear();
                      });
                    },
                    child: const Text('Clear Hive data'),
                  ),
                  const SizedBox(height: 20),
                  const Text('Hive data:'),
                  Text(hiveData),
                ],
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyMaterialAppTwo(),
                          ));
                      // runApp(const MyMaterialAppTwo());
                    },
                    child: const Text('Launch runApp(MyApp2());'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
