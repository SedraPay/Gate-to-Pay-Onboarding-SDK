<p align="center">
  <img src="https://github.com/SedraPay/Gate-to-Pay-Onboarding-SDK/blob/main/gatetopay.png" alt="Icon"/>
</p>
<H1 align="center">Gate to Pay Onboarding SDK</H1>

The new eKYC in simple way.

`Gate to Pay Onboarding SDK` is between your hands to help you onboard your customer easily with almost no effort.

## Screenshot
[![GatetoPayOnboardingSDK](https://github.com/SedraPay/Gate-to-Pay-Onboarding-SDK/blob/main/screenshot.png)](https://youtu.be/8oehz24fXI4)





## Requirements
[![Platform iOS](https://img.shields.io/badge/Platform-iOS-blue.svg?style=fla)]()



## Installation
==========================

Gate to Pay Onboarding SDK is available through [CocoaPods](https://github.com/SedraPay/Gate-to-Pay-Onboarding-SDK). To install
it, simply add the following line to your Podfile:

```ruby
pod 'GatetoPayOnboardingSDK'

#also add this
post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
            config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        end
    end
end
```

Then install it in terminal using below lines:

pod install

-- OR --

pod install --repo-update


## Add below line into your Info.plist

```xml
<key>NSCameraUsageDescription</key>
<string>$(PRODUCT_NAME) {camera usage description and why the app needs to use it}.</string>
```


### Lets Start coding

## First step is required to have so you will create session and can use below steps

###### Create Journey ######

```swift
import GatetoPayOnboardingSDK

//Mandatory step to add

override func viewDidLoad(){
    super.viewDidLoad()
    
    //assign the delegate to your viewController
    GatetoPayOnboardingSDK.shared.delegate = self
    
/// This function is required to initialize the SDK correctly.
/// You must provide all parameters to ensure proper functionality.
///
/// - Parameters:
///   - serverKey: The key provided to you from the portal.
///   - serverURLString: The base URL provided by the sales team.
///   - nationalNumber: Required so the backend can communicate with Civil Status Authority to retrieve user information.
///   - riskFormId: Used to fetch the first request which contains the risk form data.
///   - applicationId: 

GatetoPayOnboardingSDK.shared.setSettings(
    serverKey: "<YOUR_SERVER_KEY>",
    serverURLString: "<YOUR_GIVEN_SERVER_URL>",
    nationalNumber: "<USER_NATIONAL_NUMBER>",
    riskFormId: "<RISK_FORM_ID>",
    applicationId: ""
)
}


extension <YOUR_VIEW_CONTROLLER>: GatetoPayOnboardingJourneyDelegate{
    func didFinishCreatingJourneyWithError(error: GatetoPayOnboardingCheckError){
        //do your own code as:
        //dismiss dialogs, loadings
        //recall the function
    }
    
    func didFinishCreatingJourneyWithSuccess(journeyId: String, isDocumentVerification: Bool, isLiveness: Bool, isFaceMatching: Bool) {
        //do your own code as:
        //dismiss dialog, loadings
        //save the journey if needed as a reference to your server to check user from our protal
         GatetoPayOnboarding.riskForm.delegate = self
         GatetoPayOnboarding.riskForm.getRiskFields(fieldValues: [])
    }
}


Enable / Disable OCR

You can enable or disable the OCR feature for all forms.

@IBAction func enableOCRSwitchAction(_ sender: UISwitch) {
    sender.isOn ?
      GatetoPayOnboarding.shared.setOCREnabled(true) :
      GatetoPayOnboarding.shared.setOCREnabled(false)
}

If set to true → OCR will be enabled and applied on all forms.
If set to false → OCR will be applied only if the form itself supports OCR, otherwise it will be skipped.

```
###### END OF CREATE JOURNEY ######


###### GatetoPayOnboarding Risk Form Flow ######

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    GatetoPayOnboarding.riskForm.delegate = self
    
    // Request dynamic risk form fields
    GatetoPayOnboarding.riskForm.getRiskFields(fieldValues: [])
}


@IBAction func nextButton(_ sender: UIButton) {
    Dialogs.showLoading()
    
    // Submit updated risk form data
    GatetoPayOnboarding.riskForm.updateRiskData(
        riskFields: sectionsArray ?? []
    )
}



extension <YOUR_VIEW_CONTROLLER>: GatetoPayOnboardingRiskFormDelegate {

    /// Called when updating the Risk Form fails
    func updateRiskFormFinishedWithError(error: String) {
        Dialogs.dismiss()
        // Handle retry or show a proper message to the user
    }

    /// Called when updating the Risk Form succeeds
    func didUpdateRiskFormSuccessfully(riskLevel: Int?) {
        Dialogs.dismiss()
        
        // Save riskLevel for later usage when submitting getProductByIdType API
        
        GatetoPayOnboarding.cspdData.delegate = self
        
        if let sections = sectionsArray {
            let allFields = sections.flatMap { $0.dynamicFields ?? [] }

            let nationality = allFields.first {
                $0.fieldLabel == "Nationality"
            }?.value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            let residency = allFields.first {
                $0.fieldLabel == "Country of Residency" ||
                $0.fieldLabel == "Country Of Residency"
            }?.value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            guard !nationality.isEmpty, !residency.isEmpty else {
                print("Nationality or residency is empty — skipping CSPD API call")
                return
            }

            GatetoPayOnboarding.cspdData.getCSPDTypes(
                nationality: nationality,
                residency: residency
            )
        }
    }

    /// Called when retrieving Risk Form fields fails
    func riskFormFinishedWithError(error: GatetoPayOnboardingError) {
        Dialogs.dismiss()
        Dialogs.showError(error.localizedDescription)
    }

    /// Called when Risk Form dynamic fields are successfully retrieved
    func riskFormFields(fields: [GatetoPayOnboardingKYCFieldItem]) {
        Dialogs.dismiss()
        
        var array: [GatetoPayOnboardingKYCDynamicField] = []
        
        fields.forEach { item in
            if let items = item.dynamicFields {
                array.append(contentsOf: items)
            }
        }
        
        // `array` now contains all dynamic fields to display in your UI
        // Please store it into sectionsArray to submit it later
    }
}

```

###### GatetoPayOnboarding CSPD Flow ######
```swift

      @IBAction func NextButton(_ sender: Any) {
        GatetoPayOnboarding.cspdData.delegate = self
        GatetoPayOnboarding.cspdData.getProductByIdType(riskLevel: risklevel ?? 0, customerIdentityType: self.customerIdentityType ?? 0)
    } 
   extension <YOUR_VIEW_CONTROLLER>: GatetoPayOnboardingDSPDDelegate {
    
    
    func cspdTypesReceived(types: [CSPDType]){
          //do your own code as:
         //dismiss dialogs, loadings
         //recall the function
    }
    
    
    
    func cspdTypesFinishedWithError(error: GatetoPayOnboardingError){
        Dialogs.dismiss()
        Dialogs.showError(error.localizedDescription)
    }
    
    
    func productIdForKYCReceived(productId: Int) {
        productIdForKYC = productId
        if !isDocumentVerificationEnabled && !isLivenessEnabled {
            GatetoPayOnboarding.kyc.delegate = self
            Dialogs.showLoading()
            GatetoPayOnboarding.kyc.getKYCFields(fieldValues: [] , productId: productIdForKYC ?? 0)
           
        }
        else if isDocumentVerificationEnabled {
        
              GatetoPayOnboarding.documentsCheck.captureDocuments(documentType: .id, configuration: configuration)

        }
        else if isLivenessEnabled && !isDocumentVerificationEnabled {
            GatetoPayOnboarding.livenessCheck.checkLiveness(viewController: self, detectOptions: [.blink, .lookRight, .lookLeft], isDetectionOptionsSorted: true)
            GatetoPayOnboarding.livenessCheck.delegate = self
        }
    }
    
    func productIdForKYCFinishedWithError(error: GatetoPayOnboardingError) {
        Dialogs.showError(error.errorString)

    }
    
  
```

###### GatetoPayOnboarding KYC  ######

To handle the KYC flow, you need to conform to the GatetoPayOnboardingKYCDelegate protocol.
```swift
extension <YOUR_VIEW_CONTROLLER>: GatetoPayOnboardingKYCDelegate {

    // Called when updating KYC fails
    func updateKYCFinishedWithError(error: String) {
          //do your own code as:
         //dismiss dialogs, loadings
         //recall the function
    }
    
    // Called when updating KYC succeeds
    func didUpdateKYCSuccessfully(id: Int?) {
         //do your own code as:
         //dismiss dialogs, loadings
         //recall the function
    }
    
    // Called when KYC request fails
    func kycFinishedWithError(error: GatetoPayOnboardingError) {
        Dialogs.dismiss()
        Dialogs.showError(error.localizedDescription)
    }
    
    // Called when KYC dynamic fields are returned
    func kycFields(fields: [GatetoPayOnboardingKYCFieldItem]) {
        Dialogs.dismiss()
        
        /// This will return all dynamic fields from the SDK.
        /// You can use them to render your own KYC form dynamically.
        var array: [GatetoPayOnboardingKYCDynamicField] = []
        
        for item in fields {
            if let items = item.dynamicFields {
                for object in items {
                    array.append(object)
                }
            }
        }
        
        // Now `array` contains all dynamic fields to display in your UI.
    }
}
```
#### Countries and Cities

Call this method only once and cache the response (countries and cities) locally.
This data will be used later in the KYC screen to handle data types like country and countryCity.

```swift
extension <YOUR_VIEW_CONTROLLER>: GatetoPayOnboardingCountriesDelegate {

  func loadCountries() {
    GatetoPayOnboarding.countries.delegate = self
    GatetoPayOnboarding.countries.getNationalities()
  }

  func didGetNationalitiesWithSuccess(response: CountriesAndCitiesResponse) {
    // use response (countries, cities)
  }

  func didGetNationalitiesWithError(error: GatetoPayOnboardingError) {
    // handle error
  }
}
```

###### GatetoPayOnboarding Dynamic Fields ######

Both FormInfofields(fields: [IntegrationInfo]) and kycFields(fields: [GatetoPayOnboardingKYCFieldItem]) can return dynamic fields.

The possible field types are:
```swift
 GatetoPayOnboardingKYCFieldType {
    case textField = 1          // Simple text input
    case dropdown = 2           // Select from multiple options
    case checkbox = 3           // Tick multiple options
    case radioButton = 4        // Select one option
    case dateTime = 5           // Pick a date or time
    case boolean = 6            // True/False toggle
    case file = 7               // Upload file
    case image = 8              // Upload image
    case country = 9            // Country picker
    case city = 10              // City picker
    case table = 11             // Table input
    case textArea = 12          // Multi-line text
    case email = 13             // Email input
    case mobile = 14            // Phone number input
    case number = 15            // Numeric input
    case address = 16           // Address input
    case textEditor = 17        // Rich text editor
    case yesNo = 18             // Yes/No option
    case countryandcity = 19    // Country and city combined
}

```

###### GatetoPayOnboarding Check ######

If you need to let the user capture the document (id, passport), use below code:

```swift

//put this code when you need to capture the document.
@objc func myButtonAction(_ sender: UIButton){
    GatetoPayOnboarding.documentsCheck.delegate = self

    /// Below function is for ocr the document and get the information of the user.
    /// - Parameters:
    ///   - documentType: this is an enum (.id, .passport)
    ///   - configuration: of type ConfigureScanDocumentsViews whitch contains 3 objects type will be declared down 

    GatetoPayOnboarding.documentsCheck.captureDocuments(documentType: .id, configuration: configuration)
}

extension <YOUR_VIEW_CONTROLLER>: GatetoPayOnboardingDocumentsDelegate{
    func userDidCloseCamera(){
    
    }
    func userFinishCapturingDocument(documents: [GatetoPayOnboardingDocument]){
    
    }
    func userFinishCapturingDocumentsWithResponse(documents: [GatetoPayOnboardingDocument], response: GatetoPayOnboardingDocumentVerificationResponse){
    
    }
    func userFinishCapturingDocumentsWithError(documents: [GatetoPayOnboardingDocument], , error: GatetoPayOnboardingError){
    
    }
    func didFinishWithError(error: GatetoPayOnboardingError){

    }
    func userFinishCapturingDocumentsWithError(documents: [GatetoPayOnboardingDocument]) {
        
    }
}
```
###### END OF GatetoPayOnboarding CHECK ######

###### GatetoPayOnboarding Configuration ######
If you need to configure the Documents Pages, use below code:
```swift
/// ConfigureDocumentsCameraPage: this is the first object which configure all attributes in the Camera Page, use below code with default values:

public struct ConfigureDocumentsCameraPage {
    //Camera Page Attributes
    public var cameraViewBackgroundColor: UIColor? = .black
    public var topHintCameraLabelColor:UIColor? = .white
    public var topHintCameraLabelTitle:String? = NSLocalizedString("Please get close to the ID/Passport so it would fill the empty area", comment: "")
    public var topHintCameraIsHidden:Bool? = false
    public var topHintCameraLabelNumberOfLines:Int? = 0
    
    public var frontIDLabelColor:UIColor? = .white
    public var frontIDLabelTitle:String? =  NSLocalizedString("Scan your ID front face", comment: "")
    public var frontIDIsHidden:Bool? = false
    
    public var backIDLabelColor:UIColor? = .white
    public var backIDLabelTitle:String? =  NSLocalizedString("Scan your ID Back face", comment: "")
    public var backIDIsHidden:Bool? = false
    
    public var passportLabelColor:UIColor? = .white
    public var passportLabelTitle:String? =  NSLocalizedString("Scan your passport", comment: "")
    public var passportIsHidden:Bool? = false
    
    public var frontDrivingLicenseLabelColor:UIColor? = .white
    public var frontDrivingLicenseLabelTitle:String? =  NSLocalizedString("Scan your Driving front face", comment: "")
    public var frontDrivingLicenseIsHidden:Bool? = false
    
    public var backDrivingLicenseLabelColor:UIColor? = .white
    public var backDrivingLicenseLabelTitle:String? =  NSLocalizedString("Scan your Driving back face", comment: "")
    public var backDrivingLicenseIsHidden:Bool? = false
    
    public var documentTypeLabelNumberOfLines:Int? = 0
    public var fontNameAndSize: UIFont? = .systemFont(ofSize: 13)
    
    public var captureButtonImage: UIImage? = nil
    public var captureButtonImageURL: String? = ""
    public var captureButtonIsHidden:Bool? = false
    public var captureButtonTitle:String? = ""
    public var captureButtonColor:UIColor? = .clear
    public var captureButtonFontColor:UIColor? = .white
    public var captureButtonFontNameAndSize:UIFont? = .systemFont(ofSize: 13)
    public var captureButtonImageTintColor:UIColor? = .white
    
    public var closeButtonImageURL:String? = ""
    public var closeButtonImage:UIImage? = nil
    public var closeButtonIsHidden:Bool? = false
    public var closeButtonTitle:String? = ""
    public var closeButtonColor:UIColor? = .clear
    public var closeButtonFontColor:UIColor? = .white
    public var closeButtonFontNameAndSize:UIFont? = .systemFont(ofSize: 13)
    public var closeButtonImageTintColor:UIColor? = .white
    
    public var flashButtonImageURL:String? = ""
    public var flashButtonImage:UIImage? = nil
    public var flashButtonIsHidden:Bool? = false
    public var flashButtonTitle:String? = ""
    public var flashButtonColor:UIColor? = .clear
    public var flashButtonFontColor:UIColor? = .white
    public var flashButtonFontNameAndSize:UIFont? = .systemFont(ofSize: 13)
    public var flashButtonImageTintColor:UIColor? = .white
    }
 
 ```
 
 ```swift
/// ConfigureDocumentsEditPage: this is the second object which configure all attributes in the edit Page, use below code with default values:

public struct ConfigureDocumentsEditPage {
    public var editPageBackgroundColor: UIColor? = .black
    public var outlinesCroppingColor:UIColor? = .red
    
    public var backButtonImage:UIImage? = nil
    public var backButtonImageURL:String? = ""
    public var backButtonTitle:String? = ""
    public var backButtonIsHidden:Bool? = false
    public var backButtonColor:UIColor? = .clear
    public var backButtonFontColor:UIColor? = .white
    public var backButtonFontNameAndSize:UIFont? = .systemFont(ofSize: 13)
    public var backButtonImageTintColor:UIColor? = .white
    
    public var cropButtonImage:UIImage? = nil
    public var cropButtonImageURL:String? = ""
    public var cropButtonTitle:String? = ""
    public var cropButtonIsHidden:Bool? = false
    public var cropButtonColor:UIColor? = .clear
    public var cropButtonFontColor:UIColor? = .white
    public var cropButtonFontNameAndSize:UIFont? = .systemFont(ofSize: 13)
    public var cropButtonImageTintColor:UIColor? = .white
    }
 ```
 
 ```swift
/// ConfigureDocumentsPreviewPage: this is the third object which configure all attributes in the preview Page, use below code with default values:
 
 public struct ConfigureDocumentsPreviewPage {
    public var previewPageBackgroundColor: UIColor? = .black
    
    public var reviewLabelTitle:String? = ""
    public var reviewLabelColor:UIColor = .white
    public var reviewLabelNumberOfLine:Int? = 0
    public var reviewLabelIsHidden:Bool? = false
    
    public var editScanButtonImage:UIImage? = nil
    public var editScanButtonImageURL:String? = ""
    public var editScanButtonTitle:String? = ""
    public var editScanButtonIsHidden:Bool? = false
    public var editScanButtonColor:UIColor? = .clear
    public var editButtonFontColor:UIColor? = .white
    public var editButtonFontNameAndSize:UIFont? = .systemFont(ofSize: 13)
    public var editScanButtonImageTintColor:UIColor? = .white
    
    public var confirmButtonImage:UIImage? = nil
    public var confirmButtonImageURL:String? = ""
    public var confirmButtonTitle:String? = ""
    public var confirmButtonIsHidden:Bool? = false
    public var confirmScanButtonColor:UIColor? = .clear
    public var confirmButtonFontColor:UIColor? = .white
    public var confirmButtonFontNameAndSize:UIFont? = .systemFont(ofSize: 13)
    public var confirmScanButtonImageTintColor:UIColor? = .white
    
    public var rotateButtonImage:UIImage? = nil
    public var rotateButtonImageURL:String? = ""
    public var rotateButtonTitle:String? = ""
    public var rotateButtonIsHidden:Bool? = false
    public var rotateScanButtonColor:UIColor? = .clear
    public var rotateButtonFontColor:UIColor? = .white
    public var rotateButtonFontNameAndSize:UIFont? = .systemFont(ofSize: 13)
    public var rotateScanButtonImageTintColor:UIColor? = .white
    }
```

###### END OF GatetoPayOnboarding CHECK ######

###### GatetoPayOnboarding Liveness Check ######

If you need to check user liveness and take a selfie, use below code:

```swift

//put this code when you need to check liveness.
@objc func myButtonAction(_ sender: UIButton){
        GatetoPayOnboarding.livenessCheck.delegate = self


    /// Below function is for checking the liveness of the user and take a photo for the user.
    /// - Parameters:
    ///   - viewController: current viewController
    ///   - detectOptions: array of side(detection) options enum [.blink, .smile, .lookRight, .lookLeft] 

        GatetoPayOnboarding.livenessCheck.checkLiveness(viewController: vc, detectOptions: [.blink])

}

extension <YOUR_VIEW_CONTROLLER>: GatetoPayOnboardingCheckLivenessCheckDelegate{
    func didPressCancel(){
    
    }
    func didGetImageSuccessfully(data: UIImage){
    
    }
    func didGetImageMatchingResponseSuccessfully(response: ImageMatchingResponse){
    
    }
    func didGetError(errorMessage: String){
    
    }
    func LivenessCheckPageError(error: GatetoPayOnboardingCheckError){
        
    }
    func LivenessCheckDone(){
    
    }
    func cameraAccessDeniedError(error: GatetoPayOnboardingError){
    
    }
    
}
```
###### END OF SEDRA LIVENESS CHECK ######


###### GatetoPayOnboarding Comply ######


```swift

//put this code when you need to check your user in the world check.
@objc func myButtonAction(_ sender: UIButton){
    GatetoPayOnboardingCheck.comply.delegate = self

    /// Below function is for screening and checking the customer.
    /// - Parameters:
    ///   - firstName: enter the first name of the user <Required>
    ///   - secondName: enter the second name of the user <Optional>, leave empty string if not needed
    ///   - thirdName: enter the third name of the user <Optional>, leave empty string if not needed
    ///   - lastName: enter the last name of the user <Required>

    GatetoPayOnboarding.comply.screenCustomer(firstName: "<FIRST_NAME_HERE>",
                                    secondName: "<SECOND_NAME_HERE>",
                                    thirdName: "<THIRD_NAME_HERE>",
                                    lastName: "<LAST_NAME_HERE>")
}

extension <YOUR_VIEW_CONTROLLER>: GatetoPayOnboardingComplyDelegate{
    func screeningFinishedWithSuccess(response: GatetoPayOnboardingScreeningResponse){
        //do your code here
    }
    
    func screeningFinishedWithError(message: GatetoPayOnboardingError){
        //do your code here
    }
}
```
###### END OF APYAN COMPLY ######

###### Close Journey ######

```swift
extension <YOUR_VIEW_CONTROLLER>:  GatetoPayOnboardingCloseJourneyDelegate {
  override func viewDidLoad(){
    super.viewDidLoad()
    GatetoPayOnboarding.closeJourney.delegate = self
    GatetoPayOnboarding.closeJourney.closeJourneyAPI(customerId: "unique-customer-id")
  }
  func didFinishCloseJourneyWithSuccess() { 
        //do your own code as:
        //dismiss dialogs, loadings
        //recall the function
  }
  func didFinishCloseJourneyWithError(error: GatetoPayOnboardingError) { 
         //do your own code as:
         //dismiss dialogs, loadings
         //recall the function
}
}
```

Localization
==========================
Check localizable.string file in the project and translate it in the way you love.


Contact Us & Report a Bug
==========================

If you have any questions or you want to contact us, visit our website.

https://sedracheck.sedrapay.com/


--- OR ---

Contact us via email mob@sedrapay.com

