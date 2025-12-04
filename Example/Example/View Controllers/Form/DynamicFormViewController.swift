import UIKit

class DynamicFormViewController: UIViewController {

    /**
     This class for ....
     */
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    
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
    @IBAction func submitButtonAction(_ sender: Any) {
        
    }
    
    
    //MARK:-Functions

}
