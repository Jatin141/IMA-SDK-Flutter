import UIKit
import GSPlayer

class BasicFullscreenViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var fullscreenPlayerView: VideoFullscreenPlayerView!
    @IBOutlet weak var play_Button: UIButton!
    @IBOutlet weak var duration_Slider: UISlider!
    @IBOutlet weak var currentDuration_Label: UILabel!
    @IBOutlet weak var totalDuration_Label: UILabel!
    lazy var transitioner: VideoFullscreenTransitioner = {
        loadViewIfNeeded()
        let transition = VideoFullscreenTransitioner()
        transition.fullscreenControls = [closeButton]
        transition.fullscreenPlayerView = fullscreenPlayerView
        transition.fullscreenVideoGravity = .resizeAspect
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        return transition
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func tapClose(_ sender: UIButton) {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        dismiss(animated: true, completion: nil)
    }
    
//    @IBAction func onClicked_Play(_ sender: Any) {
//        if (videoPlayer.state == .playing) {
//            videoPlayer.pause(reason: .userInteraction)
//        } else {
//            videoPlayer.resume()
//        }
//    }
    
}
