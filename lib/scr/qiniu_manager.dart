import 'package:qiniu_flutter_sdk/qiniu_flutter_sdk.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qiniu_sdk_base/qiniu_sdk_base.dart' as base;

/// 七牛上传工具类
class QiNiuManager {
  static late final QiNiuManager _instance = QiNiuManager._internal();

  QiNiuManager._internal();

  factory QiNiuManager() => _instance;

  ///上传文件
  ///uploadFile 上传文件
  ///token 接口返回七牛token
  ///urlPrefix 返回地址需要拼接的前缀
  ///key 资源名,如果不传则后端自动生成
  ///progress 上传进度
  ///sucCallback 成功回调
  ///failCallback 失败回调
  ///retryLimit 失败重试次数
  ///base.Config 上传配置类，可修改host、配置HttpClientAdapter等
  PutController uploadFile(
    File uploadFile,
    String token,
    String? urlPrefix,
    String? key, {
    UploadProgressCallback? progress,
    UploadSucCallback? sucCallback,
    UploadFailCallback? failCallback,
    int? retryLimit,
    base.Config? config,
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
    Storage storage = Storage(
      config: config ??
          Config(
            retryLimit: retryLimit ?? 3, //失败重试次数
          ),
    );

    /// PutController 控制器，可以用于取消任务、获取上述的状态，进度等信息
    /// 添加任务进度监听
    /// addProgressListener
    /// 添加文件发送进度监听
    /// addSendProgressListener
    /// 添加任务状态监听
    /// addStatusListener
    ///
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
          sucCallback(_generateFileName(urlPrefix, key), response.hash ?? "");
        }
        debugPrint('上传已完成: 原始响应数据: ${jsonEncode(response.rawData)}');
        ;
      })
      ..catchError((dynamic error) {
        if (error is StorageError) {
          String errorMsg = _onError(error);
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
    return putController;
  }

  ///取消上传任务
  void cancel(PutController controller) {
    controller.cancel();
  }

  ///处理异常
  String _onError(StorageError error) {
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
  String _generateFileName(String? urlPrefix, String? key) {
    return '$urlPrefix' + '/' + '$key';
  }
}

typedef UploadProgressCallback = void Function(double percent);

typedef UploadSucCallback = void Function(String url, String hashCode);

typedef UploadFailCallback = void Function(int? code, String msg);
