import UIKit
import GatetoPayOnboardingSDK
class CloseJourneyViewController: UIViewController {

    /**
     This class for ....
     */
    
    //MARK: - Outlets
    
    
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
        self.showCloseJourneyAlert()
    }
    
    
    //MARK: - Actions
    
    //MARK:-Functions
    func showCloseJourneyAlert(){
        let ac = UIAlertController(title: "Enter Customer ID", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.textFields?.first?.keyboardType = .default
        ac.textFields?.first?.placeholder = "Customer ID"
        
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            let answer = ac.textFields![0].text ?? ""
            DispatchQueue.main.async {
                
                if answer.isEmpty{
                    self.showCloseJourneyAlert()
                    return
                }
                GatetoPayOnboarding.closeJourney.delegate = self
                GatetoPayOnboarding.closeJourney.closeJourneyAPI(customerId: answer )
            }
        }
        ac.addAction(submitAction)
        
        self.present(ac, animated: true)
    }
}

extension CloseJourneyViewController: StatusDelegate{
    func didPressNext() {
            self.navigationController?.popToRootViewController(animated: true)
    }
}

extension CloseJourneyViewController: GatetoPayOnboardingCloseJourneyDelegate {
    func didFinishCloseJourneyWithSuccess() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "StatusViewController") as? StatusViewController{
            vc.statusType = .profileSubmitted
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didFinishCloseJourneyWithError(error: GatetoPayOnboardingError) {
        
    }
}
