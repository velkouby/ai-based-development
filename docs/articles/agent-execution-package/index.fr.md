---
title: "Ce que l'agent reçoit vraiment : anatomie d'un ordre de mission"
author: "Vincent El Kouby-Benichou, Baracoda"
company: "Baracoda"
company_url: "https://baracoda.com"
description: >-
  À partir de la pagination de l'annuaire clients, ouvrons le paquet d'exécution transmis au runner : contexte commun, bloc de tâches, frontières, état Git et contrat de sortie.
---

# Ce que l'agent reçoit vraiment : anatomie d'un ordre de mission { .article-title }

Il est 9 h 34. Le brief de pagination est validé, les trois tâches sont prêtes et le runner n'a pas encore démarré. Ouvrons exactement ce qu'il va recevoir pour exécuter tout le bloc sans recharger trois fois le même contexte.
{ .article-lead }

<p class="article-meta">
  <span>Par <span class="article-author">Vincent El Kouby-Benichou</span>, <a class="article-company-link" href="https://baracoda.com">Baracoda</a></span>
  <a class="article-contact-link" href="https://www.linkedin.com/in/vincentelkoubybenichou/">LinkedIn</a>
</p>

Dans [l'article précédent](../agentic-feature-end-to-end/index.md), nous avons suivi la pagination serveur de l'annuaire clients du brief à la revue locale. Entre le plan et le runner apparaissait un paquet d'exécution. Arrêtons maintenant la chronologie juste avant le code pour l'ouvrir pièce par pièce.

Le plan contient trois tâches : faire évoluer l'API, adapter l'interface, puis contrôler leur cohérence. La page commence à `1`, la taille est fixée à `25`, une page invalide renvoie HTTP 404 avec le code `pagination_page_invalide`, et la synchronisation dans l'URL reste un non-objectif.

À ce stade, toutes les décisions nécessaires sont prises. Il reste à transformer ces informations en une unité que le runner peut exécuter sans reconstruire l'autorité de la mission depuis la conversation et tout le repository.

> Le paquet d'exécution n'est pas un prompt plus long. C'est un bloc de tâches ordonné, accompagné du contexte partagé, des limites propres à chaque tâche et d'un état de départ observable.

## 9 h 34 : un prompt de trois lignes ne suffit pas

On pourrait envoyer ceci à l'agent :

```text
Ajoute la pagination serveur à l'annuaire clients.
Modifie le backend, le frontend et les tests.
Respecte les conventions du repository.
```

L'instruction semble raisonnable. Pourtant, l'agent doit encore deviner presque tout ce qui gouverne son travail.

| Question pendant l'exécution | Ce que ces trois lignes ne disent pas |
| --- | --- |
| Quelle page charger d'abord ? | La page `1` |
| Combien d'éléments demander ? | `25` |
| Que faire d'une page invalide ? | Répondre HTTP 404 avec `pagination_page_invalide` |
| La page doit-elle apparaître dans l'URL ? | Non, elle reste dans l'état local pour cette livraison |
| Quels fichiers sont modifiables ? | Les zones clients du backend et du frontend, avec une frontière propre à chaque tâche |
| Les composants partagés peuvent-ils évoluer ? | Non ; ils sont consultables, mais leur modification exige un autre travail |
| Quelles commandes comptent ? | `make test-back`, `make test-front` et `make build-front` |
| Que restituer à la fin ? | Un résultat distinct pour T-01, T-02 et T-03, avec fichiers, commandes, questions et blocages déclarés |

Ajouter ces réponses dans un grand paragraphe ne résout qu'une partie du problème. Leur rôle resterait ambigu : une référence à consulter pourrait ressembler à une autorisation d'écriture, une suggestion du plan à une décision produit, et une validation attendue à une commande déjà exécutée.

Le paquet conserve ces catégories séparées afin que le runner sache quoi faire et que le workflow sache ensuite quoi contrôler.

## 9 h 35 : sélectionner un bloc cohérent de tâches

Le plan de la fonctionnalité contient cette chaîne :

```text
T-01 · contrat backend
  -> T-02 · intégration frontend
    -> T-03 · contrôle de cohérence
```

T-02 dépend du contrat produit par T-01. T-03 ne devient pertinente qu'après les deux modifications. Les trois tâches partagent aussi le même objectif, les mêmes décisions de pagination et les mêmes frontières générales. Elles forment donc un **bloc cohérent** que le runner peut exécuter dans une seule session.

```text
plan complet
  -> sélection [T-01, T-02, T-03]
  -> ajout du contexte commun et des contrats par tâche
  -> paquet pagination-clients-01
  -> une session du runner
  -> un résultat pour chaque tâche
```

Ce regroupement n'aplatit pas les tâches. T-02 reste dépendante de T-01 ; si T-01 découvre une incompatibilité avec un consommateur existant, le runner doit arrêter le paquet avant de présenter T-02 ou T-03 comme terminées.

Il ne donne pas non plus accès à toute la fonctionnalité par principe. Une évolution du routeur partagé ne rejoint pas ce bloc : la synchronisation URL est un non-objectif, `shared/routing/**` est en lecture seule et un changement de son interface publique aurait un autre propriétaire, d'autres consommateurs et d'autres validations.

> Le workflow planifie le travail au niveau des tâches. L'agent de code planifie les modifications détaillées à l'intérieur du bloc.

## 9 h 36 : charger le contexte commun une seule fois

Dans une implémentation, la partie commune du paquet peut ressembler à ceci :

```yaml
paquet:
  id: "pagination-clients-01"
  tentative: "001"
  bloc: [T-01, T-02, T-03]

  objectif: >-
    Ajouter une pagination serveur à l'annuaire clients et permettre
    de changer de page depuis l'interface.

  criteres_acceptation:
    - "L'API renvoie les éléments, la page courante et le nombre total."
    - "L'annuaire charge la page 1 à l'ouverture."
    - "Les actions précédente et suivante respectent les limites."
    - "Les états loading, empty et error restent distincts."

  decisions:
    premiere_page: 1
    taille_page: 25
    page_invalide:
      statut_http: 404
      code: "pagination_page_invalide"
    stockage_page: "etat local"

  non_objectifs:
    - "Synchroniser la page dans l'URL."
    - "Modifier une primitive partagée."
    - "Ajouter une dépendance."
    - "Migrer ou restructurer les données."

  references_communes:
    - "docs/customers/pagination.md"
    - "agent-docs/architecture.md"
    - "agent-docs/write-boundaries.md"

  enveloppe_ecriture:
    - "backend/customers/**"
    - "frontend/customers/**"

  lecture_seule:
    - "docs/customers/pagination.md"
    - "shared/ui/**"
    - "shared/state/**"
    - "shared/routing/**"

  interdit:
    - "tooling/**"
    - "generated/**"
    - "workflow-state/**"

  arreter_si:
    - "Une décision produit reste ouverte."
    - "Le contrat devient incompatible avec un consommateur existant."
    - "Une nouvelle dépendance est nécessaire."
    - "La solution exige une modification d'une zone partagée."
    - "Une validation exige d'élargir le périmètre ou l'environnement."
```

Le contexte commun est chargé une fois parce qu'il gouverne tout le bloc. Il ne remplace pas le contrat de chaque tâche. L'enveloppe d'écriture indique l'union maximale des zones du paquet ; elle ne signifie pas que T-01 peut modifier le frontend ou que T-02 peut réécrire le backend.

Le paquet ne contient pas non plus toute la documentation du projet. Il embarque les décisions courtes dont l'agent aura besoin en permanence et référence les documents précis à consulter. Les règles de paiement, les tâches futures et l'historique complet du chat n'aident pas à paginer l'annuaire ; ils restent hors du contexte.

<figure class="article-diagram">
  <img src="../../../articles/agent-execution-package/execution-package-anatomy.png" alt="Vue éclatée du paquet d'exécution de la pagination avec contexte commun, trois tâches ordonnées, références en lecture seule, chemins interdits, conditions d'arrêt et contrat de sortie." loading="lazy" />
  <figcaption>Le contexte voyage une fois ; les résultats, dépendances et frontières restent attachés à chaque tâche.</figcaption>
</figure>

## 9 h 37 : ouvrir les trois cartes de tâche

Le runner reçoit ensuite le résultat attendu, les dépendances, les chemins et la validation propres à chaque tâche.

```yaml
taches:
  - id: T-01
    resultat:
      - "GET /api/customers?page=2 renvoie items, page et total."
      - "Une page invalide renvoie HTTP 404 avec pagination_page_invalide."
    depend_de: []
    ecriture:
      - "backend/customers/api.py"
      - "backend/customers/tests/test_pagination.py"
    references_lecture_seule:
      - "docs/customers/pagination.md"
      - "frontend/customers/customer-api.ts"
    validation_attendue: "make test-back"
    arreter_si:
      - "Le contrat requis s'avère incompatible avec un consommateur existant."

  - id: T-02
    resultat:
      - "customer-api.ts transmet la page demandée."
      - "L'annuaire charge la page 1 à l'ouverture."
      - "Précédent est désactivé sur la page 1."
      - "Suivant est désactivé lorsque le total est atteint."
      - "Les états loading, empty et error restent couverts."
    depend_de: [T-01]
    ecriture:
      - "frontend/customers/customer-api.ts"
      - "frontend/customers/customer-list.tsx"
      - "frontend/customers/customer-list.test.tsx"
    references_lecture_seule:
      - "backend/customers/api.py"
      - "shared/ui/**"
      - "shared/state/**"
      - "shared/routing/**"
    validation_attendue: "make test-front"
    arreter_si:
      - "La solution exige de modifier Button, l'état partagé ou le routeur."

  - id: T-03
    resultat:
      - "Vérifier que le client consomme exactement le contrat backend."
      - "Vérifier qu'aucune synchronisation URL n'a été introduite."
      - "Signaler toute incohérence sans ouvrir un nouveau périmètre."
    depend_de: [T-01, T-02]
    ecriture: []
    references_lecture_seule:
      - "backend/customers/**"
      - "frontend/customers/**"
    validation_attendue: "make build-front"
```

Les cinq fichiers attendus ne sont donc pas une simple liste jointe au prompt. Deux appartiennent à T-01, trois à T-02 et aucun à T-03. Cette précision aide l'agent à ordonner son travail et permet de relire son compte rendu par tâche.

Elle ne prouve toutefois pas l'attribution. Comme le runner exécute tout le paquet dans une session et que le workflow n'ajoute pas de capture Git entre les tâches, le contrôle indépendant verra le diff du paquet. Il pourra confirmer que les cinq chemins restent dans l'enveloppe globale, mais pas que telle ligne a réellement été écrite pendant T-01 plutôt que T-02. Cette attribution restera déclarative.

Les validations ont le même statut à ce stade. `make test-front` figure dans T-02 parce que ce contrôle devra couvrir le comportement de l'annuaire. Le champ ne vaut pas résultat. Après le runner et le contrôle de périmètre, le workflow devra encore lancer ou observer la commande, conserver son code de retour et signaler toute validation absente.

## 9 h 38 : consigner l'état Git de départ

Juste avant de remettre le paquet au runner, le workflow observe la copie de travail :

```text
$ git branch --show-current
feature/customer-pagination

$ git rev-parse --short HEAD
7a31c42

$ git status --short --untracked-files=all
# aucune sortie
```

Le paquet conserve donc :

```yaml
git_depart:
  branche: "feature/customer-pagination"
  head: "7a31c42"
  fichiers_suivis_modifies: []
  fichiers_indexes: []
  fichiers_non_suivis: []
  etat: "propre"
```

Cette observation est utile : si cinq fichiers apparaissent après l'exécution, aucun d'eux n'était visible dans l'état initial retenu. Elle reste pourtant une entrée, pas une preuve finale. Elle ne dit rien des commandes qui réussiront, ne garantit pas que le runner restera sur cette branche et ne remplace pas l'état Git relevé à la fin.

Une implémentation devrait conserver l'identifiant Git complet même si l'article affiche sa forme courte. Si la copie de travail était déjà modifiée, le paquet devrait lister les chemins concernés ou déclarer explicitement que l'attribution des changements sera ambiguë.

## 9 h 39 : rendre l'ordre de mission au runner

Le paquet structuré peut maintenant être rendu sous une forme directe pour l'agent de code :

```text
Exécute T-01, puis T-02, puis T-03 dans cette session.

Charge le contexte commun une seule fois.
Respecte la frontière d'écriture propre à chaque tâche.
N'écris jamais dans shared/**, tooling/**, generated/** ou workflow-state/**.
La page reste dans l'état local ; ne synchronise pas l'URL.

Arrête tout le paquet dès qu'une condition d'arrêt est rencontrée.
Ne présente pas une tâche dépendante comme terminée après cet arrêt.

Retourne un résultat distinct pour T-01, T-02 et T-03 avec :
- le statut et le résultat obtenu ;
- les fichiers que tu déclares avoir modifiés ;
- les commandes que tu déclares avoir lancées ;
- les questions, avertissements et blocages restants.
```

Le texte est plus court que les données qui l'ont produit, car il peut résumer et ordonner ce qui compte pour le runner. La structure complète reste disponible au workflow pour contrôler le résultat. Cette séparation évite d'utiliser le texte rendu comme seule trace de l'autorité accordée.

Le contrat de sortie attendu peut être tout aussi explicite :

```yaml
resultat_runner:
  statut_paquet: "termine | bloque | echec"
  resultats_taches:
    - id: "T-01"
      statut: "..."
      resume: "..."
      fichiers_declares: []
      commandes_declarees: []
      blocage: null
  questions_ouvertes: []
  avertissements: []
```

Au moment où la tentative `001` commence, aucun de ces résultats n'est encore rempli. Le paquet fixe la forme de la réponse ; il ne préjuge pas de son contenu. Une fois la session terminée, la liste déclarée par l'agent devra être comparée à l'état Git observé, et les validations attendues à leurs exécutions réelles.

## Retrouver l'origine de chaque décision

La provenance devient concrète lorsqu'on suit quelques valeurs du paquet jusqu'à leur source.

| Valeur compilée | Source | Autorité pour cette valeur |
| --- | --- | --- |
| Objectif et critères | Brief de la fonctionnalité | Résultat produit attendu |
| Taille `25` et erreur `pagination_page_invalide` | `docs/customers/pagination.md` | Convention du domaine validée |
| Page conservée dans l'état local | Décision prise pendant la qualification | Arbitrage de cette livraison |
| `shared/routing/**` en lecture seule | Contrat du repository resserré par le plan | Frontière architecturale de la tâche |
| T-02 dépend de T-01 | Plan exécutable | Ordre du travail |
| Copie de travail propre à `7a31c42` | Observation Git de 9 h 38 | Fait local au départ de la tentative |

L'autorité dépend du sujet. Le plan peut resserrer les chemins autorisés par le repository ; il ne peut pas rendre modifiable une zone que celui-ci protège. Une observation Git peut établir qu'un fichier est présent ; elle ne peut pas décider si ce changement est souhaitable.

La compilation doit donc refuser les contradictions au lieu de les fusionner dans une prose ambiguë. Si T-02 déclarait soudainement `shared/routing/**` modifiable, le paquet ne devrait pas être lancé. Si la taille de page valait `50` dans une tâche alors que la décision persistée vaut `25`, l'écart devrait être résolu avant le runner.

## Ce que ce paquet permet — et ce qu'il ne permet pas

À 9 h 39, le runner dispose d'une mission plus précise sans recevoir tout le projet dans sa fenêtre de contexte. Il peut coordonner l'évolution de l'API et de son consommateur, conserver les mêmes décisions pendant les trois tâches et organiser lui-même les éditions détaillées.

Le workflow gagne aussi des points de comparaison : tâches attendues, union des chemins modifiables, références en lecture seule, validations et forme de sortie. Mais ces gains ont des limites nettes.

- Le paquet **décrit une autorité** ; il ne retire pas à lui seul les permissions du processus. Sans sandbox, le contrôle des chemins intervient après l'écriture.
- Les commandes du paquet sont **des validations attendues**, pas des résultats. Un code de retour doit être observé et enregistré séparément.
- Une capture avant et après la session qualifie **le diff du paquet**, pas l'auteur de chaque modification par tâche.
- Un état Git propre au départ améliore l'attribution locale, mais ne lie pas encore la tentative à une révision finale prête au merge.
- Une structure valide ne garantit pas que le contexte sélectionné est pertinent, complet ou à jour.
- Un paquet trop large diluerait de nouveau l'objectif. L'évolution éventuelle du routeur reste donc une unité de travail distincte.

> Un bon paquet n'empêche pas l'agent de se tromper. Il rend ses instructions, ses limites et ses écarts comparables à des faits.

## Vérifier le paquet avant de lancer la tentative

Pour cette pagination, la revue avant exécution tient en dix questions concrètes :

- ☐ Les critères nomment-ils la page initiale, les limites et les états d'interface ?
- ☐ La taille `25` et l'erreur 404 viennent-elles encore de la source de décision actuelle ?
- ☐ T-01, T-02 et T-03 peuvent-elles s'enchaîner sans dépendance extérieure au bloc ?
- ☐ Chaque fichier modifiable appartient-il à une tâche précise ?
- ☐ `shared/ui/**`, `shared/state/**` et `shared/routing/**` sont-ils bien en lecture seule ?
- ☐ `tooling/**`, `generated/**` et `workflow-state/**` restent-ils interdits ?
- ☐ Les trois commandes attendues sont-elles indépendantes du futur rapport de l'agent ?
- ☐ Chaque condition d'arrêt indique-t-elle quand ne pas poursuivre la tâche suivante ?
- ☐ L'état Git couvre-t-il les fichiers suivis, indexés et non suivis ?
- ☐ Le runner doit-il rendre un résultat séparé pour chacune des trois tâches ?

Si l'une de ces réponses manque, il vaut mieux corriger le paquet que demander à l'agent de combler le silence pendant l'implémentation.

## Conclusion

La tentative `001` est maintenant prête. Le runner recevra une seule fois le brief, les décisions, les règles et l'état Git de départ. Il exécutera T-01, T-02 et T-03 dans la même session, tout en conservant leurs dépendances, leurs frontières et leurs résultats distincts.

Le gain ne vient pas d'un prompt particulièrement persuasif. Il vient d'un travail préparatoire précis : sélectionner un bloc cohérent, retirer le contexte sans rapport, préserver la provenance, annoncer les validations et rendre les arrêts actionnables.

Mais un paquet bien préparé n'assure pas une exécution sans incident. Une décision peut manquer, une frontière peut être franchie ou une validation peut échouer. [L'article suivant montre comment qualifier ces arrêts et reprendre sans effacer la tentative précédente](../agent-task-stop-and-resume/index.md).

<div class="article-footer-contact">
  <p>Pour discuter de cet article ou me laisser un message public :</p>
  <a class="article-contact-link" href="https://github.com/velkouby/ai-based-development/issues/new?template=contact.yml">Message sur GitHub</a>
</div>
