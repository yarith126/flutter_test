import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/resources/app/repo_helper.dart';
import 'package:flutter_demo/resources/helpers/rgb_log_helper.dart';

class ApiResponseView extends StatefulWidget {
  const ApiResponseView({super.key});

  @override
  State<ApiResponseView> createState() => _ApiResponseViewState();
}

class _ApiResponseViewState extends State<ApiResponseView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('completer')),
      body: Column(
        children: [
          TextButton(
            onPressed: () async {
              var future = Dio(BaseOptions(responseType: ResponseType.json))
                  .get('https://api.quotable.io/random');

              try {
                RepoData(future)
                  ..onValue((p0) {
                    RGBLog.green(p0);
                  })
                  ..onError((p0) {
                    RGBLog.green(p0.name);
                    RGBLog.green(p0.desc);
                  });
              } catch (e) {
                RGBLog.blue(e);
              }
            },
            child: const Text('Fetch!'),
          ),
        ],
      ),
    );
  }
}
