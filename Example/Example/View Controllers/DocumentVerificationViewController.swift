import UIKit
import GatetoPayOnboardingSDK
class DocumentVerificationViewController: UIViewController {

    /**
     This class for ....
     */
    
    //MARK: - Outlets
    
    
    //MARK: - Variables
    @IBOutlet weak var frontImageView: UIView!
    @IBOutlet weak var frontImageImageView: UIImageView!
    @IBOutlet weak var bottomImageView: UIView!
    @IBOutlet weak var bottomImageImageView: UIImageView!
    
    var delegate: SelfieConfirmationDelegate?
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
        self.navigationItem.hidesBackButton = true
        let images = GatetoPayOnboarding.shared.scannedDocuments
        bottomImageView.isHidden = (images?.count ?? 0) == 1
        
        if (images?.count ?? 0) == 1{
            frontImageImageView.image = images?.first?.image
        }else{
            frontImageImageView.image = images?.filter({$0.documentSide == .front}).first?.image
            bottomImageImageView.image = images?.filter({$0.documentSide == .back}).first?.image
        }
    }
    
    
    //MARK: - Actions
    @IBAction func confirmButtonAction(_ sender: Any) {
        delegate?.userDidVerifySelfie()
    }
    
    @IBAction func noButtonAction(_ sender: Any) {
        delegate?.userDidSelectToRetakeSelfie()
    }
    
    //MARK:-Functions

}
