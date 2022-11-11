import 'package:qiniu_flutter_sdk/qiniu_flutter_sdk.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';

/// 七牛上传工具类
class QiNiuManager {
  static late final QiNiuManager _instance = QiNiuManager._internal();

  QiNiuManager._internal();

  factory QiNiuManager() => _instance;

  ///上传文件
  ///uploadFile 删除文件
  ///
  void uploadFile(
    File uploadFile,
    String token,
    String? urlPrefix,
    String? key, {
    UploadProgressCallback? progress,
    UploadSucCallback? sucCallback,
    UploadFailCallback? failCallback,
  }) {
    /// storage 对象
    /// storage = Storage(Config(
    /// 通过自己的 hostProvider 来使用自己的 host 进行上传
    ///    hostProvider: HostProvider,
    ///     // 可以通过实现 cacheProvider 来自己实现缓存系统支持分片断点续传
    ///     cacheProvider: CacheProvider,
    ///     // 如果你需要对网络请求进行更基础的一些操作，你可以实现自己的 HttpClientAdapter 处理相关行为
    ///     httpClientAdapter: HttpClientAdapter,
    ///     // 设定网络请求重试次数
    ///     retryLimit: 3,
    ///  ));
    /// PutController 控制器，可以用于取消任务、获取上述的状态，进度等信息
    /// 添加任务进度监听
    /// addProgressListener
    /// 添加文件发送进度监听
    /// addSendProgressListener
    /// 添加任务状态监听
    /// addStatusListener
    ///
    Storage storage = Storage();

    PutController putController = PutController();
    if (progress != null) {
      putController.addProgressListener((double percent) {
        progress(percent);
      });
    }
    storage.putFile(
      uploadFile,
      token,
      options: PutOptions(
        key: key,
        controller: putController,
      ),
    )
      ..then((PutResponse response) {
        if (sucCallback != null) {
          sucCallback(generateFileName(urlPrefix, key), response.hash ?? "");
        }
        debugPrint('上传已完成: 原始响应数据: ${jsonEncode(response.rawData)}');
        ;
      })
      ..catchError((dynamic error) {
        if (error is StorageError) {
          String errorMsg = onError(error);
          if (failCallback != null) {
            failCallback(error.code, errorMsg);
          }
        } else {
          if (failCallback != null) {
            failCallback(error.code, error.toString());
          }
          debugPrint('发生错误: ${error.toString()}');
        }
      });
  }

  ///处理异常
  String onError(StorageError error) {
    String errorMsg = "上传失败";
    switch (error.type) {
      case StorageErrorType.CONNECT_TIMEOUT:
        errorMsg = '上传错误: 连接超时';
        break;
      case StorageErrorType.SEND_TIMEOUT:
        errorMsg = '上传错误: 发送数据超时';
        break;
      case StorageErrorType.RECEIVE_TIMEOUT:
        errorMsg = '上传错误: 响应数据超时';
        break;
      case StorageErrorType.RESPONSE:
        errorMsg = '上传错误: ${error.message}';
        break;
      case StorageErrorType.CANCEL:
        errorMsg = '上传错误: 请求取消';
        break;
      case StorageErrorType.UNKNOWN:
        errorMsg = '上传错误: 未知错误';
        break;
      case StorageErrorType.NO_AVAILABLE_HOST:
        errorMsg = '上传错误: 无可用 Host';
        break;
      case StorageErrorType.IN_PROGRESS:
        errorMsg = '上传错误: 已在队列中';
        break;
    }
    return errorMsg;
  }

  ///获取用户上传头像文件路径
  String generateFileName(String? urlPrefix, String? key) {
    return '$urlPrefix' + '/' + '$key';
  }
}

typedef UploadProgressCallback = void Function(double percent);

typedef UploadSucCallback = void Function(String url, String hashCode);

typedef UploadFailCallback = void Function(int? code, String msg);
