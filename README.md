<p align="center">
  <img src="https://github.com/SedraPay/Gate-to-Pay-Onboarding-SDK/blob/main/gatetopay.png" alt="Icon"/>
</p>
<H1 align="center">AbyanCheck</H1>

The new eKYC in simple way.

`AbyanCheck` is between your hands to help you onboard your customer easily with almost no effort.

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
import Abyan

//Mandatory step to add

override func viewDidLoad(){
    super.viewDidLoad()
    
    //assign the delegate to your viewController
    Abyan.shared.delegate = self
    
/// Below function is required to continue using the framework, you have to enter all parameters to let the framework works fine
/// - Parameters:
///   - serverKey: this key will be from the portal
///   - serverURLString: the base url that sent to you by sales team
///   - needLog: this will show the errors in the debug
///   - journeyType: this is enum that contains 3 types (.unknown, .new, .update) to show the user is new or updating the profile.
///      If you are not intersted to check the type don't add it or set the type as .unknown

    Abyan.shared.setSettings(serverKey: "<YOUR_SERVER_KEY>", serverURLString: "<YOUR_GIVEN_SERVER>", true, .update) 
}


extension <YOUR_VIEW_CONTROLLER>: AbyanJourneyDelegate{
    func didFinishCreatingJourneyWithError(error: AbyanCheckError){
        //do your own code as:
        //dismiss dialogs, loadings
        //recall the function
    }
    
    func didFinishCreatingJourneyWithSuccess(journeyId: String) {
        //do your own code as:
        //dismiss dialog, loadings
        //save the journey if needed as a reference to your server to check user from our protal
    }
}


Enable / Disable OCR

You can enable or disable the OCR feature for all forms.

@IBAction func enableOCRSwitchAction(_ sender: UISwitch) {
    sender.isOn ?
      Abyan.shared.setOCREnabled(true) :
      Abyan.shared.setOCREnabled(false)
}

If set to true → OCR will be enabled and applied on all forms.
If set to false → OCR will be applied only if the form itself supports OCR, otherwise it will be skipped.

```
###### END OF CREATE JOURNEY ######


###### Abyan Products Flow ######

You can use the Products API to retrieve available products, get their form info, and continue the flow based on whether OCR is required or not.
```swift
override func viewDidLoad(){
    super.viewDidLoad()
    Abyan.product.delegate = self
    Abyan.product.getProducts()
}

@IBAction func nextButton(_ sender: UIButton) {
    Dialogs.showLoading()
    Abyan.product.getFormInfo(productID: self.selectedProduct ?? 0,isOcrEnabled: Abyan.shared.isOCREnabled)
}


extension <YOUR_VIEW_CONTROLLER>: AbyanProductsDelegate {
    
    // Called when products request returns with error
    func productsFinishedWithError(error: AbyanError) {
         //do your own code as:
         //dismiss dialogs, loadings
         //recall the function
    }
    }
    
    // Called when products request returns successfully
    func products(products: ProductsResponse) {
          //do your own code as:
         //dismiss dialogs, loadings
        // handle products response (e.g., show in a list or picker)
    }
    
    // Called when form info fields are received for the selected product
    
  func FormInfofields(fields: [IntegrationInfo]) {
    Dialogs.dismiss()
    
    /// Note:
    /// - The `fields` array contains the form fields for the selected product.
    /// - If `fields` is empty → call `getKYCFields(fieldValues:productId:)` directly
    ///   and send an empty array (`formDataValueFields`) to continue the flow.
    /// - If `fields` is not empty → it may contain dynamic fields that you must fill
    ///   because these dynamic fields need to be sent later when calling the next KYC step.
    
    if Abyan.shared.isOCREnabled == true {
        // OCR is globally forced → always run OCR flow
    } else {
        // OCR depends on form content
    }
}

    // Called when form info is empty → fallback to KYC flow
    func EmptyFormInfofields() {
        Dialogs.dismiss()
        Abyan.kyc.delegate = self
        Dialogs.showLoading()
        Abyan.kyc.getKYCFields(fieldValues:  [formDataValueFields] = [] ,productId: self.selectedProduct ?? 0)
    }
}
```

Explanation:

getProducts() → fetch all available products.
getFormInfo(productID:) → fetch form fields of the selected product.
If OCR is enabled globally → SDK forces OCR in the flow.
If OCR is disabled globally → SDK checks the form; if it contains OCR, it runs OCR, otherwise manual flow.
If form info is empty → SDK falls back to requesting KYC fields.


###### Abyan KYC  ######

To handle the KYC flow, you need to conform to the AbyanKYCDelegate protocol.
```swift
extension <YOUR_VIEW_CONTROLLER>: AbyanKYCDelegate {

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
    func kycFinishedWithError(error: AbyanError) {
        Dialogs.dismiss()
        Dialogs.showError(error.localizedDescription)
    }
    
