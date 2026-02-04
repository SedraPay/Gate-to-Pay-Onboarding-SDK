<p align="center">
  <img src="https://github.com/SedraPay/Gate-to-Pay-Onboarding-SDK/blob/main/gatetopay.png" alt="Icon"/>
</p>
<H1 align="center">Gate to Pay Onboarding SDK</H1>

The new eKYC in simple way.

`Gate to Pay Onboarding SDK` is between your hands to help you onboard your customer easily with almost no effort.

## Screenshot
[![GatetoPayOnboardingSDK](https://github.com/SedraPay/Gate-to-Pay-Onboarding-SDK/blob/main/screenshot.png)](https://youtu.be/8oehz24fXI4)





## Requirements
- iOS 13.0+
- Swift 5.7+

## Installation

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

```bash
pod install

# OR

pod install --repo-update
```

**Alternative: Xcode project reference (for this repo)**
- Add `GatetoPayOnboardingSDK.xcodeproj` to your app workspace.
- In your app target **General → Frameworks, Libraries, and Embedded Content**, add `GatetoPayOnboardingSDK.framework` and set it to **Embed & Sign**.

Then import the module where needed:
```swift
import GatetoPayOnboardingSDK
```

## Quick Start

### First Step: Create Journey

This is a mandatory step to create a session before using any other features.

```swift
import GatetoPayOnboardingSDK

class YourViewController: UIViewController, GatetoPayOnboardingJourneyDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign the delegate to your viewController
        GatetoPayOnboarding.shared.delegate = self
        
        /// This function is required to initialize the SDK correctly.
        /// You must provide all parameters to ensure proper functionality.
        ///
        /// - Parameters:
        ///   - serverKey: The key provided to you from the portal.
        ///   - serverURLString: The base URL provided by the sales team.
        ///   - needsLogging: Optional flag for logging (default: false)
        ///   - journeyType: Type of journey (.new or .update, default: .new)
        ///   - referenceKey: Optional reference key
        ///   - customerId: Optional unique customer identifier
        ///   - nationalNumber: Required so the backend can communicate with Civil Status Authority to retrieve user information.
        ///   - riskFormId: Used to fetch the first request which contains the risk form data.
        ///   - applicationId: Unique identifier used to label each KYC onboarding journey so it can be easily distinguished
        
        try? GatetoPayOnboarding.shared.setSettings(
            serverKey: "<YOUR_SERVER_KEY>",
            serverURLString: "<YOUR_GIVEN_SERVER_URL>",
            true,                     // needsLogging
            .new,                     // journey type
            referenceKey: nil,
            customerId: "unique-customer-id",
            nationalNumber: "<USER_NATIONAL_NUMBER>",
            riskFormId: "<RISK_FORM_ID>",
            applicationId: "<APPLICATION_ID>"
        )
    }
    
    // MARK: - GatetoPayOnboardingJourneyDelegate
    
    func didFinishCreatingJourneyWithError(error: GatetoPayOnboardingError) {
        // Handle error: dismiss dialogs, loadings, or recall the function
        print("Journey creation failed: \(error.errorString ?? "Unknown error")")
    }
    
    func didFinishCreatingJourneyWithSuccess(
        journeyId: String,
        isDocumentVerification: Bool,
        isLiveness: Bool,
        isFaceMatching: Bool
    ) {
        // Journey created successfully
        // Save the journeyId if needed as a reference to your server
        // Now you can proceed with the onboarding flow
        
        // Example: Start with Risk Form
        GatetoPayOnboarding.riskForm.delegate = self
        GatetoPayOnboarding.riskForm.getRiskFields(fieldValues: [])
    }
}
```

## Usage

### Risk Form Flow

```swift
class RiskFormViewController: UIViewController, GatetoPayOnboardingRiskFormDelegate {
    
    var sectionsArray: [GatetoPayOnboardingKYCFieldItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GatetoPayOnboarding.riskForm.delegate = self
        
        // Request dynamic risk form fields
        GatetoPayOnboarding.riskForm.getRiskFields(fieldValues: [])
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        // Submit updated risk form data
        GatetoPayOnboarding.riskForm.updateRiskData(
            riskFields: sectionsArray ?? []
        )
    }
    
    // MARK: - GatetoPayOnboardingRiskFormDelegate
    
    /// Called when retrieving Risk Form fields fails
    func riskFormFinishedWithError(error: GatetoPayOnboardingError) {
        // Handle error: dismiss dialogs, show error message
        print("Risk form error: \(error.errorString ?? "Unknown error")")
    }
    
    /// Called when Risk Form dynamic fields are successfully retrieved
    func riskFormFields(fields: [GatetoPayOnboardingKYCFieldItem]) {
        // Store fields to display in your UI
        sectionsArray = fields
        
        var allFields: [GatetoPayOnboardingKYCDynamicField] = []
        for item in fields {
            if let dynamicFields = item.dynamicFields {
                allFields.append(contentsOf: dynamicFields)
            }
        }
        
        // Now `allFields` contains all dynamic fields to display in your UI
        // Render your form UI here
    }
    
    /// Called when updating the Risk Form fails
    func updateRiskFormFinishedWithError(error: String) {
        // Handle retry or show a proper message to the user
        print("Update risk form failed: \(error)")
    }
    
    /// Called when updating the Risk Form succeeds
    func didUpdateRiskFormSuccessfully(riskLevel: Int?) {
        // Save riskLevel for later usage when submitting getProductByIdType API
        let savedRiskLevel = riskLevel ?? 0
        
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
}
```

### CSPD Data Flow

```swift
class CSPDViewController: UIViewController, GatetoPayOnboardingCSPDDelegate {
    
    var riskLevel: Int?
    var customerIdentityType: String?
    var productIdForKYC: Int?
    
    @IBAction func nextButton(_ sender: Any) {
        GatetoPayOnboarding.cspdData.delegate = self
        GatetoPayOnboarding.cspdData.getProductByIdType(
            riskLevel: riskLevel ?? 0,
            customerIdentityType: customerIdentityType ?? ""
        )
    }
    
    // MARK: - GatetoPayOnboardingCSPDDelegate
    
    func cspdTypesReceived(types: [CSPDType]) {
        // Handle CSPD types received
        // Display types to user if needed
    }
    
    func cspdTypesFinishedWithError(error: GatetoPayOnboardingError) {
        // Handle error
        print("CSPD types error: \(error.errorString ?? "Unknown error")")
    }
    
    func productIdForKYCReceived(productId: Int) {
        productIdForKYC = productId
        
        // Now you can fetch KYC fields using this productId
        GatetoPayOnboarding.kyc.delegate = self
        GatetoPayOnboarding.kyc.getKYCFields(
            fieldValues: [],
            productId: productIdForKYC ?? 0
        )
    }
    
    func productIdForKYCFinishedWithError(error: GatetoPayOnboardingError) {
        // Handle error
        print("Product ID error: \(error.errorString ?? "Unknown error")")
    }
}
```

### KYC Dynamic Fields

```swift
class KYCViewController: UIViewController, GatetoPayOnboardingKYCDelegate {
    
    var sectionsArray: [GatetoPayOnboardingKYCFieldItem]?
    
    func fetchKYCFields(productId: Int) {
        GatetoPayOnboarding.kyc.delegate = self
        GatetoPayOnboarding.kyc.getKYCFields(
            fieldValues: [],
            productId: productId
        )
    }
    
    @IBAction func submitButton(_ sender: UIButton) {
        // Submit KYC form data
        GatetoPayOnboarding.kyc.updateKYC(kycFields: sectionsArray ?? [])
    }
    
    // MARK: - GatetoPayOnboardingKYCDelegate
    
    /// Called when KYC request fails
    func kycFinishedWithError(error: GatetoPayOnboardingError) {
        // Handle error
        print("KYC error: \(error.errorString ?? "Unknown error")")
    }
    
    /// Called when KYC dynamic fields are returned
    func kycFields(fields: GatetoPayOnboardingKYCFieldModel) {
        // Extract fields from the model
        sectionsArray = fields.steps
        
        var allFields: [GatetoPayOnboardingKYCDynamicField] = []
        
        if let steps = fields.steps {
            for item in steps {
                if let dynamicFields = item.dynamicFields {
                    allFields.append(contentsOf: dynamicFields)
                }
            }
        }
        
        // Now `allFields` contains all dynamic fields to display in your UI
        // Render your KYC form UI here
    }
    
    /// Called when updating KYC fails
    func updateKYCFinishedWithError(error: String) {
        // Handle error: dismiss dialogs, show error message
        print("Update KYC failed: \(error)")
    }
    
    /// Called when updating KYC succeeds
    func didUpdateKYCSuccessfully(id: Int?) {
        // KYC updated successfully
        // Proceed to next step in your flow
        print("KYC updated successfully with ID: \(id ?? -1)")
    }
}
```

### Countries and Cities

Call this method only once and cache the response (countries and cities) locally. This data will be used later in the KYC screen to handle data types like country and countryCity.

```swift
class CountriesViewController: UIViewController, GatetoPayOnboardingCountriesDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCountries()
    }
    
    func loadCountries() {
        GatetoPayOnboarding.countries.delegate = self
        GatetoPayOnboarding.countries.getNationalities()
    }
    
    // MARK: - GatetoPayOnboardingCountriesDelegate
    
    func didGetNationalitiesWithSuccess(response: CountriesAndCitiesResponse) {
        // Cache the response locally
        // Use response.countries and response.cities in your KYC forms
        // This data will be used for fields with dataType: .country, .city, or .countryandcity
    }
    
    func didGetNationalitiesWithError(error: GatetoPayOnboardingError) {
        // Handle error
        print("Countries error: \(error.errorString ?? "Unknown error")")
    }
}
```

### Verification Journey

```swift
class VerificationViewController: UIViewController, VerificationJourneyDelegate {
    
    func startVerification(applicationLanguage: String, nationality: String) {
        GatetoPayOnboarding.verificationJourney.delegate = self
        GatetoPayOnboarding.verificationJourney.startVerification(
            applicationLanguage: applicationLanguage,
            nationality: nationality
        )
    }
    
    // MARK: - VerificationJourneyDelegate
    
    func onJourneyStarted(journeyId: String) {
        // Journey started
        print("Verification journey started: \(journeyId)")
    }
    
    func onJourneyResumed(journeyId: String) {
        // Journey resumed
        print("Verification journey resumed: \(journeyId)")
    }
    
    func onJourneyCompleted(journeyId: String) {
        // Journey completed successfully
        print("Verification journey completed: \(journeyId)")
    }
    
    func onJourneyCancelled(journeyId: String, cancellationReason: String) {
        // User cancelled the journey
        print("Verification journey cancelled: \(cancellationReason)")
    }
    
    func onJourneyBlocked(journeyId: String, blockReasonMessage: String) {
        // Journey was blocked
        print("Verification journey blocked: \(blockReasonMessage)")
    }
    
    func onJourneyError(error: String) {
        // Handle error
        print("Verification journey error: \(error)")
    }
    
    func checkIsMobileJourneyFailed(error: GatetoPayOnboardingError) {
        // Handle error when mobile journey check fails
        print("Mobile journey check failed: \(error.errorString ?? "Unknown error")")
    }
}
```

### Close Journey

```swift
class CloseJourneyViewController: UIViewController, GatetoPayOnboardingCloseJourneyDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GatetoPayOnboarding.closeJourney.delegate = self
        GatetoPayOnboarding.closeJourney.closeJourneyAPI(customerId: "unique-customer-id")
    }
    
    // MARK: - GatetoPayOnboardingCloseJourneyDelegate
    
    func didFinishCloseJourneyWithSuccess() {
        // Journey closed successfully
        // Dismiss dialogs, loadings, or proceed to next step
        print("Journey closed successfully")
    }
    
    func didFinishCloseJourneyWithError(error: GatetoPayOnboardingError) {
        // Handle error: dismiss dialogs, loadings, or retry
        print("Close journey error: \(error.errorString ?? "Unknown error")")
    }
}
```

## Dynamic Fields Types

Both `riskFormFields` and `kycFields` return dynamic fields. The possible field types are:

```swift
public enum GatetoPayOnboardingKYCFieldType: Int, Codable {
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

### Handling File and Image Uploads

When a field has `dataType == .file` or `dataType == .image`, you need to set the file/image data before submitting:

```swift
// For image fields
field.imageData = imageData
field.selectedImageName = "image.jpg"

// For file fields
field.fileData = fileData
field.selectedFileName = "document.pdf"
field.selectedFileMimeType = "application/pdf"
```

The SDK will automatically upload these files when you call `updateKYC()` or `updateRiskData()`.

## Error Handling

Most calls report `GatetoPayOnboardingError` via delegates. Common error cases:
- `.journeyIsNotGenerated` - Journey session was not created
- `.serverError` - Server returned an error
- `.imageLoadingError` - Error loading/processing images
- `.invalidSubscription` - Invalid subscription key

## Sample App Walkthrough

The `Sample/` folder contains an end-to-end reference implementation. Key screens:

- **LandingPageViewController**
  - Collects the subscription key and initializes the SDK via `GatetoPayOnboarding.shared.setSettings(...)`

- **RiskFormViewController**
  - Retrieves risk form fields via `GatetoPayOnboarding.riskForm.getRiskFields(...)`
  - Submits risk form data with `GatetoPayOnboarding.riskForm.updateRiskData(...)`
  - Uses CSPD data to get product ID for KYC flow

- **KYCViewController**
  - Retrieves dynamic KYC fields via `GatetoPayOnboarding.kyc.getKYCFields(...)`
  - Builds the form UI and submits values with `GatetoPayOnboarding.kyc.updateKYC(...)`, including file/image uploads handled internally by the SDK

- **CloseJourneyViewController**
  - Closes the journey at the end of the flow via `GatetoPayOnboarding.closeJourney.closeJourneyAPI(...)`

You can follow these controllers step-by-step to mirror the same integration in your own app.

## Localization

Check the `Localizable.strings` file in the project and translate it according to your needs.

## Contact Us & Report a Bug

If you have any questions or want to contact us, visit our website:

https://sedracheck.sedrapay.com/

--- OR ---

Contact us via email: mob@sedrapay.com

## License

Proprietary. All rights reserved unless otherwise stated.
