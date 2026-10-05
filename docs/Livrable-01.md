## Fiche de sujet à soumettre
### Identification

-   **Titre du projet :** FixMyCity — Plateforme Cloud Citoyenne de Signalement et Traitement des Dégradations Urbaines
    
-   **Membres du groupe :** 
    - Bouzidi Med Ali
    - Sarra Mejaouel
    - Salma Kochtben
    - Imen Ben Amor
    
-   **Dépôt Git :**  [FixMyCity.git](https://github.com/MedAliBouzidi/FixMyCity.git) 
    

### Description du sujet

-   **Domaine métier et problème traité :**
    
    FixMyCity est une plateforme citoyenne et municipale permettant aux utilisateurs de signaler des anomalies dans l'espace public (nids-de-poule, éclairage public défaillant, dépôts sauvages, voirie abîmée) avec géolocalisation et photos, et aux services municipaux d'organiser, prioriser et résoudre ces incidents.
    
-   **Application servant de charge de travail :**
    
    Application web multi-tiers développée en interne (Next.js, NestJS, MySQL), conteneurisée et totalement sans état (stateless).
    
-   **Composants applicatifs et rôle de chacun :**
    
    1.  _Frontend Web (Next.js) :_ Interface responsive pour la soumission citoyenne de signalements avec formulaire photo et tableau de bord de suivi pour les agents de la mairie.
        
    2.  _API Backend (NestJS) :_ Gestion métier, validation des données, upload/génération d'URLs pré-signées S3, et déclenchement des notifications.
        
    3.  _Base de données (RDS MySQL) :_ Persistance relationnelle des utilisateurs, signalements, catégories, statuts, adresses et métadonnées des photos.
        
    4.  _Stockage Objets (S3) :_ Stockage sécurisé des photos de signalement en accès privé strict.
        
    5.  _Composants bonus (§4.2) :_ SQS + Lambda pour le redimensionnement asynchrone des photos (thumbnails) et SNS pour l'envoi d'alertes automatiques à la mairie en cas de concentration anormale d'incidents (e.g >10 par rue).
        

### Objectifs non fonctionnels auto-imposés

| **Objectif** | **Cible fixée par le groupe** | **Mode de démonstration** | 
|--|--|--|
| **Tolérance à la perte d'une instance applicative** | Indisponibilité perçue < 5 secondes, zéro perte de session/signalement en cours. | Terminaison manuelle d'une instance EC2 de l'ASG : l'ALB bascule immédiatement vers la seconde instance sans erreur 502/504 côté client, et l'ASG réinstancie automatiquement une nouvelle machine. |
| **Charge nominale et charge de pointe visées** | Nominale : 25 req/s (2 instances) ; Pointe : 120 req/s avec passage automatique à 4 instances sous 3 minutes. | Injection de charge HTTP simulant un afflux de signalements via un script, vérifiant la politique de mise à l'échelle CloudWatch. |
| **Temps de reconstruction complet de l'infrastructure** | < 10 minutes (temps dominé par le provisionnement RDS). | Exécution d'une seule commande `terraform apply` sur un compte Learner Lab vierge jusqu'au statut HTTP 200 sur l'ALB. |
| **Perte de données maximale admissible** | RPO < 24 h (sauvegardes automatiques quotidiennes) ; RTO < 15 minutes. | Restauration démontrée en direct à partir d'un snapshot RDS et vérification de l'intégrité des signalements enregistrés. |
| **Budget total consommé sur le semestre** | Consommation cumulée < 25 USD par compte étudiant (soit 50 % de marge de sécurité sur les 50 $). | Script de destruction automatique en fin de séance (`terraform destroy`), suivi du solde dans `/docs/journal-destructions.md`, alarme CloudWatch de budget. |

### Faisabilité préliminaire

-   **Services obligatoires mobilisés (§4.1) :**
    
    VPC, Subnets multi-AZ (publics et privés), Route Tables, IGW, Security Groups, EC2, EBS, ALB, Auto Scaling Group, Launch Template, RDS MySQL, S3, CloudWatch Logs/Metrics/Alarmes.
    
-   **Services optionnels mobilisés (§4.2) :**
    
    Amazon SNS (alertes par e-mail/SMS pour les signalements critiques ou les pannes), Amazon SQS + AWS Lambda (traitement et génération de miniatures des photos d'incidents).
    
-   **Solution d'accès sortant envisagée (§5.3) :**
    
    Dépendances pré-empaquetées via ECR pour limiter les coûts.
    
-   **Points de risque identifiés :**
    
    1.  Dépassement budgétaire lié à l'oubli de destruction de l'ALB et de l'instance RDS après une séance.
        
    2.  Impossibilité de créer des rôles IAM personnalisés sur AWS Academy (utilisation impérative de `LabRole`).
        
    3.  Perte de synchronisation du fichier d'état (`terraform.tfstate`) entre les sessions des étudiants.
