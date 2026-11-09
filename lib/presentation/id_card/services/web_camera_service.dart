// กล้องสำหรับ web: getUserMedia + ImageCapture.takePhoto()
// ใช้ conditional import เพื่อให้ compile ผ่านบน platform อื่น (จะ throw ตอนใช้งาน)
export 'web_camera_service_stub.dart'
    if (dart.library.js_interop) 'web_camera_service_web.dart';
