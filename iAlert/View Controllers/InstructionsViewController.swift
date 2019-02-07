
import UIKit

class InstructionsViewController: UIViewController {
    
    @IBOutlet weak var instructionsView: UIView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var firstIns: UILabel!
    @IBOutlet weak var secondIns: UILabel!
    @IBOutlet weak var thirdIns: UILabel!
    @IBOutlet weak var fourthIns: UILabel!
    @IBOutlet weak var fifthIns: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var descriptionIns: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initInstructions()
        instructionsView.layer.cornerRadius = 10
    }
    
    func initInstructions()
    {
        doneBtn.setTitle("done".localized, for: .normal)
        let paragraphStyle = NSMutableParagraphStyle()
        if let currentLanguage = UserDefaults.standard.string(forKey: ConstsKey.PREFFERED_LANGUAGE)
        {
            switch currentLanguage{
            case "he":
                paragraphStyle.alignment = .right
            case "en":
                paragraphStyle.alignment = .left
            default:
                paragraphStyle.alignment = .left
            }
        }
        
        instructionLabel.text = "Instructions".localized
        
        let attributes = [NSAttributedStringKey.paragraphStyle: paragraphStyle]
        
        descriptionIns.attributedText = NSAttributedString(string: "descriptionInst".localized, attributes: attributes)
        firstIns.attributedText = NSAttributedString(string: "firstIns".localized, attributes: attributes)
        secondIns.attributedText = NSAttributedString(string: "secondIns".localized, attributes: attributes)
        thirdIns.attributedText = NSAttributedString(string: "thirdIns".localized, attributes: attributes)
        fourthIns.attributedText = NSAttributedString(string: "fourthIns".localized, attributes: attributes)
        fifthIns.attributedText = NSAttributedString(string: "fifthIns".localized, attributes: attributes)
    }
    
    
    @IBAction func doneBtn(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
