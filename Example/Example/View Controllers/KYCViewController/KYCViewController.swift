import GatetoPayOnboardingSDK
import AMPopTip
import DropDown
import UIKit
import DatePickerDialog
import PDFKit
import Photos
import FAPickerView
import UniformTypeIdentifiers

class KYCViewController: UIViewController {
    
    var dataArray: [GatetoPayOnboardingKYCDynamicField]?
    var sectionsArray: [GatetoPayOnboardingKYCFieldItem]?
    var infofieldsArray : [IntegrationInfo]?
    
    private weak var datePicker: UIDatePicker?
    private var currentPickedIndex: Int?
    private var currentPickedIndexPath: IndexPath?
    var PickedFileRow : Int?
    var PickedFileSection : Int?
    
    var PickedImageRow : Int?
    var PickedImageSection : Int?
    
    private let imagePicker = UIImagePickerController()
    var nationalitiesResponse: CountriesAndCitiesResponse?
    var defaultCountryCode: CountryModel?
    var allCountriesCodes =  [allCountriesCodesStruct]()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib(nibName: "KYCTableViewCell", bundle: nil), forCellReuseIdentifier: "KYCTableViewCell")
            tableView.register(UINib(nibName: "KYCChoiceTableViewCell", bundle: nil), forCellReuseIdentifier: "KYCChoiceTableViewCell")
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.defaultCountryCode = CountryModel(name: "🇯🇴 (+962)", iso2: "", dial_code: "+962", flag: "")
        tableView.reloadData()
        
    }
    
    @IBAction func confirmButtonAction(_ sender: Any) {
        
        //        Dialogs.showLoading()
        //        GatetoPayOnboarding.kyc.delegate = self
        //        GatetoPayOnboarding.kyc.updateKYC(kycFields: sectionsArray ?? [])
        
        let check = isValid()
        if check.0 {
            if let dataArray {
                Dialogs.showLoading()
                GatetoPayOnboarding.kyc.delegate = self
                GatetoPayOnboarding.kyc.updateKYC(kycFields: sectionsArray ?? [])
            }
        } else {
            let array = check.1
            if !array.isEmpty {
                var errorsString: String = "Please check below errors:"
                for error in array {
                    errorsString = errorsString.appending("\n" + error)
                }
                Dialogs.showWarning(errorsString)
            }
        }
    }
    
    func isValid() -> (Bool, [String]) {
        var isValid = true
        var errorsArray: [String] = []
        
        guard let sections = sectionsArray else {
            errorsArray.append("Data is empty")
            return (false, errorsArray)
        }
        
        for section in sections {
            guard let dynamicFields = section.dynamicFields else { continue }
            
            for item in dynamicFields {
                let itemValue = item.value?.trimmingCharacters(in: .whitespacesAndNewlines)
                
                switch item.dataType {
                case .textField:
                    if (item.isRequired ?? false) && (itemValue == nil || itemValue?.isEmpty ?? true) {
                        isValid = false
                        errorsArray.append("\(item.fieldLabel ?? "") is required")
                    } else if ((item.value?.count ?? 0) > (item.fieldMax ?? 1000)) {
                        isValid = false
                        errorsArray.append("\(item.fieldLabel ?? "") maximum number of characters allowed is \((item.fieldMax ?? 1000))")
                    } else if ((item.value?.count ?? 0) < (item.fieldMin ?? 0)) {
                        isValid = false
                        errorsArray.append("\(item.fieldLabel ?? "") minimum number of characters required is \((item.fieldMin ?? 0))")
                    } else if let regex = item.validationRegEx, !regex.isEmpty, !validateStringFromRegex(item.value, regex: regex) {
                        isValid = false
                        errorsArray.append("\(item.regExErrorMessage ?? "\(item.fieldLabel ?? "") has invalid data")")
                    }
                    
                case .dropdown, .country, .city:
                    if (item.isRequired ?? false)  && (itemValue == nil || itemValue?.isEmpty ?? true){
                        isValid = false
                        errorsArray.append("\(item.fieldLabel ?? "") is required")
                    }
                    
                case .countryandcity:
                    if item.isRequired ?? false {
                        if let value = itemValue?.trimmingCharacters(in: .whitespacesAndNewlines),
                           value.isEmpty || !value.contains(",") {
                            isValid = false
                            errorsArray.append("\(item.fieldLabel ?? "") is required (must include both country and city)")
                        }
                    }
                    
                    
                    
                case .checkbox, .radioButton, .yesNo:
                    if item.isRequired ?? false {
                        let hasSelection = item.enumeratedValues?.contains(where: { $0.isSelected == true }) ?? false
                        if !hasSelection {
                            isValid = false
                            errorsArray.append("\(item.fieldLabel ?? "") is required")
                        }
                    }
                    
                    
                case .dateTime:
                    if (item.isRequired ?? false) && (itemValue?.isEmpty ?? true) {
                        isValid = false
                        errorsArray.append("\(item.fieldLabel ?? "") is required")
                    }
                    // TODO: Add date validation logic for max/min date
                    
                case .boolean:
                    if (item.isRequired ?? false) && (itemValue?.isEmpty ?? true) {
                        isValid = false
                        errorsArray.append("\(item.fieldLabel ?? "") is required")
                    }
                    
                case .file:
                    if (item.isRequired ?? false) && (item.fileData?.isEmpty ?? true) && (item.value?.isEmpty ?? true) {
                        isValid = false
                        errorsArray.append("\(item.fieldLabel ?? "") is required")
                    }
                    
                case .image:
                    if (item.isRequired ?? false) && (item.imageData?.isEmpty ?? true) && (item.value?.isEmpty ?? true) {
                        isValid = false
                        errorsArray.append("\(item.fieldLabel ?? "") is required")
                    }
                    
                    
                    
                default:
                    break
                }
            }
        }
        
        return (isValid, errorsArray)
    }
    
    // Show hint popup for the field to let the user knows what is this field
    @objc func didSelectHintFor(button: UIButton) {
        let tag = button.tag
        if let hint = dataArray?[tag].hint,
           !hint.isEmpty {
            let popTip = PopTip()
            popTip.shouldDismissOnTap = true
            popTip.shouldDismissOnTapOutside = true
            popTip.shouldDismissOnSwipeOutside = true
            popTip.show(text: hint, direction: .auto, maxWidth: 200, in: view, from: button.frame)
        }
    }
    
    // Open the drop down picker with your design
    @objc func didSelectDropDown(button: UIButton) {
        
        let row = button.tag // Get the row from the button tag
        
        // Find the cell that contains the button
        var cell: UIView? = button
        while cell != nil, !(cell is KYCTableViewCell) {
            cell = cell?.superview
        }
        
        guard let tableViewCell = cell as? KYCTableViewCell,
              let indexPath = tableView.indexPath(for: tableViewCell) else {
            print("Failed to find cell or indexPath")
            return
        }
        
        let section = indexPath.section
        
        // Ensure data exists
        guard let field = sectionsArray?[section].dynamicFields?[row] else {
            print("Field not found at section: \(section), row: \(row)")
            return
        }
        
        var items = [FAPickerItem]()
        
        if let enumeratedValues = field.enumeratedValues {
            items = enumeratedValues.compactMap { obj in
                FAPickerItem(id: "\(obj.key ?? "")", title: obj.value ?? "")
            }
        }
        
        var selectedItem = items.first { $0.id == field.value }
        if selectedItem == nil {
            selectedItem = items.first { $0.title == field.value }
        }
        FAPickerView.showSingleSelectItem(
            items: NSMutableArray(array: items),
            selectedItem: selectedItem,
            filter: true,
            headerTitle: NSLocalizedString("Select \(field.fieldLabel ?? "Option")", comment: ""),
            complete: { [weak self] (selectedItem: FAPickerItem?) in
                guard let self = self, let selectedItem = selectedItem else { return }
                
                // Update UI
                tableViewCell.cellDescriptionLabel.text = selectedItem.title
                tableViewCell.cellDescriptionLabel.isHidden = false
                
                // Update Data Model
                self.sectionsArray?[section].dynamicFields?[row].value = selectedItem.title
                
                // Reset previous selections and mark the new one
                //self.sectionsArray?[section].dynamicFields?[row].enumeratedValues?.forEach { $0.isSelected = false }
                if let selectedIndex = self.sectionsArray?[section].dynamicFields?[row].enumeratedValues?.firstIndex(where: { $0.value == selectedItem.title }) {
                    self.sectionsArray?[section].dynamicFields?[row].enumeratedValues?[selectedIndex].isSelected = true
                }
                self.tableView.reloadData()
                
            },
            cancel: {
                print("Dropdown selection canceled")
            }
        )
    }
    
    
    @objc func didSelectCountryDropDown(button: UIButton) {
        
        let row = button.tag // Get the row from the button tag
        
        // Find the cell that contains the button
        var cell: UIView? = button
        while cell != nil, !(cell is KYCTableViewCell) {
            cell = cell?.superview
        }
        
        guard let tableViewCell = cell as? KYCTableViewCell,
              let indexPath = tableView.indexPath(for: tableViewCell) else {
            print("Failed to find cell or indexPath")
            return
        }
        
        let section = indexPath.section
        
        // Ensure data exists
        guard let field = sectionsArray?[section].dynamicFields?[row] else {
            print("Field not found at section: \(section), row: \(row)")
            return
        }
        
        var items = [FAPickerItem]()
        
        if let enumeratedValues = nationalitiesResponse?.countries {
            items = enumeratedValues.compactMap { obj in
                FAPickerItem(id: "\(obj.id ?? 0)", title: obj.name ?? "")
            }
        }
        
        var selectedItem = items.first { $0.id == field.value }
        if selectedItem == nil {
            selectedItem = items.first { $0.title == field.value }
        }
        FAPickerView.showSingleSelectItem(
            items: NSMutableArray(array: items),
            selectedItem: selectedItem,
            filter: true,
            headerTitle: NSLocalizedString("Select \(field.fieldLabel ?? "Option")", comment: ""),
            complete: { [weak self] (selectedItem: FAPickerItem?) in
                guard let self = self, let selectedItem = selectedItem else { return }
                
                // Update UI
                tableViewCell.cellDescriptionLabel.text = selectedItem.title
                tableViewCell.cellDescriptionLabel.isHidden = false
                
                // Update Data Model
                self.sectionsArray?[section].dynamicFields?[row].value = selectedItem.title
                
                let newValue = GatetoPayOnboardingKYCDynamicFieldEnumeratedValue(
                    key: selectedItem.id,
                    value: selectedItem.title,
                    isSelected: true
                )
                
                if self.sectionsArray?[section].dynamicFields?[row].enumeratedValues == nil {
                    self.sectionsArray?[section].dynamicFields?[row].enumeratedValues = []
                }
                
                self.sectionsArray?[section].dynamicFields?[row].enumeratedValues?.removeAll()
                self.sectionsArray?[section].dynamicFields?[row].enumeratedValues?.append(newValue)
                
                self.tableView.reloadData()
                
            },
            cancel: {
                print("Dropdown selection canceled")
            }
        )
    }
    
    var selectedCountryCityObj : GatetoPayOnboardingKYCDynamicFieldEnumeratedValue?
    
    var selectedCityObj : GatetoPayOnboardingKYCDynamicFieldEnumeratedValue?
    
    
    @objc func didSelectCountryCityDropDown(button: UIButton) {
        
        let row = button.tag // Get the row from the button tag
        
        // Find the cell that contains the button
        var cell: UIView? = button
        while cell != nil, !(cell is KYCTableViewCell) {
            cell = cell?.superview
        }
        
        guard let tableViewCell = cell as? KYCTableViewCell,
              let indexPath = tableView.indexPath(for: tableViewCell) else {
            print("Failed to find cell or indexPath")
            return
        }
        
        let section = indexPath.section
        
        // Ensure data exists
        guard let field = sectionsArray?[section].dynamicFields?[row] else {
            print("Field not found at section: \(section), row: \(row)")
            return
        }
        
        var items = [FAPickerItem]()
        
        if let enumeratedValues = nationalitiesResponse?.countries {
            items = enumeratedValues.compactMap { obj in
                FAPickerItem(id: "\(obj.id ?? 0)", title: obj.name ?? "")
            }
        }
        let value = field.value ?? ""
        let parts = value.split(separator: ",")
        let firstPart = parts.first ?? ""
        
        let selectedItem = items.first { $0.id == self.selectedCountryCityObj?.key ?? "\(firstPart)" }
        
        FAPickerView.showSingleSelectItem(
            items: NSMutableArray(array: items),
            selectedItem: selectedItem,
            filter: true,
            headerTitle: NSLocalizedString("Select \(field.fieldLabel ?? "Option")", comment: ""),
            complete: { [weak self] (selectedItem: FAPickerItem?) in
                guard let self = self, let selectedItem = selectedItem else { return }
                
                // Update UI
                
                // Update Data Model
                self.sectionsArray?[section].dynamicFields?[row].value = selectedItem.title
                
                let newValue = GatetoPayOnboardingKYCDynamicFieldEnumeratedValue(
                    key: selectedItem.id,
                    value: selectedItem.title,
                    isSelected: true
                )
                self.selectedCountryCityObj = newValue
                self.selectedCityObj = nil
                tableViewCell.cellDescriptionLabel.text = selectedItem.title
                tableViewCell.cellDescriptionLabel.isHidden = false
                
                if self.sectionsArray?[section].dynamicFields?[row].enumeratedValues == nil {
                    self.sectionsArray?[section].dynamicFields?[row].enumeratedValues = []
                }
                
                self.sectionsArray?[section].dynamicFields?[row].enumeratedValues?.removeAll()
                self.sectionsArray?[section].dynamicFields?[row].enumeratedValues?.append(newValue)
                
                self.tableView.reloadData()
                
            },
            cancel: {
                print("Dropdown selection canceled")
            }
        )
    }
    
    @objc func didSelectCityDropDown(button: UIButton) {
        
        let row = button.tag // Get the row from the button tag
        
        // Find the cell that contains the button
        var cell: UIView? = button
        while cell != nil, !(cell is KYCTableViewCell) {
            cell = cell?.superview
        }
        
        guard let tableViewCell = cell as? KYCTableViewCell,
              let indexPath = tableView.indexPath(for: tableViewCell) else {
            print("Failed to find cell or indexPath")
            return
        }
        
        let section = indexPath.section
        
        // Ensure data exists
        guard let field = sectionsArray?[section].dynamicFields?[row] else {
            print("Field not found at section: \(section), row: \(row)")
            return
        }
        
        var items = [FAPickerItem]()
        
        
        if let selectedCountryId = selectedCountryCityObj?.key,
           let cities = nationalitiesResponse?.countries?
            .first(where: { "\($0.id ?? 0)" == selectedCountryId })?
            .cities {
            
            items = cities.compactMap { city in
                FAPickerItem(id: "\(city.id ?? 0)", title: city.name ?? "")
            }
        }
        let value = field.value ?? ""
        let parts = value.split(separator: ",")
        var selectedItem = FAPickerItem()
        if parts.count == 2 {
            let cityId = Int(parts[1])
            selectedItem = items.first { $0.id == self.selectedCityObj?.key ?? "\(cityId ?? 0)"} ?? FAPickerItem()
            
        } else {
            selectedItem = items.first { $0.title == field.value } ?? FAPickerItem()
            
        }
        
        
        FAPickerView.showSingleSelectItem(
            items: NSMutableArray(array: items),
            selectedItem: selectedItem,
            filter: true,
            headerTitle: NSLocalizedString("Select \(field.fieldLabel ?? "Option")", comment: ""),
            complete: { [weak self] (selectedItem: FAPickerItem?) in
                guard let self = self, let selectedItem = selectedItem else { return }
                
                // Update UI
                tableViewCell.cellDescriptionLabel.text = selectedItem.title
                tableViewCell.cellDescriptionLabel.isHidden = false
                
                // Update Data Model
                
                let newValue = GatetoPayOnboardingKYCDynamicFieldEnumeratedValue(
                    key: "\(self.selectedCountryCityObj?.key ?? ""),\(selectedItem.id ?? "")",
                    value: "\(self.selectedCountryCityObj?.value ?? ""),\(selectedItem.title ?? "")",
                    isSelected: true
                )
                self.sectionsArray?[section].dynamicFields?[row].value = newValue.value
                
                self.selectedCityObj = GatetoPayOnboardingKYCDynamicFieldEnumeratedValue(
                    key:  selectedItem.id ?? "" ,
                    value: selectedItem.title ?? "",
                    isSelected: true
                )
                if self.sectionsArray?[section].dynamicFields?[row].enumeratedValues == nil {
                    self.sectionsArray?[section].dynamicFields?[row].enumeratedValues = []
                }
                
                self.sectionsArray?[section].dynamicFields?[row].enumeratedValues?.removeAll()
                self.sectionsArray?[section].dynamicFields?[row].enumeratedValues?.append(newValue)
                
                self.tableView.reloadData()
                
            },
            cancel: {
                print("Dropdown selection canceled")
            }
        )
    }
    
    
    // Validate if string obey with the Regex returned by the framework
    func validateStringFromRegex(_ string: String?, regex: String) -> Bool {
        let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: string)
        return isValid
    }
    
    // Open document picker
    @objc func importFile(button: UIButton) {
        PickedFileRow = button.tag
        currentPickedIndex = button.tag
        var superview = button.superview
        while superview != nil && !(superview is KYCTableViewCell) {
            superview = superview?.superview
        }
        if let cell = superview as? KYCTableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            currentPickedIndexPath = indexPath
            PickedFileSection = indexPath.section
            
        } else {
            currentPickedIndexPath = nil
        }
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["png", "jpg", "pdf", "com.adobe.pdf", "jpeg"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    // Open date time picker
    @objc func dateTimePicker(button: UIButton) {
        let row = button.tag
        
        var cell: UIView? = button
        while cell != nil, !(cell is KYCTableViewCell) {
            cell = cell?.superview
        }
        
        guard let tableViewCell = cell as? KYCTableViewCell,
              let indexPath = tableView.indexPath(for: tableViewCell) else {
            print("Failed to find cell or indexPath")
            return
        }
        
        let section = indexPath.section
        
        // Ensure data exists
        guard let field = sectionsArray?[section].dynamicFields?[row] else {
            print("Field not found at section: \(section), row: \(row)")
            return
        }
        
        let minimumDateFormatter = DateFormatter()
        minimumDateFormatter.dateFormat = "dd/MM/yyyy"
        let minimumDate = minimumDateFormatter.date(from: field.dateMin ?? "")
        
        let maximumDateFormatter = DateFormatter()
        maximumDateFormatter.dateFormat = "dd/MM/yyyy"
        let maximumDate = maximumDateFormatter.date(from: field.dateMax ?? "")
        
        let currentDateFormatter = DateFormatter()
        currentDateFormatter.dateFormat = "dd/MM/yyyy"
        let currentDate = currentDateFormatter.date(from: field.value ?? "") ?? Date()
        
        DatePickerDialog().show("Pick \(field.fieldLabel ?? "")",
                                doneButtonTitle: "Done",
                                cancelButtonTitle: "Cancel",
                                defaultDate: currentDate,
                                minimumDate: minimumDate,
                                maximumDate: maximumDate,
                                datePickerMode: .date) { date in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                let dateString = formatter.string(from: dt)
                
                // Update the correct field value in sectionsArray
                self.sectionsArray?[section].dynamicFields?[row].value = dateString
                self.tableView.reloadData()
            }
        }
    }
    
    // Import Image from camera or image picker
    @objc func importImage(button: UIButton) {
        currentPickedIndex = button.tag
        PickedImageRow = button.tag
        var superview = button.superview
        while superview != nil && !(superview is KYCTableViewCell) {
            superview = superview?.superview
        }
        if let cell = superview as? KYCTableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            currentPickedIndexPath = indexPath
            PickedImageSection = indexPath.section
            
        } else {
            currentPickedIndexPath = nil
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // Open camera to take photo
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Open Gallery
    func openGallery() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        // If you don't want to edit the photo then you can set allowsEditing to false
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func switchValueChanged(sender: UISwitch) {
        let tag = sender.tag
        dataArray?[tag].value = sender.isOn ? "true" : "false"
    }
    
    @objc func didSelectPhoneCountryDropDown(button: UIButton) {
        // Find the cell
        self.view.endEditing(true)
        let row = button.tag // Get the row from the button tag
        
        // Find the cell that contains the button
        var cell: UIView? = button
        while cell != nil, !(cell is KYCTableViewCell) {
            cell = cell?.superview
        }
        
        guard let tableViewCell = cell as? KYCTableViewCell,
              let indexPath = tableView.indexPath(for: tableViewCell) else {
            print("Failed to find cell or indexPath")
            return
        }
        
        let section = indexPath.section
        
        // Ensure data exists
        guard let field = sectionsArray?[section].dynamicFields?[row] else {
            print("Field not found at section: \(section), row: \(row)")
            return
        }
        
        
        let countries = loadCountries()
        
        var items = [FAPickerItem]()
        
        items = countries.map { country in
            FAPickerItem(id: country.dial_code ?? "", title: "\(country.flag ?? "") (\(country.dial_code ?? ""))")
        }
        let fieldID = sectionsArray?[section].dynamicFields?[row].id
        sectionsArray?[section].dynamicFields?[row].value = ""
        self.tableView.reloadData()
        let existingItem = self.allCountriesCodes.first(where: { $0.FieldID == fieldID })
        
        
        let selectedItem = items.first { $0.id == existingItem?.countryData.dial_code }
        
        FAPickerView.showSingleSelectItem(
            items: NSMutableArray(array: items),
            selectedItem: selectedItem,
            filter: true,
            headerTitle: "Select Country",
            complete: { selectedItem in
                guard let selectedItem = selectedItem else { return }
                
                let selectedCountryitem = CountryModel(name: selectedItem.title, iso2: "", dial_code: selectedItem.id, flag: "")
                
                let fieldID = self.sectionsArray?[section].dynamicFields?[row].id ?? 0
                
                self.allCountriesCodes.removeAll { $0.FieldID == fieldID }
                
                // Append the new one
                self.allCountriesCodes.append(
                    allCountriesCodesStruct(
                        countryData: selectedCountryitem,
                        FieldID: fieldID
                    )
                )
                
                
                tableViewCell.countryButton.setTitle(selectedItem.title, for: .normal)
                self.tableView.reloadData()
                // self.tableView.reloadData()
            },
            cancel: {
                print("Dropdown selection canceled")
            }
        )
    }
    
}

