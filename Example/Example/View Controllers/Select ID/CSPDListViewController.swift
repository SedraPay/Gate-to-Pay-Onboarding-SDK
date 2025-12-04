//
//  CSPDListViewController.swift
//  Sample
//
//  Created by Amani on 25/11/2025.
//

import GatetoPayOnboardingSDK
import AMPopTip
import DropDown
import UIKit
import DatePickerDialog
import PDFKit
import Photos
import FAPickerView

class CSPDListViewController: UIViewController {

    var cspdList = [CSPDType]()
    var nationalitiesResponse: CountriesAndCitiesResponse?

    @IBOutlet weak var cspdListButton: UIButton!
    @IBOutlet weak var selectedCSPDLB: UILabel!
    var customerIdentityType : Int?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func didSelectCSPDList(button: UIButton) {
        

        let items: [FAPickerItem] = cspdList.map { ev in
            FAPickerItem(id: ev.value, title: ev.key)
        }

        FAPickerView.showSingleSelectItem(
            items: NSMutableArray(array: items),
            selectedItem: nil,
            filter: true,
            headerTitle: "Select ID type",
            complete: { [weak self] (selectedItem: FAPickerItem?) in
                guard let self = self, let selectedItem = selectedItem else { return }

                // Update UI
                selectedCSPDLB.text = selectedItem.title

                self.customerIdentityType = Int(selectedItem.id) ?? 0
              
            },
            cancel: {
                print("Dropdown selection canceled")
            }
        )
    }

    
    @IBAction func NextButton(_ sender: Any) {
        GatetoPayOnboarding.cspdData.delegate = self
        GatetoPayOnboarding.cspdData.getProductByIdType(riskLevel: risklevel ?? 0, customerIdentityType: self.customerIdentityType ?? 0)
    }
    
}

extension CSPDListViewController : GatetoPayOnboardingCSPDDelegate {
    func productIdForKYCReceived(productId: Int) {
        productIdForKYC = productId
        if !isDocumentVerificationEnabled && !isLivenessEnabled {
            GatetoPayOnboarding.kyc.delegate = self
            Dialogs.showLoading()
            GatetoPayOnboarding.kyc.getKYCFields(fieldValues: [] , productId: productIdForKYC ?? 0)
           
        }
        else if isDocumentVerificationEnabled {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "ScanIDViewController") as? ScanIDViewController {
                vc.pageType = .documentType
                vc.nationalitiesResponse = nationalitiesResponse
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if isLivenessEnabled && !isDocumentVerificationEnabled {
            GatetoPayOnboarding.livenessCheck.checkLiveness(viewController: self, detectOptions: [.blink, .lookRight, .lookLeft], isDetectionOptionsSorted: true)
            GatetoPayOnboarding.livenessCheck.delegate = self
        }
    }
    
    func productIdForKYCFinishedWithError(error: GatetoPayOnboardingError) {
        Dialogs.showError(error.errorString)

    }
}

extension CSPDListViewController: GatetoPayOnboardingDocumentsDelegate{
    func didFinishWithError(error: GatetoPayOnboardingError) {
        Dialogs.dismiss()
        Dialogs.showError(error.errorString)
    }
    
    func userFinishCapturingDocumentsWithError(documents: [GatetoPayOnboardingDocument], error: GatetoPayOnboardingError) {
        Dialogs.dismiss()
        Dialogs.showError(error.errorString)
    }
    
    func userFinishCapturingDocument(documents: [GatetoPayOnboardingDocument]) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "DocumentVerificationViewController") as? DocumentVerificationViewController{
            vc.delegate = self
           
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func userFinishCapturingDocumentsWithResponse(documents: [GatetoPayOnboardingDocument], response: DocumentVerificationResponse) {
        print("\(response)")
        Dialogs.dismiss()
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "OCRDataResponseViewController") as? OCRDataResponseViewController{
            vc.documentsObject = response
            vc.nationalitiesResponse = self.nationalitiesResponse
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func userFinishCapturingDocumentsWithError(documents: [GatetoPayOnboardingDocument]) {
        Dialogs.showError("Error", duration: 3)
    }
    
    func userDidCloseCamera() {
        
    }
    
}

extension CSPDListViewController: SelfieConfirmationDelegate{
    func userDidVerifySelfie() {
        Dialogs.showLoading()
        GatetoPayOnboarding.documentsCheck.extractData()
    }
    
    func userDidSelectToRetakeSelfie() {
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    
}


extension CSPDListViewController: GatetoPayOnboardingLivenessCheckDelegate{
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
                GatetoPayOnboarding.livenessCheck.checkLiveness(viewController: self, detectOptions: [.blink, .lookRight, .lookLeft], isDetectionOptionsSorted: true)
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


extension CSPDListViewController: GatetoPayOnboardingKYCDelegate {
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
