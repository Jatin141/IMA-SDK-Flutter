
import Foundation
import GoogleInteractiveMediaAds
import GSPlayer
import AVFoundation


class NativeViewFactory : NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
    }
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return NativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
}/*{
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return NativeView(frame, viewId:viewId, args:args)
    }
}*/

public class NativeView : NSObject, FlutterPlatformView,AudioPlayerDelegate, IMAAdsLoaderDelegate, IMAAdsManagerDelegate {
    
    deinit{
        stopTimer()
        playerView.pause()
    }
    
    private var _view: UIView
    var coordinatorDelegate: NewsCoordinatorDelegate?
    var kTestAppContentUrl_MP4 = "https://jsoncompare.org/LearningContainer/SampleFiles/Video/MP4/sample-mp4-file.mp4"
   // var kTestAppContentUrl_MP4 =
  //    "https://storage.googleapis.com/gvabox/media/samples/stock.mp4"
    
//    var kTestAppContentUrl_MP4 =
//      "https://jsoncompare.org/LearningContainer/SampleFiles/Video/MP4/sample-mp4-file.mp4"

    var settings = UIButton()
    //var contentPlayer: AVPlayer?
   // var playerLayer: AVPlayerLayer?
    
    var playerView =  VideoPlayerView()
    var controlView =  GSPlayerControlUIView()
    
    var paybackSlider = UISlider()

    var contentPlayhead: IMAAVPlayerContentPlayhead?
    var adsLoader: IMAAdsLoader!
    var adsManager: IMAAdsManager!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//    var controller = UIApplication.shared.keyWindow?.rootViewController
    let controller = UIApplication.topViewController()
//    var controller = FlutterViewController()

    var item : AVPlayerItem!
   // let flutterChannel: FlutterMethodChannel
    var message : FlutterBinaryMessenger!
    weak var timer: Timer?
    
    static let kTestAppAdTagUrl =
      "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/vmap_ad_samples&sz=640x480&cust_params=sample_ar%3Dpremidpost&ciu_szs=300x250&gdfp_req=1&ad_rule=1&output=vmap&unviewed_position_start=1&env=vp&impl=s&cmsid=496&vid=short_onecue&correlator="
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        super.init()

        if let argumentsDictionary = args as? Dictionary<String, Any> {
            self.kTestAppContentUrl_MP4 = argumentsDictionary["videoURL"] as! String
//            self.kTestAppContentUrl_MP4 =
//            "https://storage.googleapis.com/gvabox/media/samples/stock.mp4"
            print("test URL:", kTestAppContentUrl_MP4)
        }
        message = messenger
        
        let flutterChannel = FlutterMethodChannel(name: "gym_fans_video_player",
                                             binaryMessenger: messenger!)
        
//        func fullScreen(){
//            flutterChannel.invokeMethod("fullScreen",arguments: 0)
//        }
        
      //  flutterChannel.invokeMethod("fullScreen",arguments: 0)
        
