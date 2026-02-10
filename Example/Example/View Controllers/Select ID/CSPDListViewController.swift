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
    var customerIdentityType : String?
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

                self.customerIdentityType = selectedItem.title ?? ""
              
            },
            cancel: {
                print("Dropdown selection canceled")
            }
        )
    }

    
    @IBAction func NextButton(_ sender: Any) {
        
        guard let identityType = customerIdentityType,
              !identityType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            
            Dialogs.showError("Please select your ID type")
            return
        }
        
        GatetoPayOnboarding.cspdData.delegate = self
        GatetoPayOnboarding.cspdData.getProductByIdType(
            riskLevel: risklevel ?? 0,
            customerIdentityType: identityType
        )
    }
    
}

extension CSPDListViewController : GatetoPayOnboardingCSPDDelegate {
    func productIdForKYCReceived(productId: Int) {
        productIdForKYC = productId
        Dialogs.showLoading()
        GatetoPayOnboarding.verificationJourney.delegate = self
        GatetoPayOnboarding.verificationJourney.startVerification(applicationLanguage: "en", nationality: "Jordanian")
        
    }
    
    func productIdForKYCFinishedWithError(error: GatetoPayOnboardingError) {
        Dialogs.showError(error.errorString)

    }
}
extension CSPDListViewController : VerificationJourneyDelegate {
    func onJourneyStarted(journeyId: String) {
        
    }
    
    func onJourneyResumed(journeyId: String) {
        
    }
    
    func onJourneyCompleted(journeyId: String) {
        GatetoPayOnboarding.kyc.delegate = self
        Dialogs.showLoading()
        GatetoPayOnboarding.kyc.getKYCFields(fieldValues: [] , productId: productIdForKYC ?? 0)
    }
    
    func onJourneyCancelled(journeyId: String, cancellationReason: String) {
        
    }
    
    func onJourneyBlocked(journeyId: String, blockReasonMessage: String) {
        
    }
    
    func onJourneyError(error: String) {
        Dialogs.showError(error)
    }
    
    func checkIsMobileJourneyFailed(error: GatetoPayOnboardingSDK.GatetoPayOnboardingError) {
        Dialogs.showError(error.errorString)
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
                Dialogs.showLoading()
                GatetoPayOnboarding.verificationJourney.delegate = self
                GatetoPayOnboarding.verificationJourney.startVerification(applicationLanguage: "en", nationality: "Jordanian")
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
                Dialogs.showLoading()
                GatetoPayOnboarding.verificationJourney.delegate = self
                GatetoPayOnboarding.verificationJourney.startVerification(applicationLanguage: "en", nationality: "Jordanian")
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
