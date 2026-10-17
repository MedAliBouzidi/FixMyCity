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
    
    FixMyCity est une solution de gestion territoriale des anomalies urbaines (chaussée dégradée, éclairage défaillant, dépôts sauvages). Elle orchestre un circuit de validation complet : les citoyens signalent les incidents, les administrateurs centralisent et mandatent des agents de terrain pour vérifier la véracité des faits isolés, les agents valident et priorisent l'anomalie, puis les techniciens procèdent à la réparation.
    
-   **Application servant de charge de travail :**
    
    Application web multi-tiers développée en interne (Next.js, NestJS, MySQL), conteneurisée et totalement sans état (stateless).
    
-   **Composants applicatifs et rôle de chacun :**
    
    1.  _Frontend Web (Next.js) :_ Interface responsive offrant trois vues dédiées : le portail citoyen (création et consultation de ses signalements), le centre de supervision administrateur (revue, déclenchement d'inspections, assignation des techniciens), et l'espace mobile des agents/techniciens (validation terrain, changement de statut, rapport de clôture).
        
    2.  _API Backend (NestJS) :_ Moteur d'orchestration gérant l'authentification basée sur les rôles (RBAC), les règles de seuil (alerte automatique vers la mairie dès 10 signalements identiques), le calcul des priorités et l'émission des métriques de santé.
        
    3.  _Base de données (RDS MySQL) :_ Base de données managée hébergée en sous-réseau privé. Elle stocke les comptes utilisateurs, le registre des incidents, le journal d'audit des statuts et les métadonnées des photos.
        
    4.  _Stockage Objets (S3) :_ Stockage sécurisé des photos de signalement en accès privé strict, ainsi qu'à l'export des sauvegardes de la base.
        

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
    
    - Réseau et sécurité : VPC, 2 sous-réseaux publics, 2 sous-réseaux privés applicatifs, 2 sous-réseaux privés base de données, Passerelle Internet (IGW), Tables de routage explicites, Security Groups stricts.
    - Calcul et élasticité : Application Load Balancer (ALB), Auto Scaling Group (min 2 instances, max 4), Launch Template, instances EC2 t3.micro avec volumes EBS gp3.
    - Données et fichiers : RDS MySQL, compartiment S3 privé.
    - Observabilité : CloudWatch Logs (centralisation des logs applicatifs), CloudWatch Dashboard, et 2 alarmes actives (taux d'erreurs 5xx et saturation CPU).   
    
-   **Services optionnels mobilisés (§4.2) :**
    
    - Amazon SNS: Utilisé pour router les notifications critiques (plus de 10 signalements sur la même voie, ou déclenchement d'alarmes d'infrastructure) vers les e-mails de l'équipe et de l'administrateur.
    - SDK Python (Boto3) : Script d'audit de conformité vérifiant la présence des étiquettes obligatoires du groupe (Project=FixMyCity, Env=Dev) et script d'aide au nettoyage de fin de séance.
    
-   **Solution d'accès sortant envisagée (§5.3) :**
    
    Dépendances pré-empaquetées via ECR pour limiter les coûts.
    
-   **Points de risque identifiés :**
    
    1.  Dépassement budgétaire lié à l'oubli de destruction de l'ALB et de l'instance RDS après une séance.
        
    2.  Impossibilité de créer des rôles IAM personnalisés sur AWS Academy (utilisation impérative de `LabRole`).
        
    3.  Perte de synchronisation du fichier d'état (`terraform.tfstate`) entre les sessions des étudiants.
