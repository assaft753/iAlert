
import UIKit

class InstructionsViewController: UIViewController {
    
    @IBOutlet weak var instructionsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instructionsView.layer.cornerRadius = 10
    }
    
    @IBAction func doneBtn(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
