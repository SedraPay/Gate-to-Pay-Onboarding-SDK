import UIKit
import GatetoPayOnboardingSDK
class FormViewController: UIViewController {


    /**
     This class for ....
     */
    
    //MARK: - Outlets
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var documentIDNumberTextField: UITextField!
    @IBOutlet weak var nationalIDTextField: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var arabicFullNameTextField: UITextField!
    
    
    //MARK: - Variables
    public var documentsObject: DocumentVerificationResponse?

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
        fullNameTextField.text = "\(documentsObject?.extractedFields?.filter({$0.name == "Full Name"}).first?.value ?? "")"
        let gender = (documentsObject?.extractedFields?.filter({$0.name == "Sex"}).first?.value ?? "")
        
        if gender.hasPrefix("M"){
            genderTextField.text = "\("Male")"
        }else if gender.hasPrefix("F"){
            genderTextField.text = "\("Female")"
        }else{
            genderTextField.text = "\("")"
        }
        let arabicName = "\(documentsObject?.extractedFields?.filter({$0.name == "Full Name Native"}).first?.value ?? "")"
        
        arabicFullNameTextField.text = arabicName
        dateOfBirthTextField.text =  "\(documentsObject?.extractedFields?.filter({$0.name == "Birth Date"}).first?.value ?? "")"
        documentIDNumberTextField.text = "\(documentsObject?.extractedFields?.filter({$0.name == "Document Number"}).first?.value ?? "")" //to have it
        nationalIDTextField.text = "\(documentsObject?.extractedFields?.filter({$0.name == "Personal Number"}).first?.value ?? "")"
        expiryDateTextField.text = "\(documentsObject?.extractedFields?.filter({$0.name == "Expiry Date"}).first?.value ?? "")"
        addressTextField.text = "\(documentsObject?.extractedFields?.filter({$0.name == "Address"}).first?.value ?? "")"
    }
    
    
    //MARK: - Actions
    @IBAction func submitButtonAction(_ sender: Any) {
        GatetoPayOnboarding.comply.delegate = self
        Dialogs.showLoading()
        
//        let nameArray = (documentsObject?.extractedFields?.filter({$0.name == "Full Name"}).first?.value ?? "").split(separator: " ")
        if fullNameTextField.text?.isEmpty ?? false {
            Dialogs.showError("Full name is required", duration: 3)
        } else {
            let nameArray = fullNameTextField.text?.split(separator: " ")
            
            GatetoPayOnboarding.comply.screenCustomer(firstName: String(nameArray?.first ?? ""), secondName: "", thirdName: "", lastName: String(nameArray?.last ?? ""))
        }
        
    }
    
    //MARK:-Functions
    func showCloseJourneyAlert(){
        let ac = UIAlertController(title: "Enter Customer ID", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.textFields?.first?.keyboardType = .default
        ac.textFields?.first?.placeholder = "Customer ID"
        
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            let answer = ac.textFields![0].text ?? ""
            DispatchQueue.main.async {
                
                if answer.isEmpty{
                    self.showCloseJourneyAlert()
                    return
                }
                GatetoPayOnboarding.closeJourney.delegate = self
                GatetoPayOnboarding.closeJourney.closeJourneyAPI(customerId: answer )
            }
        }
        ac.addAction(submitAction)
        
        self.present(ac, animated: true)
    }

}


extension FormViewController: StatusDelegate{
    func didPressNext() {
            self.navigationController?.popToRootViewController(animated: true)
    }
}

extension FormViewController: GatetoPayOnboardingComplyDelegate{
    func emptyNamesError(error: GatetoPayOnboardingError) {
        
    }
    
    func screeningFinishedWithError(message: GatetoPayOnboardingError) {
        
    }
    
    func screeningFinishedWithSuccess(response: screeningResponse) {
        Dialogs.dismiss()
        DispatchQueue.main.async {
            self.showCloseJourneyAlert()
        }
    }
    
    func screeningFinishedWithError(message: String) {
//        DispatchQueue.main.async    {
            Dialogs.dismiss()
            Dialogs.showError(message, duration: 3)
//        }
    }
}

extension FormViewController: GatetoPayOnboardingCloseJourneyDelegate {
    func didFinishCloseJourneyWithSuccess() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "StatusViewController") as? StatusViewController{
            vc.statusType = .profileSubmitted
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didFinishCloseJourneyWithError(error: GatetoPayOnboardingError) {
        
    }
    
  
    
}
