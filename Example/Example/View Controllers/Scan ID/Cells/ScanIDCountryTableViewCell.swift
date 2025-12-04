import UIKit

class ScanIDCountryTableViewCell: UITableViewCell {

    @IBOutlet weak var flagButton: UIButton!{
        didSet {
            flagButton.isHidden = true
        }
    }
    @IBOutlet weak var sectorView: UIView!{
        didSet {
            sectorView.isHidden = true
        }
    }
    @IBOutlet weak var nationalityLabel: UITextField!
    @IBOutlet weak var mainView: FAView!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var downArrowImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