extension KYCViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let fields = sectionsArray?[section].dynamicFields else { return 0 }
        
        var count = 0
        for field in fields {
            switch field.dataType {
            case .countryandcity:
                
                count += 2
            default:
                count += 1
            }
        }
        
        return count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsArray?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionsArray?[section].fieldLabel ?? ""
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .secondarySystemBackground
        
        let label = UILabel()
        label.numberOfLines = 0
        label.text = sectionsArray?[section].fieldLabel ?? ""
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor  = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let fields = sectionsArray?[indexPath.section].dynamicFields else {
            return UITableViewCell()
        }
        
        var fieldIndex = 0
        var localRow = indexPath.row
        
        while fieldIndex < fields.count {
            let field = fields[fieldIndex]
            let rowsForField = (field.dataType == .countryandcity) ? 2 : 1
            
            if localRow < rowsForField {
                switch field.dataType {
                case .checkbox, .radioButton, .yesNo:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "KYCChoiceTableViewCell") as? KYCChoiceTableViewCell {
                        cell.setupCell(field: field)
                        cell.delegate = self
                        return cell
                    }
                    
                case .table:
                    let cell = UITableViewCell()
                    cell.backgroundColor = .blue
                    return cell
                    
                case .dropdown, .city:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "KYCTableViewCell") as? KYCTableViewCell {
                        cell.setupCell(field: field)
                        cell.nationalitiesResponse = self.nationalitiesResponse
                        cell.cellButton.tag = fieldIndex
                        cell.cellButton.removeTarget(self, action: #selector(didSelectDropDown(button:)), for: .touchUpInside)
                        cell.cellButton.addTarget(self, action: #selector(didSelectDropDown(button:)), for: .touchUpInside)
                        return cell
                    }
                    
                case .country:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "KYCTableViewCell") as? KYCTableViewCell {
                        cell.setupCell(field: field)
                        cell.nationalitiesResponse = self.nationalitiesResponse
                        cell.cellButton.tag = fieldIndex
                        cell.cellButton.removeTarget(self, action: #selector(didSelectCountryDropDown(button:)), for: .touchUpInside)
                        cell.cellButton.addTarget(self, action: #selector(didSelectCountryDropDown(button:)), for: .touchUpInside)
                        return cell
                    }
                    
                case .countryandcity:
                    let subIndex = localRow // 0 = country, 1 = city
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "KYCTableViewCell") as? KYCTableViewCell {
                        cell.setupCell(field: field)
                        cell.nationalitiesResponse = self.nationalitiesResponse
                        cell.cellButton.tag = fieldIndex
                        if let value = field.value {
                            // Split the value to get countryId and cityId
                            let parts = value.split(separator: ",")
                            if parts.count == 2,
                               let countryId = Int(parts[0]),
                               let cityId = Int(parts[1]),
                               let matchedCountry = nationalitiesResponse?.countries?.first(where: { $0.id == countryId }),
                               let matchedCity = matchedCountry.cities?.first(where: { $0.id == cityId }) {
                                
                                // Fill selectedCityObj from the matched city
                                self.selectedCityObj = GatetoPayOnboardingKYCDynamicFieldEnumeratedValue(
                                    key: "\(matchedCity.id ?? 0)",
                                    value: matchedCity.name ?? "",
                                    isSelected: true
                                )
                                
                                self.selectedCountryCityObj =  GatetoPayOnboardingKYCDynamicFieldEnumeratedValue(
                                    key: "\(matchedCountry.id ?? 0)",
                                    value: matchedCountry.name ?? "",
                                    isSelected: true
                                )
                                
                                cell.cellDescriptionLabel.text = matchedCity.name ?? ""
                            }
                        }
                        
                        
                        if subIndex == 0 {
                            cell.cellButton.isEnabled = true
                            cell.cellButton.removeTarget(self, action: #selector(didSelectCountryCityDropDown(button:)), for: .touchUpInside)
                            cell.cellButton.addTarget(self, action: #selector(didSelectCountryCityDropDown(button:)), for: .touchUpInside)
                            cell.cellLabel.text = "Country"
                            cell.cellDescriptionLabel.text = self.selectedCountryCityObj?.value
                        } else {
                            
                            if self.selectedCountryCityObj == nil   {
                                cell.cellButton.isEnabled = false
                                cell.cellDescriptionLabel.text = "Please select country first"
                                cell.cellDescriptionLabel.isHidden = false
                                cell.cellLabel.text = "City"
                                
                            } else {
                                
                                cell.cellButton.isEnabled = true
                                cell.cellButton.removeTarget(self, action: #selector(didSelectCityDropDown(button:)), for: .touchUpInside)
                                cell.cellButton.addTarget(self, action: #selector(didSelectCityDropDown(button:)), for: .touchUpInside)
                                cell.cellLabel.text = "City"
                                cell.cellDescriptionLabel.text = self.selectedCityObj?.value
                                
                                
                            }
                        }
                        return cell
                    }
                    
                case .textField, .number, .email:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "KYCTableViewCell") as? KYCTableViewCell {
                        cell.setupCell(field: field)
                        cell.nationalitiesResponse = self.nationalitiesResponse
                        cell.cellTextField.delegate = nil
                        cell.cellTextField.tag = fieldIndex
                        cell.cellTextField.delegate = self
                        return cell
                    }
                    
                case .mobile :
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "KYCTableViewCell") as? KYCTableViewCell {
                        cell.setupCell(field: field)
                        cell.nationalitiesResponse = self.nationalitiesResponse
                        cell.cellTextField.delegate = nil
                        cell.cellTextField.tag = fieldIndex
                        cell.cellTextField.delegate = self
                        cell.countryButton.tag = fieldIndex
                        let existingItem = self.allCountriesCodes.first(where: { $0.FieldID == field.id })
                        if existingItem == nil {
                            
                            cell.countryButton.setTitle(self.defaultCountryCode?.name , for: .normal)
                            
                        } else {
                            cell.countryButton.setTitle(existingItem?.countryData.name, for: .normal)
                        }
                        cell.countryButton.removeTarget(self, action: #selector(didSelectPhoneCountryDropDown(button:)), for: .touchUpInside)
                        cell.countryButton.addTarget(self, action: #selector(didSelectPhoneCountryDropDown(button:)), for: .touchUpInside)
                        
                        return cell
                    }
                    
                    
                case .textArea, .address, .textEditor:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "KYCTableViewCell") as? KYCTableViewCell {
                        cell.setupCell(field: field)
                        cell.nationalitiesResponse = self.nationalitiesResponse
                        cell.textView.delegate = nil
                        cell.textView.tag = fieldIndex
                        cell.textView.delegate = self
                        return cell
                    }
                    
                case .dateTime:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "KYCTableViewCell") as? KYCTableViewCell {
                        cell.setupCell(field: field)
                        cell.nationalitiesResponse = self.nationalitiesResponse
                        cell.cellButton.tag = fieldIndex
                        cell.cellButton.removeTarget(self, action: #selector(dateTimePicker(button:)), for: .touchUpInside)
                        cell.cellButton.addTarget(self, action: #selector(dateTimePicker(button:)), for: .touchUpInside)
                        return cell
                    }
                    
                case .file:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "KYCTableViewCell") as? KYCTableViewCell {
                        cell.setupCell(field: field)
                        cell.nationalitiesResponse = self.nationalitiesResponse
                        cell.cellButton.tag = fieldIndex
                        cell.cellButton.removeTarget(self, action: #selector(importFile(button:)), for: .touchUpInside)
                        cell.cellButton.addTarget(self, action: #selector(importFile(button:)), for: .touchUpInside)
                        return cell
                    }
                    
                case .image:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "KYCTableViewCell") as? KYCTableViewCell {
                        cell.setupCell(field: field)
                        cell.nationalitiesResponse = self.nationalitiesResponse
                        cell.cellButton.tag = fieldIndex
                        cell.cellButton.removeTarget(self, action: #selector(importImage(button:)), for: .touchUpInside)
                        cell.cellButton.addTarget(self, action: #selector(importImage(button:)), for: .touchUpInside)
                        return cell
                    }
                    
                case .boolean:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "KYCTableViewCell") as? KYCTableViewCell {
                        cell.setupCell(field: field)
                        cell.nationalitiesResponse = self.nationalitiesResponse
                        cell.boolSwitch.tag = fieldIndex
                        cell.boolSwitch.removeTarget(self, action: #selector(switchValueChanged(sender:)), for: .valueChanged)
                        cell.boolSwitch.addTarget(self, action: #selector(switchValueChanged(sender:)), for: .valueChanged)
                        return cell
                    }
                    
                default:
                    return UITableViewCell()
                }
            } else {
                localRow -= rowsForField
                fieldIndex += 1
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        120.0
    }
    
}



extension KYCViewController: KYCChoiceDelegate {
    func didSelectItem(itemIndex: Int, newValue: Bool, tag: Int, newItem: GatetoPayOnboardingKYCDynamicField) {
        for sectionIndex in 0..<(sectionsArray?.count ?? 0) {
            
            if let rowIndex = sectionsArray?[sectionIndex].dynamicFields?.firstIndex(where: { $0.id == tag }) {
                
                sectionsArray?[sectionIndex].dynamicFields?[rowIndex] = newItem
                
                return
            }
        }
    }
    
}


extension KYCViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let row = textField.tag
        
        var cell: UIView? = textField
        while cell != nil, !(cell is KYCTableViewCell) {
            cell = cell?.superview
        }
        
        guard let tableViewCell = cell as? KYCTableViewCell,
              let indexPath = tableView.indexPath(for: tableViewCell) else {
            return
        }
        
        let section = indexPath.section
        switch sectionsArray?[indexPath.section].dynamicFields?[row].dataType {
        case .mobile:
            sectionsArray?[section].dynamicFields?[row].value = ""
            if let fieldID = sectionsArray?[section].dynamicFields?[row].id,
               let existingItem = self.allCountriesCodes.first(where: { $0.FieldID == fieldID }) {
                
                sectionsArray?[section].dynamicFields?[row].value = "\(existingItem.countryData.dial_code ?? "")\(textField.text ?? "")"
                
            } else {
                sectionsArray?[section].dynamicFields?[row].value = "\(self.defaultCountryCode?.dial_code ?? "")\(textField.text ?? "")"
            }
            
            
            
        default :
            sectionsArray?[section].dynamicFields?[row].value = textField.text
            
        }
        
    }
    
}

extension KYCViewController: UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard controller.documentPickerMode == .import,
              let url = urls.first else { return }
        
        //TODO: Fill data
        if let section = PickedFileSection, let row = PickedFileRow{
            if let image = UIImage(contentsOfFile: url.path) {
                self.sectionsArray?[section].dynamicFields?[row].imageData = image.jpegData(compressionQuality: 0.5)
                self.sectionsArray?[section].dynamicFields?[row].selectedImageName = url.lastPathComponent
                self.tableView.reloadData()
            } else if let pdf = PDFDocument(url: url) {
                self.sectionsArray?[section].dynamicFields?[row].fileData = pdf.dataRepresentation()
                self.sectionsArray?[section].dynamicFields?[row].selectedFileName = url.lastPathComponent
                self.sectionsArray?[section].dynamicFields?[row].selectedFileMimeType = url.mimeType
                self.tableView.reloadData()
            }
        }
        controller.dismiss(animated: true)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}

extension KYCViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //TODO: - Complete here
        if let section = PickedImageSection, let row = PickedImageRow{
            if let editedImage = info[.editedImage] as? UIImage {
                // self.imgProfile.image = editedImage
                self.sectionsArray?[section].dynamicFields?[row].imageData = editedImage.jpegData(compressionQuality: 0.5)
                if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset, let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                    self.sectionsArray?[section].dynamicFields?[row].selectedImageName = imageURL.lastPathComponent
                }
                self.tableView.reloadData()
            } else if let image = info[.originalImage] as? UIImage {
                self.sectionsArray?[section].dynamicFields?[row].imageData = image.jpegData(compressionQuality: 0.5)
                if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset, let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                    self.sectionsArray?[section].dynamicFields?[row].selectedImageName = imageURL.lastPathComponent
                }
                self.tableView.reloadData()
            }
        }
        
        // Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension KYCViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let row = textView.tag
        
        var cell: UIView? = textView
        while cell != nil, !(cell is KYCTableViewCell) {
            cell = cell?.superview
        }
        
        guard let tableViewCell = cell as? KYCTableViewCell,
              let indexPath = tableView.indexPath(for: tableViewCell) else {
            print("Failed to find cell or indexPath")
            return
        }
        
        let section = indexPath.section
        
        guard let field = sectionsArray?[section].dynamicFields?[row] else {
            print("Field not found at section: \(section), row: \(row)")
            return
        }
        
        sectionsArray?[section].dynamicFields?[row].value = textView.text
        print("Updated Field: Section \(section), Row \(row), New Value: \(textView.text ?? "nil")")
    }
    
    
    
}

