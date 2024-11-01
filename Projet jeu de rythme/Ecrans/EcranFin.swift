import AVFoundation
import UIKit


class EcranFin: UIViewController
{
    
    // Attributs
    
    static var lecteur: AVAudioPlayer!
    var fichierAudio = String()
    var nomMusique: String = "Syntax Error - Winter Golf"
    var vies:  Int!
    var score: Int!
    
    @IBOutlet weak var texteScore: UILabel!
    @IBOutlet weak var texteVies:  UILabel!
    
    
    
    // Instanciation
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Cache le bouton de navigation
        self.navigationItem.hidesBackButton = true
        
        // On affiche les résultats dans les labels
        self.texteScore.text = "Score : " + String(self.score)
        self.texteVies.text  = "Vies : "  + String(self.vies)
        
        // Affectation du lecteur
        do
        {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            self.fichierAudio = Bundle.main.path(forResource: self.nomMusique, ofType: "mp3")!
            EcranFin.lecteur = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fichierAudio))
            
            // On lance la musique que si aucune ne joue déjà
            if !EcranFin.lecteur.isPlaying
            {
                EcranFin.lecteur.play()
            }
        }
        catch
        {
            print ("Echec de la session audio")
        }
    }
    
    
    
    // Action pour la transition vers le menu d'accueil
    
    @IBAction func retourAccueil(_ for: UIStoryboardSegue)
    {
        // On arrête la musique en cours
        EcranFin.lecteur.stop()
        
        // Changement d'écran
        self.performSegue(withIdentifier: "segueAccueil", sender: self)
    }
    
}
