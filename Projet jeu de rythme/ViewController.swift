import UIKit


class ViewController: UIViewController
{
    var lives: Int = 3

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func retour(for windSegue: UIStoryboardSegue, towards       subsequentVC: UIViewController)
    {
        print("La transition a été déroulée")
    }
    
    func gameRunning()
    {
        if(lives < 1)
        {
            
        }
    }

}
