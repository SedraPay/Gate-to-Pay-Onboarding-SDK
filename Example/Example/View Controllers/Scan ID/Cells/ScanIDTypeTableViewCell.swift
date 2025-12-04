import UIKit

class ScanIDTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var theTitleLabel: UILabel!
    @IBOutlet weak var theImageView: UIImageView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView! {
        didSet {
            rightImageView.isHidden = true
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
