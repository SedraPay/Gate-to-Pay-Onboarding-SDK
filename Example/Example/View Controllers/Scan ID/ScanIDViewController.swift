import UIKit
import DropDown
import GatetoPayOnboardingSDK

enum IDTypesEnum1: String{
    case id = "National ID"
    case passport = "Passport"
    case drivingLicense = "Driving License "
}

enum ScanIDPageTypeEnum: Int{
    case nationality
    case documentType
}

struct ScanIDPageDocumentObject{
    var type: IDTypesEnum1?
    var image: UIImage?
}

class ScanIDViewController: UIViewController {

    
    /**
     This class for ....
     */
    
    //MARK: - Outlets
    @IBOutlet weak var theTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.register(UINib.init(nibName: "ScanIDCountryTableViewCell", bundle: nil), forCellReuseIdentifier: "ScanIDCountryTableViewCell")
            tableView.register(UINib.init(nibName: "ScanIDTypeTableViewCell", bundle: nil), forCellReuseIdentifier: "ScanIDTypeTableViewCell")
        }
    }
    @IBOutlet weak var bottomButton: FAButton!
    
    
    //MARK: - Variables
    var pageType: ScanIDPageTypeEnum?
    var documentTypesArray: [ScanIDPageDocumentObject]?
    var nationalitiesResponse:CountriesAndCitiesResponse?
    var selectedNationality:String?
    var idTypesArray: [NationalityIDType]?
    var selectedProduct:Int?
    var formDataValueArray: [formDataValueFields] = []

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
        bottomButton.isHidden = pageType == .documentType
        theTitleLabel.text = pageType == .documentType ? "Select ID type" : "Select your nationality"

        documentTypesArray = [ScanIDPageDocumentObject.init(type: .id, image: UIImage.init(named: "nationalIDIcon")),
                              ScanIDPageDocumentObject.init(type: .passport, image: UIImage.init(named: "passport"))]
        idTypesArray = []
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    //MARK: - Actions
    @IBAction func bottomButtonAction(_ sender: Any) {
        if pageType == .nationality{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "ScanIDViewController") as? ScanIDViewController{
                vc.pageType = .documentType
                vc.selectedNationality = self.selectedNationality
                vc.nationalitiesResponse = self.nationalitiesResponse
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    @objc func flagButtonAction(_ sender: UIButton){
//        let dropDown = DropDown()
//
//        // The view to which the drop down will appear on
//        if let cell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? ScanIDCountryTableViewCell{
//            dropDown.anchorView =  cell.mainView// UIView or UIBarButtonItem
//        }
//        
//        dropDown.direction = .bottom
//      
//        // The list of items to display. Can be changed dynamically
//        if let nationalities = nationalitiesResponse?.nationalities
//          {
//            var sorted = nationalities.sorted(by: {$0.name ?? "" < $1.name ?? ""})
//            if let index = sorted.firstIndex(where: {$0.isoCode?.lowercased() == "sar"}) {
//                let item = sorted[index]
//                sorted.remove(at: index)
//                sorted.insert(item, at: 0)
//            }
//            for obj in sorted{
//                dropDown.dataSource.append(obj.name ?? "")
//                
//            }
//        }
//        
//        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
//            if let cell = self.tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? ScanIDCountryTableViewCell{
//                cell.nationalityLabel.text = item
//            }
//            
//            dropDown.hide()
//        }
//        
//        dropDown.show()
    }
    
    
    //MARK:-Functions
    
    
}


extension ScanIDViewController: UITableViewDelegate, UITableViewDataSource{
    
    //MARK: - TableView DataSource and Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        idTypesArray = nationalitiesResponse?.nationalities?.filter({$0.name?.lowercased() == self.selectedNationality?.lowercased()}).first?.nationalityIDTypes
        
        return pageType == .nationality ?  1 : (documentTypesArray?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch pageType{
        case .nationality:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ScanIDCountryTableViewCell", for: indexPath) as? ScanIDCountryTableViewCell{
                cell.flagButton.setTitle("🇯🇴", for: .normal)
                cell.nationalityLabel.text = "Jordanian"
                self.selectedNationality = cell.nationalityLabel.text
                //cell.flagButton.addTarget(self, action: #selector(flagButtonAction(_:)), for: .touchUpInside)
                return cell
            }
        case .documentType:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ScanIDTypeTableViewCell", for: indexPath) as? ScanIDTypeTableViewCell{
                
//                let idType = idTypesArray?[indexPath.row]
//                if  idType?.name == .idCard {
//                    cell.theImageView.image = documentTypesArray?.filter({$0.type == .id}).first?.image
//                } else {
//                    cell.theImageView.image = documentTypesArray?.filter({$0.type == .passport}).first?.image
//                }
                cell.theImageView.image = documentTypesArray?[indexPath.row].image
                cell.theTitleLabel.text = documentTypesArray?[indexPath.row].type?.rawValue
                
                return cell
            }
            
        default:
            return UITableViewCell()
        }
        
        
        
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if pageType == .documentType {
            let type : DocumentTypeEnum = indexPath.row == 0 ? .id : indexPath.row == 1 ? .passport : .drivingLicense
            let confiureCameraPage = ConfigureDocumentsCameraPage(cameraViewBackgroundColor: UIColor.black,
                                                                             topHintCameraLabelColor: UIColor.white,
                                                                  topHintCameraLabelTitle: "Camera",
                                                                             topHintCameraIsHidden: false,
                                                                             topHintCameraLabelNumberOfLines: 1,
                                                                  captureButtonImage: UIImage(named: "cameraIcons"))
            let configuration = ConfigureScanDocumentsViews(ConfigureDocumentsCameraPage: confiureCameraPage)
            
            GatetoPayOnboarding.documentsCheck.captureDocuments(documentType:  NationalityIDType(typeID: indexPath.row == 0  ? 1 : 2 , name: indexPath.row == 0  ?  .idCard : .passport , numberOfImages: indexPath.row == 0  ? 2 : 1) , configuration: configuration)
                GatetoPayOnboarding.documentsCheck.delegate = self
        }
        else{
            let dropDown = DropDown()
            // The view to which the drop down will appear on
            if let cell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? ScanIDCountryTableViewCell{
                dropDown.anchorView =  cell.mainView// UIView or UIBarButtonItem
            }
            
            dropDown.direction = .bottom
          
            // The list of items to display. Can be changed dynamically
            if let nationalities = nationalitiesResponse?.countries
              {
                var sorted = nationalities.sorted(by: {$0.name ?? "" < $1.name ?? ""})
                if let index = sorted.firstIndex(where: {$0.iso?.lowercased() == "jor"}) {
                    let item = sorted[index]
                    sorted.remove(at: index)
                    sorted.insert(item, at: 0)
                }
                for obj in sorted{
                    dropDown.dataSource.append(obj.name ?? "")
                    
                }
            }
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                if let cell = self.tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? ScanIDCountryTableViewCell{
                    cell.nationalityLabel.text = item
                    self.selectedNationality = item
                }
                dropDown.hide()
            }
            dropDown.show()
        }
    }
}



