import UIKit
import OTPFieldView

class OTPViewController: UIViewController {


    /**
     This class for ....
     */
    
    //MARK: - Outlets
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var otpNumberLabel: UILabel!
    @IBOutlet weak var otpFieldView: OTPFieldView!
    
    
    //MARK: - Variables
    var timer : Timer?
    var currentTime = 0
    let fullTime = 60
    var otp = ""
    
    //MARK: - Class Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        currentTime = fullTime
        setupTimeLabel()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    //MARK: - Helpers
    func setupView(){
        setupOtpView()
        
    }
    
    func setupTimer(){
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            
            self.currentTime -= 1
            if self.currentTime <= 0{
                self.currentTime = 0
                self.timer?.invalidate()
            }
            
            self.setupTimeLabel()
            
        })
    }
    
    func setupOtpView(){
        otpFieldView.fieldsCount = 5
        otpFieldView.fieldBorderWidth = 0
        otpFieldView.defaultBorderColor = UIColor.black
        otpFieldView.filledBorderColor = UIColor("EAECEF")
        otpFieldView.cursorColor = UIColor.clear
        otpFieldView.displayType = .roundedCorner
        otpFieldView.filledBackgroundColor = UIColor("EAECEF")
        otpFieldView.defaultBackgroundColor = UIColor("EAECEF")
        otpFieldView.fieldSize = (otpFieldView.frame.width / 5) - 35
        otpFieldView.separatorSpace = 10
        otpFieldView.shouldAllowIntermediateEditing = true
        otpFieldView.delegate = self
        otpFieldView.initializeUI()
    }
    
    
    //MARK: - Actions
    @IBAction func sendAgainButtonAction(_ sender: Any) {
        if currentTime == 0{
            //resend
            currentTime = fullTime
            setupTimeLabel()
            setupTimer()
        }else{
            //show dialog
        }
    }
    
    @IBAction func submitButtonAction(_ sender: Any) {
        if otp.count == 5 && otp == "12345"{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "StatusViewController") as? StatusViewController{
                vc.statusType = .phoneValidation
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            Dialogs.showWarning("Please enter a valid OTP")
        }
    }
    
    
    //MARK:-Functions
    func setupTimeLabel(){
        self.secondsLabel.text = "\(self.currentTime) \("Seconds")"
    }
}

extension OTPViewController: OTPFieldViewDelegate {
    func hasEnteredAllOTP(hasEnteredAll hasEntered: Bool) -> Bool {
        print("Has entered all OTP? \(hasEntered)")
        return false
    }
    
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otp otpString: String) {
        otp = otpString
        print("OTPString: \(otpString)")
    }
}


extension OTPViewController: StatusDelegate{
    func didPressNext() {
        self.navigationController?.popViewController(animated: false)
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ScanIDViewController") as? ScanIDViewController{
            vc.pageType = .nationality
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
