import UIKit
import GatetoPayOnboardingSDK
class KYCChoiceOptionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var borderedView: FAView!
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var optionTitleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupCell(field:GatetoPayOnboardingKYCDynamicFieldEnumeratedValue,
                   isEnabled: Bool,
                   isCheckBox: Bool) {
        borderedView.layer.borderColor = isEnabled ? UIColor(named: "AbyanColor")?.cgColor : UIColor.gray.cgColor
        if isCheckBox {
            checkImageView.image = (field.isSelected ?? false) ? UIImage(named: "checkbox_selected") : UIImage(named: "checkbox")
        } else {
            checkImageView.image = (field.isSelected ?? false) ? UIImage(named: "radioButton_selected") : UIImage(named: "radioButton")
        }
        optionTitleLabel.text = field.value ?? ""
    }
}
