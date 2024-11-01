import AVFoundation
import UIKit


class EcranAccueil: UIViewController
{
    
    // Attributs
    
    static var lecteur: AVAudioPlayer!
    static var lecteurJoue: Bool = false
    var fichierAudio = String()
    var nomMusique: String = "Syntax Error - Sunny Suburbs"
    var dicoMusiques: [String: (CGFloat, Int)] = [:]
    var bpm: CGFloat!
    var offset: Int!
    
    

    // Instanciation
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Cache le bouton de navigation
        self.navigationItem.hidesBackButton = true
        
        /*
         *  Remplissage des infos sur chaque musique :
         *
         *           |                           Nom                            |   BPM   | Offset |
         */
        dicoMusiques ["DJ Mehdi [android52 Remix] - Signatune"]                 = (128    , 95   )
        dicoMusiques ["FIBRE - SSM2044"]                                        = (119    , 146  )
        dicoMusiques ["Hitomi Sato [VanilluxePavilion Remix] - Driftveil City"] = (126    , 124  )
        dicoMusiques ["Lensko - Cetus"]                                         = (128    , 169  )
        dicoMusiques ["Lensko - Circles"]                                       = (128    , 170  )
        dicoMusiques ["Lensko - Let's Go!"]                                     = (128    , 136  )
        dicoMusiques ["Lensko - Standby"]                                       = (128    , 1365 )
        dicoMusiques ["Levantine [Agent Stereo Remix] - Midnight"]              = (127    , 207  )
        dicoMusiques ["MEGAS - Stargazer"]                                      = (92.4   , 46   )
        dicoMusiques ["Professor Kliq - Tail Lights"]                           = (126    , 180  )
        dicoMusiques ["SAINT PEPSI - tell me"]                                  = (98     , 138  )
        dicoMusiques ["she - Chiptune Superstar"]                               = (133.503, 379  )
        dicoMusiques ["she - Journey 3"]                                        = (125    , 3048 )
        dicoMusiques ["Tzesar - Listen To My Heart"]                            = (128    , 53   )
        dicoMusiques ["Vasily Umanets - The Tool"]                              = (125.013, 51   )
        dicoMusiques ["Vexento - Glow"]                                         = (127    , 22809)
        dicoMusiques ["Vexento - Sons of Norway"]                               = (130    , 83   )
        dicoMusiques ["憂鬱 - Slow"]                                             = (105    , 36719)
        
        // On lance la musique que si aucune ne joue déjà
        if !EcranAccueil.lecteurJoue
        {
            // Affectation du lecteur
            do
            {
                try AVAudioSession.sharedInstance().setMode(.default)
                try AVAudioSession.sharedInstance().setActive(true)
                
                self.fichierAudio = Bundle.main.path(forResource: self.nomMusique, ofType: "mp3")!
                EcranAccueil.lecteur = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fichierAudio))
                
                EcranAccueil.lecteur.play()
                EcranAccueil.lecteurJoue = true
            }
            catch
            {
                print ("Echec de la session audio")
            }
        }
    }
    
    
    
    // Envoi des informations sur la musique au contrôleur de jeu
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        /*
         *  La préparation ne doit concerner que les transitions vers l'écran de jeu,
         *  et non les swipes d'un menu à l'autre
         */
        if(segue.identifier == "segueJeu")
        {
            let ecranSuivant = segue.destination as! EcranJeu
            
            // Envoi du nom, des BPM et du décalage en ms.
            ecranSuivant.nomMusique = self.nomMusique
            ecranSuivant.bpm        = self.bpm
            ecranSuivant.offset     = self.offset
            
            // On arrête la musique en cours
            EcranAccueil.lecteur.stop()
            EcranAccueil.lecteurJoue = false
        }
    }
    
    
    
    // Action pour la transition vers l'écran de jeu
    
    @IBAction func demarrerJeu(_ cible: UIButton)
    {
        // Identification de la musique
        self.nomMusique  = cible.titleLabel!.text!
        self.nomMusique += " - "
        self.nomMusique += cible.subtitleLabel!.text!
        
        // Identification des BPM
        self.bpm    = self.dicoMusiques [self.nomMusique]!.0
        
        // Identification de l'offset
        self.offset = self.dicoMusiques [self.nomMusique]!.1
        
        // Changement d'écran
        self.performSegue(withIdentifier: "segueJeu", sender: self)
    }

}
