import UIKit
import DropDown

class NationalityViewController: UIViewController {


    /**
     This class for ....
     */
    
    //MARK: - Outlets
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var numberTextField: UITextField!
    
    
    //MARK: - Variables
    
    //MARK: - Class Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    //MARK: - Helpers
    func setupView(){
        
    }
    
    
    //MARK: - Actions
    @IBAction func countryButtonAction(_ sender: UIButton) {
        
        let dropDown = DropDown()

        // The view to which the drop down will appear on
        dropDown.anchorView = self.countryButton // UIView or UIBarButtonItem

        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = ["KSA", "Jordan", "UAE", "Palestine"]
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if item == "Palestine"{
                self.countryButton.setTitle("🇵🇸", for: .normal)
            }else if item == "UAE"{
                self.countryButton.setTitle("🇦🇪", for: .normal)
            }else if item == "KSA"{
                self.countryButton.setTitle("🇸🇦", for: .normal)
            }else{
                self.countryButton.setTitle("🇯🇴", for: .normal)
            }
            
            dropDown.hide()
        }
        
        dropDown.show()
        
    }
    
    @IBAction func verifyButtonAction(_ sender: Any) {
        if (numberTextField.text?.count ?? 0) == 0{
            Dialogs.showWarning("Please enter a phone number")
            return
        }else if (numberTextField.text?.count ?? 0) < 9{
            Dialogs.showWarning("Please enter a valid phone number")
            return
        }
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController{
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK:-Functions

}
