import UIKit
import GatetoPayOnboardingSDK
enum sectionType: Int, CaseIterable {
    case extractedData
    case validationData
}

class OCRDataResponseViewController: UIViewController {

    /**
     This class for ....
     */
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var finalResult: UILabel!
    
    
    //MARK: - Variables
    var documentsObject :DocumentVerificationResponse?
    var passedCount = 0
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
        tableView.register(UINib(nibName: "OCRResponseTableViewCell", bundle: nil), forCellReuseIdentifier: "OCRResponseTableViewCell")
        tableView.register(UINib(nibName: "OCRHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "OCRHeaderView")
        tableView.delegate = self
        tableView.dataSource = self
        
        calculatePassedChecks()
        finalResult.text = "Result: \(documentsObject?.validationResult?.result ?? "") | Checks: \(passedCount) / \(documentsObject?.validationResult?.validationChecks?.count ?? 0)"
    }
    
    func calculatePassedChecks() {
        if let checksArray = documentsObject?.validationResult?.validationChecks {
            for obj in checksArray {
                if obj.result?.lowercased() == "passed" {
                    passedCount += 1
                }
            }
        }
       
    }
    
    
    //MARK: - Actions
    @IBAction func submitButtonAction(_ sender: Any) {
       
        if isLivenessEnabled {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "SelfieInstructionsViewController") as? SelfieInstructionsViewController {
               
                vc.nationalitiesResponse = self.nationalitiesResponse
                self.navigationController?.pushViewController(vc, animated: true)
            }
           
        } else {
            Dialogs.showLoading()
            GatetoPayOnboarding.kyc.delegate = self
            GatetoPayOnboarding.kyc.getKYCFields(fieldValues: [] , productId: productIdForKYC ?? 0)
        }
        

    }
    
    //MARK:-Functions
}
extension OCRDataResponseViewController: GatetoPayOnboardingKYCDelegate {
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

extension OCRDataResponseViewController: StatusDelegate{
    func didPressNext() {
            self.navigationController?.popToRootViewController(animated: true)
    }
}

extension OCRDataResponseViewController: UITableViewDelegate,UITableViewDataSource {
    //MARK: - TableView DataSource and Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (sectionType(rawValue: section)).unsafelyUnwrapped {
        case .extractedData:
            return documentsObject?.extractedFields?.count ?? 0
        case .validationData:
            return documentsObject?.validationResult?.validationChecks?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      
        if let headerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "OCRHeaderView" ) as? OCRHeaderView {
            
            switch (sectionType(rawValue: section)).unsafelyUnwrapped {
            case .extractedData:
                headerView.nameLabel.text = "Extraction Field Name"
                headerView.valueLabel.text = "Extraction Field Value"
            case .validationData:
                headerView.nameLabel.text = "Validation Field Name"
                headerView.valueLabel.text = "Validation Field Value"
            }
            
            return headerView
        }

        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "OCRResponseTableViewCell", for: indexPath) as? OCRResponseTableViewCell{
            
            switch (sectionType(rawValue: indexPath.section)) {
                
            case .extractedData:
                if let extractedFields = documentsObject?.extractedFields?[indexPath.row] {
                    cell.fieldNameLabel.text = extractedFields.name
                    cell.fieldValueLabel.text = extractedFields.value
                    cell.resultStackView.isHidden = true
                }
            case .validationData:
                if let validationField = documentsObject?.validationResult?.validationChecks?[indexPath.row] {
                    cell.fieldNameLabel.text = validationField.name
                    cell.fieldValueLabel.text = validationField.value
                    cell.resultStackView.isHidden = false
                    cell.resultLabel.text = validationField.result
                }
            default:
                break
                
            }
           
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
