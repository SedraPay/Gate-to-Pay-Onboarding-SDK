import GatetoPayOnboardingSDK

import UIKit

protocol KYCChoiceDelegate: NSObjectProtocol {
    func didSelectItem(itemIndex: Int, newValue: Bool, tag: Int, newItem: GatetoPayOnboardingKYCDynamicField)
}
class KYCChoiceTableViewCell: UITableViewCell {

    private var currentFieldData: GatetoPayOnboardingKYCDynamicField?
    var delegate: KYCChoiceDelegate?

    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var optionsCollectionView: DynamicHeightCollectionView! {
        didSet {
            optionsCollectionView.register(UINib(nibName: "KYCChoiceOptionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "KYCChoiceOptionCollectionViewCell")
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //TODO: - the height of the collection view
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(field: GatetoPayOnboardingKYCDynamicField) {

        if !(field.dataType == .checkbox ||
             field.dataType == .radioButton ||
             field.dataType == .yesNo) {
            return
        }

        currentFieldData = field

        cellTitleLabel.text = field.fieldLabel ?? ""

        optionsCollectionView.delegate = self
        optionsCollectionView.dataSource = self
        optionsCollectionView.reloadData()
    }
}

extension KYCChoiceTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentFieldData?.enumeratedValues?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let item = currentFieldData?.enumeratedValues?[indexPath.row],
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KYCChoiceOptionCollectionViewCell", for: indexPath) as? KYCChoiceOptionCollectionViewCell {
            cell.setupCell(field: item, isEnabled: !(currentFieldData?.isReadOnly ?? false), isCheckBox: currentFieldData?.dataType == .checkbox)
            return cell
        }

        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSizeMake(collectionView.frame.width, 50.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if var currentFieldData = currentFieldData {
            let row = indexPath.row
            if currentFieldData.dataType == .radioButton || currentFieldData.dataType == .yesNo {
                if let enumeratedValues = currentFieldData.enumeratedValues {
                    for (index, _) in enumeratedValues.enumerated() {
                        currentFieldData.enumeratedValues?[index].isSelected = false
                    }
                }
                currentFieldData.enumeratedValues?[row].isSelected = true
                delegate?.didSelectItem(itemIndex: row, newValue: true, tag: currentFieldData.id ?? 0, newItem: currentFieldData)
            } else if currentFieldData.dataType == .checkbox {
                let itemValue = currentFieldData.enumeratedValues?[row].isSelected ?? false
                currentFieldData.enumeratedValues?[row].isSelected = !itemValue
                delegate?.didSelectItem(itemIndex: row, newValue: !itemValue, tag: currentFieldData.id ?? 0, newItem: currentFieldData)
            }
            self.currentFieldData = currentFieldData
            collectionView.reloadData()
        }
    }
}
