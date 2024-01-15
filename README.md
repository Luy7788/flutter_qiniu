# flutter_qiniu

```
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
```

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

