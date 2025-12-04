import UIKit

protocol SelfieConfirmationDelegate{
    func userDidVerifySelfie()
    func userDidSelectToRetakeSelfie()
    
}

class SelfieConfirmationViewController: UIViewController {

 
    /**
     This class for ....
     */
    
    //MARK: - Outlets
    @IBOutlet weak var theImageView: UIImageView!
    
    
    //MARK: - Variables
    var passedImage: UIImage?
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
            self.theImageView.layer.borderColor = UIColor.init(named: "AbyanColor")?.cgColor
            self.theImageView.layer.borderWidth = 3.0
            self.theImageView.layer.cornerRadius = self.theImageView.layer.bounds.height / 2
        
        theImageView.image = passedImage
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
