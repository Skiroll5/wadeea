// Google Sign In Button Dispatcher
// Uses conditional imports to load the correct implementation

export 'google_sign_in_button_stub.dart'
    if (dart.library.io) 'google_sign_in_button_mobile.dart'
    if (dart.library.js_interop) 'google_sign_in_button_web.dart';
