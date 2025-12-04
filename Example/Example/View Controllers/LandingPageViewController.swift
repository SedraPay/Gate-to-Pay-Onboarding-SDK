import UIKit
import GatetoPayOnboardingSDK
class LandingPageViewController: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var enableOCRSwitch: UISwitch!
    @IBOutlet weak var subscriptionKeyTF: UITextField!
    @IBOutlet weak var nationalNumberTF: UITextField!
    @IBOutlet weak var riskIDTF: UITextField!
    @IBOutlet weak var applicationIDTF: UITextField!
    
    //MARK: Variables
    var nationalitiesResponse: CountriesAndCitiesResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscriptionKeyTF.delegate = self
        nationalNumberTF.delegate = self
        riskIDTF.delegate = self
        applicationIDTF.delegate = self
        subscriptionKeyTF.attributedPlaceholder = NSAttributedString(
                string: subscriptionKeyTF.placeholder ?? "",
                attributes: [
                    .foregroundColor: UIColor.gray
                ]
            )
        nationalNumberTF.attributedPlaceholder = NSAttributedString(
                string: nationalNumberTF.placeholder ?? "",
                attributes: [
                    .foregroundColor: UIColor.gray
                ]
            )
        riskIDTF.attributedPlaceholder = NSAttributedString(
                string: riskIDTF.placeholder ?? "",
                attributes: [
                    .foregroundColor: UIColor.gray
                ]
            )
        applicationIDTF.attributedPlaceholder = NSAttributedString(
                string: applicationIDTF.placeholder ?? "",
                attributes: [
                    .foregroundColor: UIColor.gray
                ]
            )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.subscriptionKeyTF.text = UserDefaults.standard.string(forKey: "ServerKey") ?? ""
        
    }
    
    
    func validateTextFields() -> Bool {
        var isValid = true
        if subscriptionKeyTF.text == "" {
            isValid = false
        }
        else if nationalNumberTF.text == "" {
            isValid = false

        }
        else if riskIDTF.text == "" {
            isValid = false
        }
        return isValid
    }
    
    
    //MARK: Actions
    
    
    @IBAction func enableOCRSwitchAction(_ sender: UISwitch) {
        sender.isOn ?
        GatetoPayOnboarding.shared.setOCREnabled(true):
        GatetoPayOnboarding.shared.setOCREnabled(false)
    }
    
    
    @IBAction func nextButtonAction(_ sender: UIButton) {
        if self.validateTextFields() {
            
            DispatchQueue.main.async {
                
                Dialogs.showLoading()
                GatetoPayOnboarding.shared.scannedDocuments = nil
                GatetoPayOnboarding.shared.livenessImage = nil
                GatetoPayOnboarding.shared.livenessImageId = nil
                GatetoPayOnboarding.shared.imagesIds = nil
                GatetoPayOnboarding.shared.delegate = self
                
                try? GatetoPayOnboarding.shared.setSettings(
                    serverKey: self.subscriptionKeyTF.text ?? "",
                    serverURLString: "https://gatetopayintgw.sedrapay.com/" ,
                    nationalNumber: self.nationalNumberTF.text ?? "",
                    riskFormId: self.riskIDTF.text ?? "",
                    applicationId: self.applicationIDTF.text ?? ""
                )
            }
            
            
        } else {
            let alert = UIAlertController(
                title: "Missing Information",
                message: "Please enter the required field to start the journey (Server Key, National Number / Passport Number, Risk ID).",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            self.present(alert, animated: true, completion: nil)

        }
        
        
        
        
    }
}

extension LandingPageViewController: GatetoPayOnboardingJourneyDelegate{
    
    func didFinishCreatingJourneyWithError(error: GatetoPayOnboardingError) {
        Dialogs.dismiss()
        Dialogs.showWarning("Invalid subscription key", duration: 5)
        //self.showSubscriptioKeyAlert()
    }
    
    
    func didFinishCreatingJourneyWithSuccess(journeyId: String, isDocumentVerification: Bool, isLiveness: Bool, isFaceMatching: Bool) {
        Dialogs.dismiss()
        isDocumentVerificationEnabled = isDocumentVerification
        isLivenessEnabled = isLiveness
        isFaceMatchingEnabled = isFaceMatching
        GatetoPayOnboarding.countries.delegate = self
        GatetoPayOnboarding.countries.getNationalities()
        
        
    }
    
    
}

extension  LandingPageViewController: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.subscriptionKeyTF{
            UserDefaults.standard.set(textField.text, forKey: "ServerKey")
        }
    }
}


extension  LandingPageViewController: GatetoPayOnboardingRiskFormDelegate {
    
    func riskFormFinishedWithError(error: GatetoPayOnboardingError){
        Dialogs.dismiss()
        Dialogs.showError("The service is not available")
        
    }
    
    func riskFormFields(fields: [GatetoPayOnboardingKYCFieldItem]){
        Dialogs.dismiss()
        var array: [GatetoPayOnboardingKYCDynamicField] = []
        
        for item in fields {
            if let items = item.dynamicFields {
                for object in items {
                    array.append(object)
                }
            }
        }
        
        if let viewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "RiskFormViewController") as? RiskFormViewController {
            Dialogs.dismiss()
            viewController.dataArray = array
            viewController.sectionsArray = fields
            viewController.nationalitiesResponse = self.nationalitiesResponse
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func didUpdateRiskFormSuccessfully(riskLevel:Int?){
        
    }
    
    func updateRiskFormFinishedWithError(error: String){
        
    }
    
}


extension LandingPageViewController : GatetoPayOnboardingCountriesDelegate {
    func didGetNationalitiesWithSuccess(response: CountriesAndCitiesResponse) {
        Dialogs.dismiss()
        self.nationalitiesResponse = response
        Dialogs.showLoading()
        GatetoPayOnboarding.riskForm.delegate = self
        GatetoPayOnboarding.riskForm.getRiskFields(fieldValues: [])

    }
    
    func didGetNationalitiesWithError(error: GatetoPayOnboardingError) {
        
    }
    
    
}
