import UIKit
import Lottie

enum StatusTypeEnum: Int{
    case phoneValidation
    case veriftingPhoto
    case photoVerified
    case profileSubmitted
}

protocol StatusDelegate: NSObjectProtocol{
    func didPressNext()
}

class StatusViewController: UIViewController {


    /**
     This class for ....
     */
    
    //MARK: - Outlets
    @IBOutlet weak var lottieView: LottieView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var bottomButton: FAButton!
    
    
    //MARK: - Variables
    let animationView = AnimationView()
    var statusType: StatusTypeEnum?
    var delegate: StatusDelegate?
    
    //MARK: - Class Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //MARK: - Helpers
    func setupView(){
        bottomButton.isHidden = false
        switch statusType{
        case .veriftingPhoto:
            animationView.animation = Animation.named("hourGlass")
            animationView.frame = lottieView.bounds
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .loop
            animationView.play()
            lottieView.addSubview(animationView)
            
            statusLabel.text = "Please wait, we are verifying your photo, it will take a moment ..."
            bottomButton.isHidden = true
            
        case .phoneValidation:
            setupLikeLottie()
            statusLabel.text = "Your mobile number has been verified successfully"
            
        case .photoVerified:
            setupLikeLottie()
            statusLabel.text = "Your photo has been verified successfully"
            
        case .profileSubmitted:
            bottomButton.isHidden = false
            bottomButton.setTitle("Done", for: .normal)
            setupLikeLottie()
            statusLabel.text = "Your profile has been submitted successfully"

        default:
            break
        }
    }
    
    func setupLikeLottie(){
        animationView.animation = Animation.named("like")
        animationView.frame = lottieView.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        lottieView.addSubview(animationView)
    }
    
    
    //MARK: - Actions
    @IBAction func bottomButtonAction(_ sender: Any) {
        self.delegate?.didPressNext()
    }
    
    
    //MARK:-Functions

}
