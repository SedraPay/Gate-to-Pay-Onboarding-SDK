import UIKit

class OCRResponseTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var fieldNameLabel: UILabel!
    @IBOutlet weak var fieldValueLabel: UILabel!
    
    @IBOutlet weak var resultStackView: UIStackView!
    @IBOutlet weak var resultLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
