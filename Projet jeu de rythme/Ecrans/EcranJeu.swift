import AVFoundation
import UIKit


class EcranJeu: UIViewController
{
    
    // Attributs
    
    @IBOutlet var objets: [UIButton]!
    @IBOutlet var objetsCliques: [UIImageView]!
    @IBOutlet weak var boutonRetour: UINavigationItem!
    
    static let nbObjets: Int = 32
    static let tailleCercle: CGFloat = 80.0
    static let periode: Int = 20 // Durée entre chaque images en millisecondes
    static let nbImagesAnimation: Int = 50
    
    static var longueur: CGFloat!
    static var largeur: CGFloat!
    static var lecteur: AVAudioPlayer!
    var fichierAudio = String()
    var nomMusique: String!
    var bpm: CGFloat!
    var offset: Int!
    var listeDelais: [Int]!
    var listeCoordonnees: [(CGFloat, CGFloat)]!
    var vies:  Int = 20
    var score: Int = 0
    var combo: Int = 0
    var enCours: Bool = true // Indique si le jeu est en cours
    
    
    
    // Instanciation
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Personnalisation du bouton de navigation
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "<- Accueil", style: .plain, target: self, action: #selector(appuiNavigation))
        
        // Tri des listes d'objets selon l'identifiant
        objets.sort(by: EcranJeu.comparerObjets)
        objetsCliques.sort(by: EcranJeu.comparerObjets)
        
        // Affectation des attributs spatiaux
        EcranJeu.longueur = self.view.frame.size.width - 47.0
        EcranJeu.largeur = self.view.frame.size.height - 110.0
        
        /*
         *  Affectation des listes de valeurs aléatoires
         *  (générées au lancement de la partie pour optimiser en cours de jeu)
         */
        self.listeDelais = Generation.genererDelais(bpm: self.bpm)
        self.listeCoordonnees = Generation.genererCoordonnees()
        