        flutterChannel.setMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) -> Void in
            switch call.method {
//            case "loadUrl":
//                if let args = call.arguments as? [String: Any]{
//                    self.kTestAppContentUrl_MP4 = args["loadUrl"] as! String
//                          return
//                }
                      
                    
            case "pauseVideo":
                self.playerView.pause(reason: .userInteraction)
                if(self.adsManager != nil){
                if(self.adsManager.adPlaybackInfo.isPlaying) {
                    self.adsManager.pause()
                }
                }
                return
//             guard let args = call.arguments as? [String: Any],
//               let text = args["text"] as? String, else {
//               result(FlutterError(code: "-1", message: "Error"))
//               return
//             }
//              self.magicView.receiveFromFlutter(text)
//              result("receiveFromFlutter success")
                
           // case "resumeVideo":
               // self.playerView.resume()
              //  self.controlView.isHidden = false
            default:
                result(FlutterMethodNotImplemented)
            }
            })
         
    
        // iOS views can be created here
       // self.view.backgroundColor = UIColor.black;
        setUpContentPlayer(view: _view)
        setUpAdsLoader()
        createNativeView(view: _view)
        startTimer()
       
        
    }
    
    func startTimer() {
        timer?.invalidate()   // just in case you had existing `Timer`, `invalidate` it before we lose our reference to it
        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [weak self] _ in
            self?.controlView.isHidden = true
        }
    }

    func stopTimer() {
        timer?.invalidate()
        self.playerView.pause()
    }

    // if appropriate, make sure to stop your timer in `deinit`

    
    
    func fullScreenTap() {
            print("fullScreen tapped!!")
        let flutterChannel = FlutterMethodChannel(name: "gym_fans_video_player",
                                             binaryMessenger: message!)
        flutterChannel.invokeMethod("fullScreen",arguments: 0)
        
        playerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height:UIScreen.main.bounds.size.width )
        controlView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        
     //   let value = UIInterfaceOrientation.landscapeLeft.rawValue
     //   UIDevice.current.setValue(value, forKey: "orientation")
     //   UIViewController.attemptRotationToDeviceOrientation()
        }
    
    func normalScreenTap() {
            print("normalScreen tapped!!")
        let flutterChannel = FlutterMethodChannel(name: "gym_fans_video_player",
                                             binaryMessenger: message!)
        flutterChannel.invokeMethod("normalScreen",arguments: 0)
        
        playerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: 300)
        controlView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: 300)
        
        }
    
    
    
    
    func setUpContentPlayer(view _view: UIView) {
      // Load AVPlayer with path to our content.
        print("test URL1:", kTestAppContentUrl_MP4)
    
      
      guard let contentURL = URL(string: kTestAppContentUrl_MP4) else {
        print("ERROR: please use a valid URL for the content URL")
        return
      }
        
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: URL(string: kTestAppContentUrl_MP4)!)

        controller.player = player
        
        playerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 300)
        controlView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 300)

        playerView.contentMode = .scaleAspectFill
    
      

        playerView.play(for: contentURL)
    
    
        controlView.delegate = self
        controlView.populate(with: playerView)
        
      //self.contentPlayer = AVPlayer(url: contentURL)
     // guard let contentPlayer = self.contentPlayer else { return }

      // Create a player layer for the player.
     // playerLayer = AVPlayerLayer(player: contentPlayer)

      // Size, position, and display the AVPlayer.
        _view.addSubview(playerView)
        _view.addSubview(controlView)
        
        playerView.pause(reason: .userInteraction)
        controlView.isHidden = true
        controlView.bringSubviewToFront(_view)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.touchHappen(_:)))
        playerView.addGestureRecognizer(tap)
        playerView.isUserInteractionEnabled = true

       
        

        //_view.layer.addSublayer(playerLayer!)

      // Set up our content playhead and contentComplete callback.
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: playerView.player!)
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(NewsViewController.contentDidFinishPlaying(_:)),
        name: UIApplication.didEnterBackgroundNotification,
        object: nil)
    }
    
    @objc func touchHappen(_ sender: UITapGestureRecognizer) {
        print("touchHappen")
        self.controlView.isHidden = false
    }
    
   

    @objc func applicationDidEnterBackground(_ notification: NSNotification) {
        playerView.pause(reason: .userInteraction)
    }
    
    @objc func contentDidFinishPlaying(_ notification: Notification) {
     
    }

    func setUpAdsLoader() {
      adsLoader = IMAAdsLoader(settings: nil)
      adsLoader.delegate = self
    }

    func requestAds(view _view: UIView) {
      // Create ad display container for ad rendering.
      let adDisplayContainer = IMAAdDisplayContainer(
        adContainer: _view, viewController: controller, companionSlots: nil)
      // Create an ad request with our ad tag, display container, and optional user context.
      let request = IMAAdsRequest(
        adTagUrl: NativeView.kTestAppAdTagUrl,
        adDisplayContainer: adDisplayContainer,
        contentPlayhead: contentPlayhead,
        userContext: controlView)

      adsLoader.requestAds(with: request)
        
    }
    public func view() -> UIView {
        return _view
    }

    func createNativeView(view _view: UIView){
        _view.backgroundColor = UIColor.black
        
        settings.addTarget(self, action: #selector(touchedSet), for: .touchUpInside)
                settings.setImage(UIImage(named: "play_48px"), for: .normal)
                settings.frame = CGRect(x: 180, y:300/2 , width: 50, height: 50)
        _view.addSubview(settings)
        _view.bringSubviewToFront(controlView)
        _view.bringSubviewToFront(settings)


    }


    
    @objc func touchedSet(sender: UIButton!) {
           print("You tapped the button")
        
        
        requestAds(view: _view)
           settings.isHidden = true
       }
    
    // MARK: - IMAAdsLoaderDelegate

    public func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
      // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
      adsManager = adsLoadedData.adsManager
      adsManager.delegate = self

      // Create ads rendering settings and tell the SDK to use the in-app browser.
      let adsRenderingSettings = IMAAdsRenderingSettings()
      adsRenderingSettings.linkOpenerPresentingController = controller

      // Initialize the ads manager.
      adsManager.initialize(with: adsRenderingSettings)
    }

    public func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        playerView.resume()
        controlView.isHidden = false

    }

    // MARK: - IMAAdsManagerDelegate

    public func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
      if event.type == IMAAdEventType.LOADED {
        // When the SDK notifies us that ads have been loaded, play them.
        adsManager.start()
      }
        if event.type == IMAAdEventType.RESUME {
                // When the SDK notifies us that ads playback has resumed from a pause
                // hide play button
          //  controlView.play_Button.isHidden = false
            settings.addTarget(self, action: #selector(touchedSet), for: .touchUpInside)
                    settings.setImage(UIImage(named: "play_48px"), for: .normal)
                    settings.frame = CGRect(x: 180, y:300/2 , width: 50, height: 50)
            _view.addSubview(settings)
            }
            
            if event.type == IMAAdEventType.PAUSE {
                // When the SDK notifies us that ads playback is paused
                // Show play button
               // controlView.play_Button.isHidden = true
                if(adsManager.adPlaybackInfo.isPlaying) {
                    adsManager.pause()
                }
                settings.addTarget(self, action: #selector(touchedSet), for: .touchUpInside)
                        settings.setImage(UIImage(named: "play_48px"), for: .normal)
                        settings.frame = CGRect(x:180, y:300/2 , width: 50, height: 50)
                _view.addSubview(settings)
            }
            
            if event.type == IMAAdEventType.TAPPED {
                // You can also add allow the user to tap anywhere on the Ad to resume play
                if(!adsManager.adPlaybackInfo.isPlaying) {
                    adsManager.resume()
                }
            }
                
    }

    public func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
      // Something went wrong with the ads manager after ads were loaded. Log the error and play the
      // content.
      print("AdsManager error: \(error.message ?? "nil")")
        playerView.resume()
        controlView.isHidden = false

    }

    public func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
      // The SDK is going to play ads, so pause the content.
        playerView.pause(reason: .userInteraction)
        controlView.isHidden = true

    }

    public func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
      // The SDK is done playing ads (at least for now), so resume the content.
        print("AdsManager resume: \("nil")")
        playerView.resume()
        controlView.isHidden = false

    }
}

    

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
