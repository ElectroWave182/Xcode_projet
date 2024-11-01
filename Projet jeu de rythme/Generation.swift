import UIKit


class Generation
{
    
    // Fonction qui génère les délais entre chaque note
    
    static func genererDelais(bpm: CGFloat) -> [Int]
    {
        // Initialisation
        var sommeBattements: Int = 0
        var listeDelais: [Int] = Array()
        var delai: Int
        
        // Conversion des minutes aux nanosecondes
        let conversion = 6 * Int(pow(10.0, 10))
        
        for _ in 0 ..< EcranJeu.nbObjets
        {
            // Délai long (1) ou court (0)
            let longOuCourt = Int(Generation.nbAleatoire() * 2)
            var nbBattements: Int
            
            // Temps fort, sinon temps faible
            if Generation.nbAleatoire() * 3 < 2
            {
                nbBattements = longOuCourt * 2 - sommeBattements % 2 + 2
            }
            else
            {
                nbBattements = longOuCourt * 2 + sommeBattements % 2 + 1
            }
            sommeBattements += nbBattements
            
            // Conversion du nombre de battements en nanosecondes
            delai = nbBattements * conversion / 2
            delai = Int(CGFloat(delai) / bpm)
            
            listeDelais.append(delai)
            print("delai = \(delai)")
        }
        
        return listeDelais
    }
    
    
    
    // Fonction qui génère les positions de chaque cercle
    
    static func genererCoordonnees() -> [(CGFloat, CGFloat)]
    {
        // Initialisation
        var occupes: [Int: (CGFloat, CGFloat)] = Dictionary()
        var aleaX: CGFloat!
        var aleaY: CGFloat!
        var essais: Int!
        
        for numObjet in 0 ..< EcranJeu.nbObjets
        {
            /*
             *  On se laisse une sécurité de 100 générations
             *  pour éviter les boucles infinies sur les petits écrans
             */
            essais = 0
            while essais < 100
            {
                essais += 1
                
                // On le déplace aléatoirement dans la vue
                aleaX = Generation.nbAleatoire() * (EcranJeu.longueur - EcranJeu.tailleCercle) + (EcranJeu.tailleCercle / 2.0) + 47
                aleaY = Generation.nbAleatoire() * (EcranJeu.largeur - EcranJeu.tailleCercle) + (EcranJeu.tailleCercle / 2.0) + 110
                
                // On arrête s'il est dans une zone où aucun autre cercle ne se trouve
                if Generation.emplacementLibre(occupes: occupes, emplacement: (aleaX, aleaY))
                {
                    break
                }
            }
            
            // On finit par stocker la position du cercle
            print("x = \(aleaX!), y = \(aleaY!)")
            occupes [numObjet] = (aleaX, aleaY)
        }
        
        return Array(occupes.values)
    }
    
    
    
    // Vérifie si un emplacement de la vue est libre pour l'apparition d'un cercle
    
    static func emplacementLibre(occupes: [Int: (CGFloat, CGFloat)], emplacement: (CGFloat, CGFloat)) -> Bool
    {
        // Initialisation
        var obstructionHorizontale: Bool
        var obstructionVerticale: Bool
        var libre: Bool = true
        
        // On vérifie si la vue de l'objet ne coïncide pas avec une vue d'un autre objet
        for obstacle in occupes.values
        {
            obstructionHorizontale = abs(emplacement.0 - obstacle.0) > EcranJeu.tailleCercle
            obstructionVerticale   = abs(emplacement.1 - obstacle.1) > EcranJeu.tailleCercle
            libre = libre && (obstructionHorizontale || obstructionVerticale)
            
            if !libre
            {
                return false
            }
        }
        
        return true
    }
    
    
    
    // Fonction qui donne un décimal aléatoire entre 0 et 1
    
    static func nbAleatoire() -> CGFloat
    {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX)
    }

}
