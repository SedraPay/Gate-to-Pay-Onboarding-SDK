import UIKit
import GatetoPayOnboardingSDK
class SumbitFullNameViewController: UIViewController {

    /**
     This class for ....
     */
    
    //MARK: - Outlets
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var secondNameTextField: UITextField!
    @IBOutlet weak var thirdNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    //MARK: - Variables
    var documentsObject :DocumentVerificationResponse?
    
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
        let fullName = "\(documentsObject?.extractedFields?.filter({$0.name == "Full Name"}).first?.value ?? "")"
        let nameArray = fullName.split(separator: " ")
        firstNameTextField.text = String(nameArray.first ?? "")
        if nameArray.count >= 2 {
            secondNameTextField.text = String(nameArray[1])
        }
        if nameArray.count >= 3 {
            thirdNameTextField.text = String(nameArray[2])
        }
       
        lastNameTextField.text = String(nameArray.last ?? "")
    }
    
    
    //MARK: - Actions
    @IBAction func submitButtonAction(_ sender: Any) {
        GatetoPayOnboarding.comply.delegate = self
        Dialogs.showLoading()
        
        if firstNameTextField.text?.isEmpty ?? false || lastNameTextField.text?.isEmpty ?? false{
            Dialogs.showError("First and Last name is required", duration: 3)
        } else {
            GatetoPayOnboarding.comply.screenCustomer(firstName: firstNameTextField.text ?? "", secondName: secondNameTextField.text ?? "", thirdName: thirdNameTextField.text ?? "", lastName: lastNameTextField.text ?? "")
        }
    }
    
    //MARK:-Functions
}

extension SumbitFullNameViewController: GatetoPayOnboardingComplyDelegate{
    func emptyNamesError(error: GatetoPayOnboardingError) {
        Dialogs.dismiss()
    }
    
    func screeningFinishedWithError(message: GatetoPayOnboardingError) {
        Dialogs.dismiss()
    }
    
    func screeningFinishedWithSuccess(response: screeningResponse) {
        Dialogs.dismiss()
        DispatchQueue.main.async {
            if DefaultsManager.shared.getLivenessCheckValue() ?? true{
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelfieInstructionsViewController") as? SelfieInstructionsViewController{
                    vc.documentsObject = self.documentsObject
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else if DefaultsManager.shared.getCloseJourneyValue() ?? true {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "CloseJourneyViewController") as? CloseJourneyViewController{
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else {
                // The only switch on
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "StatusViewController") as? StatusViewController{
                    vc.statusType = .profileSubmitted
                    vc.delegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func screeningFinishedWithError(message: String) {
            Dialogs.dismiss()
            Dialogs.showError(message, duration: 3)
    }
}

extension SumbitFullNameViewController: StatusDelegate{
    func didPressNext() {
            self.navigationController?.popToRootViewController(animated: true)
    }
}
