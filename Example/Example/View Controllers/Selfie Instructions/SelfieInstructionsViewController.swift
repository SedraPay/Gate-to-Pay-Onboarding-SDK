import UIKit
import AVFoundation
import GatetoPayOnboardingSDK
class SelfieInstructionsViewController: UIViewController {
    
    /**
     This class for ....
     */
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.register(UINib.init(nibName: "SelfieInstructionsTableViewCell", bundle: nil), forCellReuseIdentifier: "SelfieInstructionsTableViewCell")
        }
    }
    
    @IBOutlet weak var isDetectionsOptionsSorted: UISwitch!
    
    //MARK: - Variables
    private var instructionsArray = [String]()
    var currentStep = 0
    var documentsObject: DocumentVerificationResponse?
    var count = 0
    var selectedProduct:Int?
    var formDataValueArray: [formDataValueFields] = []
    var nationalitiesResponse: CountriesAndCitiesResponse?
    
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
        instructionsArray = ["Make sure you are in a well-lit area", "Hold your phone at eye level", "You will be asked to perform some gestures", "If you are wearing eye glasses, a face mask, or a hat, take it off."]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    
    //MARK: - Actions
    @IBAction func actionButtonAction(_ sender: Any) {
        GatetoPayOnboarding.livenessCheck.checkLiveness(viewController: self, detectOptions: [.blink, .lookRight, .lookLeft], isDetectionOptionsSorted: isDetectionsOptionsSorted.isOn)
        GatetoPayOnboarding.livenessCheck.delegate = self
    }
    
    @IBAction func isDetectionsOptionsSortedAction(_ sender: Any) {
        
    }
    
    //MARK:-Functions
    
    
}

extension SelfieInstructionsViewController: UITableViewDataSource, UITableViewDelegate{
    
    //MARK: - TableView DataSource and Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instructionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SelfieInstructionsTableViewCell", for: indexPath) as? SelfieInstructionsTableViewCell{
            cell.currentInstructionLabel.text = instructionsArray[indexPath.row]
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
}


extension SelfieInstructionsViewController: GatetoPayOnboardingLivenessCheckDelegate{
    func faceMatchingBundleNotAvailable() {
        Dialogs.showLoading()
        GatetoPayOnboarding.kyc.delegate = self
        GatetoPayOnboarding.kyc.getKYCFields(fieldValues: [] , productId: productIdForKYC ?? 0)
    }
    
    
    func LivenessCheckPageError(error: GatetoPayOnboardingError) {
        Dialogs.dismiss()
        Dialogs.showError(error.errorString)
    }
    
    func cameraAccessDeniedError(error: GatetoPayOnboardingError) {
        Dialogs.dismiss()
        let alert = UIAlertController(
            title: "Camera Access Needed",
            message: "To use this feature, please allow camera access in Settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow", style: .default) { _ in
            //               if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            //                   UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            //               }
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (_) in
                GatetoPayOnboarding.livenessCheck.checkLiveness(viewController: self, detectOptions: [.blink, .lookRight, .lookLeft], isDetectionOptionsSorted: self.isDetectionsOptionsSorted.isOn)
                GatetoPayOnboarding.livenessCheck.delegate = self
            })
        })
        
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(alert, animated: true, completion: nil)
        }
    }
    
    func didPressCancel() {
        
    }
    
    func LivenessCheckDone(){
    }
    
    func didGetImageSuccessfully(data: UIImage) {
        //1
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelfieConfirmationViewController") as? SelfieConfirmationViewController{
            vc.delegate = self
            vc.passedImage = data
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didGetImageMatchingResponseSuccessfully(response: ImageMatchingResponse) {
        Dialogs.dismiss()
        self.navigationController?.popViewController(animated: false)
        
        if !(response.isIdentical ?? false) {
            Dialogs.showError("Faces do not match", duration: 4)
            return
        }
        
        Dialogs.showLoading()
        GatetoPayOnboarding.kyc.delegate = self
        GatetoPayOnboarding.kyc.getKYCFields(fieldValues: [] , productId: productIdForKYC ?? 0)
    }
    
    func didGetError(errorMessage: String) {
        //show error
        Dialogs.dismiss()
        Dialogs.showError(errorMessage, duration: 5)
    }
    
    
}

extension SelfieInstructionsViewController: SelfieConfirmationDelegate{
    func userDidVerifySelfie() {
        Dialogs.showLoading()
        GatetoPayOnboarding.livenessCheck.uploadLivenessCheckImage()
    }
    
    func userDidSelectToRetakeSelfie() {
        self.navigationController?.popToViewController(self, animated: true)
        
    }
}

extension SelfieInstructionsViewController: StatusDelegate{
    func didPressNext() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension SelfieInstructionsViewController: GatetoPayOnboardingKYCDelegate {
    func updateKYCFinishedWithError(error: String) {
        Dialogs.dismiss()
    }
    
    func didUpdateKYCSuccessfully(id: Int?) {
        Dialogs.dismiss()
    }
    
    
    func kycFinishedWithError(error: GatetoPayOnboardingError) {
        Dialogs.dismiss()
        Dialogs.showError("The service is not available")
    }
    
    func kycFields(fields: GatetoPayOnboardingKYCFieldModel) {
        Dialogs.dismiss()
        if fields.isNumberMatchOCR == false {
            let alert = UIAlertController(title: "", message: "It seems that your ID number is wrong or your ID Scan is not clear or does not match your selfie image", preferredStyle: .alert)
            
            let rescanAction = UIAlertAction(title: "Re scan Card ID", style: .default) { _ in
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScanIDViewController") as? ScanIDViewController {
                    vc.pageType = .documentType
                    vc.nationalitiesResponse = self.nationalitiesResponse
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            
            let editNumberAction = UIAlertAction(title: "Edit National Number", style: .default) { _ in
                
                self.navigationController?.popToRootViewController(animated: true)
            }
            
            
            alert.addAction(rescanAction)
            alert.addAction(editNumberAction)
            
            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                rootVC.present(alert, animated: true)
            }
            return
        }
        else if fields.cspdMatchingResponse?.isIdentical == false {
            let alert = UIAlertController(title: "", message: "It seems that your image does not match your ID image", preferredStyle: .alert)
            
            let rescanAction = UIAlertAction(title: "Re scan Card ID", style: .default) { _ in
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScanIDViewController") as? ScanIDViewController {
                    vc.pageType = .documentType
                    vc.nationalitiesResponse = self.nationalitiesResponse
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ _ in
                self.navigationController?.popToRootViewController(animated: true)

            }

            alert.addAction(rescanAction)
            alert.addAction(cancelAction)


            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                rootVC.present(alert, animated: true)
            }
            return
        }
        var array: [GatetoPayOnboardingKYCDynamicField] = []
        
        for item in fields.steps ?? [] {
            if let items = item.dynamicFields {
                for object in items {
                    array.append(object)
                }
            }
        }
        
        if let viewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "KYCViewController") as? KYCViewController {
            Dialogs.dismiss()
            viewController.dataArray = array
            viewController.sectionsArray = fields.steps ?? []
            viewController.nationalitiesResponse = self.nationalitiesResponse
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        //        self.dataArray = array
    }
}