extension ScanIDViewController: GatetoPayOnboardingDocumentsDelegate{
    func didFinishWithError(error: GatetoPayOnboardingError) {
        Dialogs.dismiss()
        Dialogs.showError(error.errorString)
    }
    
    func userFinishCapturingDocumentsWithError(documents: [GatetoPayOnboardingDocument], error: GatetoPayOnboardingError) {
        Dialogs.dismiss()
        Dialogs.showError(error.errorString)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
              if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                  navigationController.popViewController(animated: true)
              }
          }
    }
    
    func userFinishCapturingDocument(documents: [GatetoPayOnboardingDocument]) {
        Dialogs.dismiss()
        if let vc = storyboard?.instantiateViewController(withIdentifier: "DocumentVerificationViewController") as? DocumentVerificationViewController{
            vc.delegate = self
           
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func userFinishCapturingDocumentsWithResponse(documents: [GatetoPayOnboardingDocument], response: DocumentVerificationResponse) {
        Dialogs.dismiss()
        
        if response.validationResult?.result?.lowercased() != "passed"{
            let alert = UIAlertController(
                title: "Warning",
                message: "Your images are not clear and might cause a failed update.",
                preferredStyle: .alert
            )

            let continueAction = UIAlertAction(title: "Continue Anyway", style: .default) { _ in
                
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "OCRDataResponseViewController") as? OCRDataResponseViewController{
                    vc.documentsObject = response
                    vc.selectedProduct = self.selectedProduct
                    vc.formDataValueArray = self.formDataValueArray
                    vc.nationalitiesResponse = self.nationalitiesResponse
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }

            let retakeAction = UIAlertAction(title: "Retake", style: .cancel) { _ in
                // Handle retake action here
                
                if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                    navigationController.popViewController(animated: true)
                }
            }

            alert.addAction(continueAction)
            alert.addAction(retakeAction)

            present(alert, animated: true, completion: nil)

        } else {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "OCRDataResponseViewController") as? OCRDataResponseViewController{
                vc.documentsObject = response
                vc.selectedProduct = self.selectedProduct
                vc.formDataValueArray = self.formDataValueArray
                vc.nationalitiesResponse = self.nationalitiesResponse
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    func userFinishCapturingDocumentsWithError(documents: [GatetoPayOnboardingDocument]) {
        Dialogs.dismiss()
        Dialogs.showError("Error", duration: 3)
    }
    
    func userDidCloseCamera() {
        
    }
    
}

extension ScanIDViewController: SelfieConfirmationDelegate{
    func userDidVerifySelfie() {
        Dialogs.showLoading()
        GatetoPayOnboarding.documentsCheck.extractData()
    }
    
    func userDidSelectToRetakeSelfie() {
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    
}