        // Affectation du lecteur
        do
        {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            self.fichierAudio = Bundle.main.path(forResource: self.nomMusique, ofType: "mp3")!
            EcranJeu.lecteur = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fichierAudio))
            
            // Délai qui laisse le temps au premier cercle de grossir
            let delaiAudio: Int = EcranJeu.periode * EcranJeu.nbImagesAnimation
            Dispatch.DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delaiAudio))
            {
                if self.enCours
                {
                    EcranJeu.lecteur.play()
                }
            }
        }
        catch
        {
            print ("Echec de la session audio")
        }
        
        // Boucle de jeu après le décalage audio
        Dispatch.DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(self.offset))
        {
            self.bougerGroupeRec()
            
            // On déclenche la victoire du joueur si l'audio se termine alors que le jeu est en cours
            let duree = Int(EcranJeu.lecteur.duration * 1000) - self.offset
            Dispatch.DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(duree))
            {
                if self.enCours
                {
                    
                    // Le joueur a gagné la partie
                    self.performSegue(withIdentifier: "segueVictoire", sender: self)
                }
            }
        }
        
        
    }
    
    
    
    // Envoi du score et des vies restantes à l'écran de fin
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // On arrête le jeu en cours et la musique
        self.enCours = false
        EcranJeu.lecteur.stop()
        
        /*
         *  La préparation ne doit concerner que les transitions vers l'écran de fin,
         *  et non les retours au menu d'accueil
         */
        if(segue.identifier == "segueDefaite" || segue.identifier == "segueVictoire")
        {
            let ecranSuivant = segue.destination as! EcranFin
            
            ecranSuivant.score = self.score
            ecranSuivant.vies  = self.vies
        }
    }
    
    
    
    // Compare 2 objets selon leurs identifiants
    
    static func comparerObjets(objetA: UIView, objetB: UIView) -> Bool
    {
        // Initialisation
        let identifiantA = Int(objetA.accessibilityIdentifier!)!
        let identifiantB = Int(objetB.accessibilityIdentifier!)!
        
        // Sortie : ordre croissant des entiers
        return identifiantA < identifiantB
    }
    
    
    
    // Procédure qui gère le mouvement de la collection de cercles
    
    func bougerGroupeRec()
    {
        // Cas récursif (arrêt si la partie est finie)
        if self.enCours
        {

            // Lancement du prochain groupe de cercles après la somme des délais
            let sommeDelais: Int = self.listeDelais.reduce(0, +)
            Dispatch.DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(sommeDelais))
            {
                self.bougerGroupeRec()
            }
            self.bougerCerclesRec(numObjet: 0)
        }
    }
    
    
    
    // Procédure qui gère le mouvement des cercles individuellement
    
    func bougerCerclesRec(numObjet: Int)
    {
        // Cas récursif (arrêt si l'on arrive au dernier cercle du groupe)
        if self.enCours && numObjet < EcranJeu.nbObjets
        {
            // Après un délai aléatoire...
            let delai = listeDelais [numObjet]
            
            // ... l'on déclenche la répétition de l'opération, avec le cercle suivant
            Dispatch.DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(delai))
            {
                self.bougerCerclesRec(numObjet: numObjet + 1)
            }
            
            // On récupère le cercle
            let objet: UIButton = self.objets [numObjet]
            let objetClique: UIImageView = self.objetsCliques [numObjet]
            
            /*
             *  On modifie son tag
             *  pour repérer que le joueur n'a pas encore cliqué dessus
             */
            objet.tag = 0
            
            // On le déplace aléatoirement dans la vue
            let coordonnees: (CGFloat, CGFloat) = listeCoordonnees [numObjet]
            objet.frame.origin.x = coordonnees.0
            objet.frame.origin.y = coordonnees.1
            objetClique.frame.origin.x = coordonnees.0
            objetClique.frame.origin.y = coordonnees.1
            
            // On met sa taille à zéro
            objet.frame.size.width  = 0.0
            objet.frame.size.height = 0.0
            objetClique.frame.size.width  = 0.0
            objetClique.frame.size.height = 0.0
            
            // On le réactive
            objet.isEnabled = true
            
            // On rend le bouton visible
            objet.isHidden = false
            objetClique.isHidden = true
            
            // On anime son apparition et sa disparition
            self.animer(objet: objet, vitesseApparition: 1.0)
            self.animer(objet: objetClique, vitesseApparition: 1.0)
        }
    }
    
    
    
    // Procédure qui gère l'apparition ou la disparition des cercles de la collection
    
    func animer(objet: UIView, vitesseApparition: CGFloat)
    {
        animerRec(objet: objet, vitesseApparition: vitesseApparition, numObjet: 0)
    }
    
    func animerRec(objet: UIView, vitesseApparition: CGFloat, numObjet: Int)
    {
        // Car récursif : lancement de l'apparition
        if numObjet < EcranJeu.nbImagesAnimation
        {
            /*
             *  Après un délai de quelques millisecondes,
             *  l'on déclenche le changement suivant sur l'image
             */
            Dispatch.DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(EcranJeu.periode))
            {
                self.animerRec(objet: objet, vitesseApparition: vitesseApparition, numObjet: numObjet + 1)
            }
            
            // Ajustement de la taille sur cette image
            let augmentation: CGFloat = vitesseApparition * EcranJeu.tailleCercle / CGFloat(EcranJeu.nbImagesAnimation)
            objet.frame.size.width  += augmentation
            objet.frame.size.height += augmentation
            
            // Décalage de l'image pour qu'elle reste centrée
            let decalage = -augmentation / 2
            objet.transform = objet.transform.translatedBy(x: decalage, y: decalage)
        }
        
        // Cas intermédiaire : lancement de la disparition
        else if vitesseApparition > 0.0
        {
            animer(objet: objet, vitesseApparition: -vitesseApparition * 1.5)
        }
        
        // Cas de base : réinitialisation
        else
        {
            // On cache l'objet
            objet.isHidden = true
            
            // Perte d'une vie si le joueur n'a pas appuyé sur ce cercle
            if objet.tag == 0
            {
                self.vies -= 1
                self.verifierVies()
            }
        }
    }

    
    
    // Le joueur a appuyé sur un cercle

    @IBAction func appuiCercle(_ cible: Any)
    {
        // Initialisation
        let objet = (cible as? UIButton)!
        let identifiant = Int(objet.accessibilityIdentifier!)!
        let objetClique = self.objetsCliques [identifiant]
        
        /*
         *  Si c'est la 1ère fois que le joueur a appuyé sur l'objet,
         *  on re-modifie le tag pour repérer cela
         *  et on ajoute les points au score
         */
        if objet.tag == 0
        {
            objet.tag = 1
            
            // On désactive le bouton
            objet.isEnabled = false
            
            // Signale au joueur que le bouton a été appuyé
            objet.isHidden       = true
            objetClique.isHidden = false
            
            // Calcul des points gagnés
            self.combo += 1
            let pointsTiming = Int(objet.frame.size.width * CGFloat(EcranJeu.nbImagesAnimation) / EcranJeu.tailleCercle)
            let facteurCombo = Int(log2(CGFloat(self.combo)))
            
            self.score += pointsTiming * facteurCombo
        }
    }
    
    
    
    // On retourne au menu en cas d'appui sur le bouton de navigation
    
    @objc func appuiNavigation()
    {
        self.performSegue(withIdentifier: "segueAccueil", sender: self)
    }
    
    
    
    // Change d'écran si le joueur a perdu (n'a plus de vies)
    
    func verifierVies()
    {
        if self.enCours && self.vies < 1
        {
            self.performSegue(withIdentifier: "segueDefaite", sender: self)
        }
    }
    
}
