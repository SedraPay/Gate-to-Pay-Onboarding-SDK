import UIKit
import GatetoPayOnboardingSDK
class KYCTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: FAView!
    @IBOutlet weak var cellLeftImageView: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellTextField: UITextField!
    @IBOutlet weak var rightArrowImageView: UIImageView!
    @IBOutlet weak var cellButton: UIButton!
    @IBOutlet weak var cellDescriptionLabel: UILabel!
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var boolSwitch: UISwitch!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var countryButton: UIButton!
    var nationalitiesResponse: CountriesAndCitiesResponse?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(field: GatetoPayOnboardingKYCDynamicField) {
        cellLabel.text = field.fieldLabel ?? ""
        
        hintButton.isHidden = field.hint == nil || (field.hint?.isEmpty ?? true)
        textView.isHidden = true
        cellTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 24).isActive = true

        switch field.dataType {
        case .boolean:
            cellLeftImageView.isHidden = true
            cellTextField.isHidden = true
            rightArrowImageView.isHidden = true
            cellButton.isHidden = true
            cellDescriptionLabel.isHidden = true
            boolSwitch.isHidden = false
            boolSwitch.isOn = field.value == "true" ? true : false
            boolSwitch.isEnabled = !(field.isReadOnly ?? true)
            countryButton.isHidden = true
            
        case .dropdown, .file, .dateTime, .image, .city:
            cellLeftImageView.isHidden = true
            cellTextField.isHidden = true
            rightArrowImageView.isHidden = false
            cellButton.isHidden = false
            cellDescriptionLabel.isHidden = false
            boolSwitch.isHidden = true
            if let value = field.value,
               let matchedEnum = field.enumeratedValues?.first(where: { $0.key == value }) {
                cellDescriptionLabel.text = matchedEnum.value
            } else {
                cellDescriptionLabel.text = field.value ?? ""
            }

            if field.dataType == .file {
                cellDescriptionLabel.text = field.selectedFileName ?? ""
            }
            
            if field.dataType == .image {
                cellDescriptionLabel.text = field.selectedImageName ?? ""
            }
            countryButton.isHidden = true
            
            
        case .country:
            cellLeftImageView.isHidden = true
            cellTextField.isHidden = true
            rightArrowImageView.isHidden = false
            cellButton.isHidden = false
            cellDescriptionLabel.isHidden = false
            boolSwitch.isHidden = true
            if let value = field.value,
               let valueId = Int(value),
               let matchedCountry = nationalitiesResponse?.countries?.first(where: { $0.id == valueId }) {
                cellDescriptionLabel.text = matchedCountry.name ?? ""
            } else {
                cellDescriptionLabel.text = field.value ?? ""
            }

            if field.dataType == .file {
                cellDescriptionLabel.text = field.selectedFileName ?? ""
            }
            
            if field.dataType == .image {
                cellDescriptionLabel.text = field.selectedImageName ?? ""
            }
            countryButton.isHidden = true

            
            
        case .countryandcity:
            cellLeftImageView.isHidden = true
            cellTextField.isHidden = true
            rightArrowImageView.isHidden = false
            cellButton.isHidden = false
            cellDescriptionLabel.isHidden = false
            boolSwitch.isHidden = true
            if let value = field.value {
                let parts = value.split(separator: ",")
                if let firstPart = parts.first,
                   let valueId = Int(firstPart),
                   let matchedCountry = nationalitiesResponse?.countries?.first(where: { $0.id == valueId }) {
                    cellDescriptionLabel.text = matchedCountry.name ?? ""
                } else {
                    cellDescriptionLabel.text = field.value
                }
            } else {
                cellDescriptionLabel.text = ""
            }

            if field.dataType == .file {
                cellDescriptionLabel.text = field.selectedFileName ?? ""
            }
            
            if field.dataType == .image {
                cellDescriptionLabel.text = field.selectedImageName ?? ""
            }
            countryButton.isHidden = true


        case .textField:
            cellLeftImageView.isHidden = true
            cellTextField.isHidden = false
            rightArrowImageView.isHidden = true
            cellButton.isHidden = true
            cellDescriptionLabel.isHidden = true
            cellTextField.text = field.value ?? ""
            cellTextField.isEnabled = !(field.isReadOnly ?? false)
            cellTextField.isUserInteractionEnabled = !(field.isReadOnly ?? false)
            boolSwitch.isHidden = true
            countryButton.isHidden = true

        case .number:
            cellLeftImageView.isHidden = true
            cellTextField.isHidden = false
            cellTextField.keyboardType = .numberPad
            rightArrowImageView.isHidden = true
            cellButton.isHidden = true
            cellDescriptionLabel.isHidden = true
            cellTextField.text = field.value ?? ""
            cellTextField.isEnabled = !(field.isReadOnly ?? false)
            cellTextField.isUserInteractionEnabled = !(field.isReadOnly ?? false)
            boolSwitch.isHidden = true
            countryButton.isHidden = true
            
        case .mobile:
            cellLeftImageView.isHidden = true
            cellTextField.isHidden = false
            cellTextField.keyboardType = .numberPad
            rightArrowImageView.isHidden = true
            cellButton.isHidden = true
            cellDescriptionLabel.isHidden = true
            cellTextField.text = field.value ?? ""
            cellTextField.isEnabled = !(field.isReadOnly ?? false)
            cellTextField.isUserInteractionEnabled = !(field.isReadOnly ?? false)
            boolSwitch.isHidden = true
            countryButton.isHidden = false

        case .email:
            cellLeftImageView.isHidden = true
            cellTextField.isHidden = false
            cellTextField.keyboardType = .emailAddress
            rightArrowImageView.isHidden = true
            cellButton.isHidden = true
            cellDescriptionLabel.isHidden = true
            cellTextField.text = field.value ?? ""
            cellTextField.isEnabled = !(field.isReadOnly ?? false)
            cellTextField.isUserInteractionEnabled = !(field.isReadOnly ?? false)
            boolSwitch.isHidden = true
            countryButton.isHidden = true

        case .textArea,.textEditor,.address:
            textView.isHidden = false
            textView.isEditable = !(field.isReadOnly ?? false)
            textView.isUserInteractionEnabled = !(field.isReadOnly ?? false)
            textView.text = field.value ?? ""
            cellLeftImageView.isHidden = true
            cellTextField.isHidden = true
            rightArrowImageView.isHidden = true
            cellButton.isHidden = true
            cellDescriptionLabel.isHidden = true
            boolSwitch.isHidden = true
            countryButton.isHidden = true

        default:
            break
        }
    }
    
    func setupFormInfoCell(field: IntegrationField) {
        cellLabel.text = field.fieldName ?? ""
        
        textView.isHidden = true
        hintButton.isHidden = true
        switch field.fieldTypes {
        case .boolean:
            break
            
        case .dropdown, .file, .dateTime, .image, .city, .country:
            cellLeftImageView.isHidden = true
            cellTextField.isHidden = true
            rightArrowImageView.isHidden = false
            cellButton.isHidden = false
            cellDescriptionLabel.isHidden = false
            boolSwitch.isHidden = true
            countryButton.isHidden = true

            
           
        case .textField:
            cellLeftImageView.isHidden = true
            cellTextField.isHidden = false
            rightArrowImageView.isHidden = true
            cellButton.isHidden = true
            cellDescriptionLabel.isHidden = true
            countryButton.isHidden = true
            boolSwitch.isHidden = true
            
        case .mobile,.number:
            cellLeftImageView.isHidden = true
            cellTextField.isHidden = false
            cellTextField.keyboardType = .numberPad
            rightArrowImageView.isHidden = true
            cellButton.isHidden = true
            cellDescriptionLabel.isHidden = true
            countryButton.isHidden = true
            boolSwitch.isHidden = true
            
        case .email:
            cellLeftImageView.isHidden = true
            cellTextField.isHidden = false
            cellTextField.keyboardType = .emailAddress
            rightArrowImageView.isHidden = true
            cellButton.isHidden = true
            cellDescriptionLabel.isHidden = true
            boolSwitch.isHidden = true
            countryButton.isHidden = true

        case .textArea,.textEditor,.address:
            textView.isHidden = false
            cellLeftImageView.isHidden = true
            cellTextField.isHidden = true
            rightArrowImageView.isHidden = true
            cellButton.isHidden = true
            cellDescriptionLabel.isHidden = true
            boolSwitch.isHidden = true
            countryButton.isHidden = true

        default:
            break
        }
    }
    
}