extension KYCViewController: GatetoPayOnboardingKYCDelegate {
    func updateKYCFinishedWithError(error: String) {
        Dialogs.dismiss()
        Dialogs.showError(error)
    }
    
    
    func kycFinishedWithError(error: GatetoPayOnboardingError) {
        //TODO: - Show Error to user if needed
        Dialogs.dismiss()
        Dialogs.showError("The service is not available")
        
    }
    
    func kycFields(fields: GatetoPayOnboardingKYCFieldModel) {
        Dialogs.dismiss()
    }
    
    func didUpdateKYCSuccessfully(id: Int?) {
        Dialogs.dismiss()
        if let vc = storyboard?.instantiateViewController(withIdentifier: "CloseJourneyViewController") as? CloseJourneyViewController{
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension KYCViewController: StatusDelegate{
    func didPressNext() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}



struct CountryModel: Codable, Hashable {
    let name: String?
    let iso2: String?
    let dial_code: String?
    let flag: String?
}

func loadCountries() -> [CountryModel] {
    guard let url = Bundle.main.url(forResource: "country_codes_flags", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let countries = try? JSONDecoder().decode([CountryModel].self, from: data) else {
        return []
    }
    return countries
}

struct allCountriesCodesStruct {
    var countryData : CountryModel
    var FieldID : Int
}

extension URL {
    var mimeType: String {
        if #available(iOS 14.0, *) {
            if let type = UTType(filenameExtension: self.pathExtension) {
                return type.preferredMIMEType ?? "application/octet-stream"
            }
        } else {
            // Fallback on earlier versions
        }
        return "application/octet-stream"
    }
}
