
import UIKit

class InstructionsViewController: UIViewController {
    
    @IBOutlet weak var instructionsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(ConstsKey.HEBREW_ID, forKey: ConstsKey.PREFFERED_LANGUAGE)
        UserDefaults.standard.synchronize()
        initInstructions()
        instructionsView.layer.cornerRadius = 10
    }
    
    func initInstructions()
    {
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
    
    @IBOutlet weak var firstIns: UILabel!
    @IBOutlet weak var secondIns: UILabel!
    @IBOutlet weak var thirdIns: UILabel!
    @IBOutlet weak var fourthIns: UILabel!
    @IBOutlet weak var fifthIns: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var descriptionIns: UILabel!
    
    
    @IBAction func doneBtn(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
