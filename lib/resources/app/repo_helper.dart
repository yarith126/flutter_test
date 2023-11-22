import 'dart:async';
import 'package:flutter/cupertino.dart';

class RepoData<T> {
  RepoData(this.future) {
    future.then((value) {
      if (_valueCallback != null) _valueCallback!(value);
    }).catchError((e, s) {
      var eo = _errorHandler(e);
      if (_errorCallback != null) _errorCallback!(eo);
      future.ignore();
    }).whenComplete(() {
      if (_whenCompleteCallback != null) _whenCompleteCallback!();
    });
  }

  Future<T> future;
  Function(T)? _valueCallback;
  Function(ErrorObject)? _errorCallback;
  Function()? _whenCompleteCallback;

  ErrorObject _errorHandler(e) {
    return ErrorObject('name test', 'desc test');
  }

  RepoData onValue(Function(T) valueCallback) {
    _valueCallback = valueCallback;
    return this;
  }

  RepoData onError(Function(ErrorObject) errorCallback) {
    _errorCallback = errorCallback;
    return this;
  }

  RepoData whenComplete(VoidCallback whenComplete) {
    _whenCompleteCallback = whenComplete;
    return this;
  }
}

class ErrorObject {
  ErrorObject(this.name, this.desc);

  String name;
  String desc;
}

/// Usage example
///
/// async:
/// RepoData(future)
/// ..onValue((p0) => RGBLog.green(p0))
/// ..onError((p0) => RGBLog.green(p0))
/// ..whenComplete(() => RGBLog.green('done'));
///
/// sync:
/// var obj = RepoData(future)
///   ..onValue((p0) => RGBLog.green(p0))
///   ..onError((p0) => RGBLog.green(p0))
///   ..whenComplete(() => RGBLog.green('done'));
/// await obj.future;
///
/// or await RepoData(future).future;
