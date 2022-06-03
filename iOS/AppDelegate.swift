
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var myOrientation: UIInterfaceOrientationMask = .portrait
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)

                  weak var registrar = self.registrar(forPlugin: "ima_sdk")

                  let factory = NativeViewFactory(messenger: registrar!.messenger())
                  registrar!.register(
                      factory,
                      withId: "NativeUI")
              
          return super.application(application, didFinishLaunchingWithOptions: launchOptions)

        
  }
    
    override func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            return myOrientation
        }
    
}