    // Called when KYC dynamic fields are returned
    func kycFields(fields: [AbyanKYCFieldItem]) {
        Dialogs.dismiss()
        
        /// This will return all dynamic fields from the SDK.
        /// You can use them to render your own KYC form dynamically.
        var array: [AbyanKYCDynamicField] = []
        
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
extension <YOUR_VIEW_CONTROLLER>: AbyanCountriesDelegate {

  func loadCountries() {
    Abyan.countries.delegate = self
    Abyan.countries.getNationalities()
  }

  func didGetNationalitiesWithSuccess(response: CountriesAndCitiesResponse) {
    // use response (countries, cities)
  }

  func didGetNationalitiesWithError(error: AbyanError) {
    // handle error
  }
}
```

###### Abyan Dynamic Fields ######

Both FormInfofields(fields: [IntegrationInfo]) and kycFields(fields: [AbyanKYCFieldItem]) can return dynamic fields.

The possible field types are:
```swift
 AbyanKYCFieldType {
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

###### Abyan Check ######

If you need to let the user capture the document (id, passport), use below code:

```swift

//put this code when you need to capture the document.
@objc func myButtonAction(_ sender: UIButton){
    Abyan.documentsCheck.delegate = self

    /// Below function is for ocr the document and get the information of the user.
    /// - Parameters:
    ///   - documentType: this is an enum (.id, .passport)
    ///   - configuration: of type ConfigureScanDocumentsViews whitch contains 3 objects type will be declared down 

    Abyan.documentsCheck.captureDocuments(documentType: .id, configuration: configuration)
}

extension <YOUR_VIEW_CONTROLLER>: AbyanDocumentsDelegate{
    func userDidCloseCamera(){
    
    }
    func userFinishCapturingDocument(documents: [AbyanDocument]){
    
    }
    func userFinishCapturingDocumentsWithResponse(documents: [AbyanDocument], response: AbyanDocumentVerificationResponse){
    
    }
    func userFinishCapturingDocumentsWithError(documents: [AbyanDocument], , error: AbyanError){
    
    }
    func didFinishWithError(error: AbyanError){

    }
    func userFinishCapturingDocumentsWithError(documents: [AbyanDocument]) {
        
    }
}
```
###### END OF ABYAN CHECK ######

###### Abyan Configuration ######
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

###### END OF ABYAN CHECK ######

###### Abyan Liveness Check ######

If you need to check user liveness and take a selfie, use below code:

```swift

//put this code when you need to check liveness.
@objc func myButtonAction(_ sender: UIButton){
        Abyan.livenessCheck.delegate = self


    /// Below function is for checking the liveness of the user and take a photo for the user.
    /// - Parameters:
    ///   - viewController: current viewController
    ///   - detectOptions: array of side(detection) options enum [.blink, .smile, .lookRight, .lookLeft] 

        Abyan.livenessCheck.checkLiveness(viewController: vc, detectOptions: [.blink])

}

extension <YOUR_VIEW_CONTROLLER>: AbyanCheckLivenessCheckDelegate{
    func didPressCancel(){
    
    }
    func didGetImageSuccessfully(data: UIImage){
    
    }
    func didGetImageMatchingResponseSuccessfully(response: ImageMatchingResponse){
    
    }
    func didGetError(errorMessage: String){
    
    }
    func LivenessCheckPageError(error: AbyanCheckError){
        
    }
    func LivenessCheckDone(){
    
    }
    func cameraAccessDeniedError(error: AbyanError){
    
    }
    
}
```
###### END OF SEDRA LIVENESS CHECK ######


###### Abyan Comply ######


```swift

//put this code when you need to check your user in the world check.
@objc func myButtonAction(_ sender: UIButton){
    AbyanCheck.comply.delegate = self

    /// Below function is for screening and checking the customer.
    /// - Parameters:
    ///   - firstName: enter the first name of the user <Required>
    ///   - secondName: enter the second name of the user <Optional>, leave empty string if not needed
    ///   - thirdName: enter the third name of the user <Optional>, leave empty string if not needed
    ///   - lastName: enter the last name of the user <Required>

    Abyan.comply.screenCustomer(firstName: "<FIRST_NAME_HERE>",
                                    secondName: "<SECOND_NAME_HERE>",
                                    thirdName: "<THIRD_NAME_HERE>",
                                    lastName: "<LAST_NAME_HERE>")
}

extension <YOUR_VIEW_CONTROLLER>: AbyanComplyDelegate{
    func screeningFinishedWithSuccess(response: AbyanScreeningResponse){
        //do your code here
    }
    
    func screeningFinishedWithError(message: AbyanError){
        //do your code here
    }
}
```
###### END OF APYAN COMPLY ######

###### Close Journey ######

```swift
extension <YOUR_VIEW_CONTROLLER>:  AbyanCloseJourneyDelegate {
  override func viewDidLoad(){
    super.viewDidLoad()
    Abyan.closeJourney.delegate = self
    Abyan.closeJourney.closeJourneyAPI(customerId: "unique-customer-id")
  }
  func didFinishCloseJourneyWithSuccess() { 
        //do your own code as:
        //dismiss dialogs, loadings
        //recall the function
  }
  func didFinishCloseJourneyWithError(error: AbyanError) { 
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

