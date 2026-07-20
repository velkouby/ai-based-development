---
title: "Quatre modes, deux parcours : choisir le bon niveau de contrôle"
author: "Vincent El Kouby-Benichou, Baracoda"
company: "Baracoda"
company_url: "https://baracoda.com"
description: >-
  Quatre situations concrètes sur le même annuaire clients montrent comment choisir un niveau de contrôle, un parcours et des conditions d'arrêt proportionnés au risque réel du changement.
---

# Quatre modes, deux parcours : choisir le bon niveau de contrôle { .article-title }

Un libellé à corriger, une action locale, une pagination de bout en bout et la découverte d'une primitive partagée à modifier ne doivent pas produire le même ordre de mission. Partons de ces quatre situations concrètes pour choisir, à chaque fois, le contexte, les validations et l'autorité réellement nécessaires.
{ .article-lead }

<p class="article-meta">
  <span>Par <span class="article-author">Vincent El Kouby-Benichou</span>, <a class="article-company-link" href="https://baracoda.com">Baracoda</a></span>
  <a class="article-contact-link" href="https://www.linkedin.com/in/vincentelkoubybenichou/">LinkedIn</a>
</p>

Dans [l'article précédent](../agent-ready-repository/index.md), nous avons préparé le terrain et projeté la forme d'un ordre de mission ainsi que du rapport attendu. Revenons maintenant au moment qui précède leur compilation : les règles, les zones et les commandes sont connues, mais un repository agent-ready ne choisit pas à lui seul la quantité de structure nécessaire pour chaque demande.

Imaginons que quatre situations se présentent au cours de la même matinée sur l'annuaire clients :

1. remplacer « Aucun résultat » par « Aucun client ne correspond à ces filtres » ;
2. ajouter une action « Réinitialiser les filtres » avec les mécanismes existants ;
3. ajouter une pagination serveur dans l'API et l'interface ;
4. découvrir, pendant l'étude de la pagination, que sa synchronisation dans l'URL exigerait une évolution du routeur partagé.

Un bon agent de code est probablement capable de modifier les quatre zones. Ce n'est pas la bonne question. Il faut décider ce que nous l'autorisons à décider, le contexte que nous lui fournissons, les faits que nous voulons relire et les découvertes qui doivent interrompre le travail.

Le texte fondateur, [Du vibe coding au développement agentique vérifiable](../ai-agent-based-coding-best-practices/index.md), distinguait quatre modes de développement avec agents. Nous allons maintenant les appliquer à ces situations concrètes.

> Le bon niveau de contrôle est le dispositif le plus léger qui rende le risque, le périmètre et l'autorité de décision visibles.

## Une matinée, quatre situations sur le même annuaire

Une première lecture donne déjà quatre traitements différents.

| Demande ou découverte | Fait dominant observé | Mode de départ | Parcours |
| --- | --- | --- | --- |
| Corriger le libellé de l'état vide | Changement local, visible et réversible | **Vibe coding contrôlé** | Léger, direct |
| Ajouter « Réinitialiser les filtres » | Plusieurs étapes, mais une seule zone produit et des contrats existants | **Codage guidé** | Léger, suivi |
| Ajouter la pagination serveur | API, interface, contrat interne et tests doivent évoluer ensemble | **Fonctionnalité structurée** | Orchestré |
| La synchronisation URL exige le routeur partagé | Primitive commune et consommateurs multiples | **Évolution du socle**, si ce besoin est retenu | Orchestré, dans un travail séparé |

Cette table donne le résultat. Voyons maintenant ce que chaque décision change réellement pour l'agent.

### Situation 1 : corriger le libellé de l'état vide

La demande est précise : lorsque des filtres ne renvoient aucun client, l'interface doit afficher « Aucun client ne correspond à ces filtres ».

Dans notre repository d'exemple, l'état vide et son test se trouvent dans `frontend/customers/**`. L'ordre de mission peut tenir en quelques lignes :

```markdown
Objectif : modifier le texte de l'état vide filtré.
Écriture autorisée : frontend/customers/**.
Contexte : réutiliser la traduction locale à la fonctionnalité et le test existant.
Validation : lancer le test ciblé de l'état vide, puis relire le diff.
Arrêter si : le texte provient d'un fichier généré ou si une primitive partagée doit changer.
```

L'agent localise la source, modifie le libellé et son test, lance la validation ciblée, puis présente le diff. Il n'a pas besoin d'un plan full-stack pour suivre cette séquence.

Le mot **contrôlé** reste essentiel. L'agent ne reçoit pas « corrige ça comme tu veux » : il reçoit une zone, une convention à réutiliser, une validation et une limite. Si le test ciblé réussit, nous savons seulement que ce test a réussi dans l'environnement local et que le diff est disponible pour relecture. Nous ne prétendons pas avoir validé toute l'application.

### Situation 2 : ajouter « Réinitialiser les filtres »

Cette fois, un clic doit remettre les filtres à leur valeur initiale et recharger l'annuaire. Le bouton du design system, la fonction de remise à zéro et le chargement de l'annuaire existent déjà.

La demande reste locale, mais elle exige plusieurs choix d'intégration. Un brief court les fixe avant le code :

```markdown
Comportement attendu :
- dans l'état vide, afficher « Réinitialiser les filtres » quand au moins un filtre est actif ;
- au clic, vider les filtres et recharger l'annuaire ;
- conserver les états loading, empty et error existants.

Réutiliser :
- le composant Button existant ;
- la fonction resetFilters() existante ;
- le mécanisme actuel de rechargement.

Non-objectifs :
- créer une nouvelle route d'API ;
- modifier `shared/state/**` ou le composant `Button` partagé.

Arrêter si : une autorisation, une dépendance ou une primitive partagée devient nécessaire.
```

Le mini-plan peut alors être très concret :

1. relier l'action existante à l'état vide de la fonctionnalité ;
2. ajouter un test vérifiant que le clic vide les filtres et relance le chargement ;
3. lancer les tests de la fonctionnalité et relire le diff.

Un suivi léger — brief, plan, checklist et court journal d'exécution — permet de reprendre le travail et de voir ce qui a été validé. Ce journal est utile, mais il reste écrit par l'agent : ce n'est pas une preuve indépendante.

Nous sommes en **codage guidé**. La tâche est non triviale, mais son résultat, ses chemins probables et les conventions à réutiliser sont connus. Si l'exploration révèle qu'il faut créer une route d'API, la demande ne s'élargit pas silencieusement : le travail s'arrête et doit être reclassé.

### Situation 3 : ajouter la pagination serveur

La phrase « ajouter la pagination serveur » masque plusieurs décisions coordonnées :

- l'API doit recevoir les paramètres de pagination prévus par les conventions du projet ;
- sa réponse doit fournir les éléments, la page courante et le nombre total de résultats ;
- l'interface doit charger la première page et permettre de naviguer ;
- les états `loading`, `empty` et `error` doivent continuer à fonctionner ;
- la taille par défaut et le comportement d'une page invalide doivent réutiliser une convention existante ou être décidés avant l'exécution ;
- le changement du contrat doit rester compatible avec ses consommateurs actuels.

Dans notre cas pédagogique, la convention existe déjà : la taille est fixée à 25 éléments et une page invalide renvoie HTTP 404 avec le code `pagination_page_invalide`. Ces choix rejoignent le brief ; l'agent n'a pas à les réinventer pendant l'implémentation.

Avant de coder, il faut donc rendre les décisions de contrat explicites et identifier leur propriétaire. Même sans compiler encore le plan, les surfaces à coordonner sont visibles :

| Surface | Changement attendu | Dépendance à respecter |
| --- | --- | --- |
| API clients — `backend/customers/**` | Paginer la réponse et couvrir les bornes | Le contrat retenu et ses consommateurs connus |
| Interface de l'annuaire — `frontend/customers/**` | Consommer les métadonnées et afficher la navigation | Le même contrat, sans l'inventer côté interface |
| Intégration | Vérifier la cohérence des deux côtés et les états existants | Backend et frontend terminés |

Le prochain article transformera cette carte en plan exécutable. À ce stade, elle suffit à montrer pourquoi un brief unique suivi d'une modification libre serait fragile. Le parcours devra conserver le brief, le plan, les frontières d'écriture, les décisions humaines, les validations et les résultats observés. Un agent pourra alors recevoir un contexte préparé pour exécuter un bloc de tâches cohérent, au lieu de reconstruire la mission depuis tout l'historique du projet.

Nous sommes dans une **fonctionnalité structurée** et un **parcours orchestré**. La difficulté ne vient pas nécessairement du volume de code ; elle vient du couplage entre plusieurs surfaces et de la décision de contrat qu'elles partagent.

### Découverte 4 : la synchronisation URL exige le routeur partagé

Supposons enfin que l'équipe veuille rendre la page partageable avec une URL comme `/customers?page=3`. L'exploration montre que le routeur commun ne sait pas encore gérer ce cas et que `shared/routing/**` est une zone protégée pour la tâche produit.

La bonne sortie de l'agent n'est pas une modification opportuniste du routeur. C'est un arrêt exploitable :

```markdown
Constat : la synchronisation exige une capacité absente du routeur partagé.
Limite : shared/routing/** est hors du périmètre d'écriture de la fonctionnalité ; il reste consultable en lecture seule.

Options :
1. conserver la page dans l'état local et livrer sans URL partageable ;
2. ouvrir une évolution séparée du routeur, avec étude des consommateurs.

Décision attendue : choisir si la synchronisation URL est requise pour cette livraison.
```

Le workflow peut constater qu'un diff a franchi `shared/routing/**`, mais ce contrôle intervient après l'écriture. Le meilleur résultat est donc que l'agent applique la condition d'arrêt dès qu'il comprend la dépendance. Aucun contrôle mécanique ne déduit à lui seul toutes les nécessités architecturales.

Si l'équipe choisit la seconde option, l'entrée du nouveau travail doit recenser les consommateurs du routeur, la compatibilité attendue, la transition, le retour arrière, les validations élargies et le responsable habilité à accepter l'impact.

C'est une **évolution du socle**. Elle suit un parcours orchestré, mais dans une unité de travail séparée. Le besoin produit explique pourquoi la primitive doit évoluer ; il n'autorise pas à modifier silencieusement toutes les fondations nécessaires.

## Qualifier concrètement la pagination

Les quatre exemples montrent le résultat. Pour rendre la décision reproductible, revenons à la pagination et appliquons la grille dans l'ordre.

### Porte 1 : chercher ce qui interdit un départ léger

Certains faits imposent un minimum de contrôle avant toute appréciation générale.

| Signal à vérifier | Ce que montre le ticket de pagination | Conséquence |
| --- | --- | --- |
| Sécurité, autorisations ou données sensibles | Aucun nouveau droit ni nouvel usage de données sensibles | Pas d'escalade sur ce point |
| Migration ou suppression de données | Aucune migration prévue | Pas d'escalade sur ce point |
| Nouvelle dépendance ou infrastructure | Explicitement hors périmètre | Arrêter si elle devient nécessaire |
| Contrat public ou externe | Contrat d'API interne, avec consommateurs à inventorier | Accord du propriétaire de l'API |
| Socle ou règle commune | Aucun changement partagé prévu | Arrêter si le routeur ou une primitive commune doit évoluer |
| Effet externe difficilement réversible | Aucun effet externe prévu | Pas d'escalade sur ce point |

Aucun signal ne transforme ici la pagination en travail de sécurité, de migration ou de socle. En revanche, le contrat interne empêche de traiter la demande comme une correction locale.

### Porte 2 : répondre à cinq questions observables

Les cinq dimensions ne produisent pas une note. Elles obligent à écrire ce que nous savons réellement.

| Question | Où regarder | Réponse pour la pagination |
| --- | --- | --- |
| **Portée :** quelles zones doivent changer ? | Arborescence, propriétaires et zones de responsabilité du repository | Backend clients, frontend clients et tests associés |
| **Ambiguïté :** peut-on écrire les critères d'acceptation sans inventer une décision ? | Demande, conventions et questions encore ouvertes | Résultat produit clair ; forme exacte du contrat à confirmer |
| **Réversibilité :** un retour Git supprime-t-il tout l'effet ? | Données persistantes, consommateurs et effets externes | Pas de donnée migrée, mais API et interface doivent revenir ensemble |
| **Surfaces et contrats :** qui consomme ce qui change ? | Appels API, types partagés, clients et tests | Interface et API interne couplées par un contrat commun |
| **Autorité :** qui peut accepter les conséquences ? | Propriétaires du module et du contrat | Responsable de la fonctionnalité et propriétaire de l'API |

Le risque dominant est maintenant visible : plusieurs surfaces doivent évoluer autour d'un contrat interne commun. Cela suffit pour retenir une **fonctionnalité structurée**, même sans migration, dépendance ou contrat public.

<figure class="article-diagram">
  <img src="../../../articles/agent-coding-modes/control-level-decision-flow.png" alt="Schéma de décision reliant la demande, les signaux d'escalade, cinq dimensions non notées, le risque dominant, le mode et le parcours, puis l'autorité de décision." loading="lazy" />
  <figcaption>Le risque dominant fixe le contrôle minimal ; les autres dimensions précisent le périmètre, les validations et l'autorité.</figcaption>
</figure>

## Mode, parcours et outil : trois questions différentes

Les exemples permettent maintenant de distinguer ces trois notions sans théorie supplémentaire.

- Le **mode** explique pourquoi le changement exige ce niveau de gouvernance : local, guidé, structuré ou partagé.
- Le **parcours** décrit ce qui va réellement se passer : entrées, étapes, suivi, contrôles, validations et relecture.
- L'**outil** exécute tout ou partie du parcours : fichiers Markdown, scripts, agent de code ou plateforme d'orchestration.

Le mode ne dépend donc pas de l'outil choisi. Changer de modèle ou d'interface ne transforme pas une migration en correction locale. À l'inverse, une équipe n'a pas besoin d'un orchestrateur complet pour relire correctement un petit diff.

## Deux parcours, vus comme des séquences de travail

Les quatre modes n'exigent pas quatre chaînes d'exécution. Deux parcours, avec des variantes proportionnées, suffisent.

| Cas | Séquence concrète | Ce qui reste à relire |
| --- | --- | --- |
| **Léger, direct** — vibe coding contrôlé | Demande bornée → règles locales → modification → test ciblé → diff | Le diff, la commande lancée et son résultat |
| **Léger, suivi** — codage guidé | Brief court → mini-plan → checklist → modification → validations déclarées → journal → diff | Le plan suivi, les écarts, les validations et le diff |
| **Orchestré, produit** — fonctionnalité structurée | Décision → brief clarifié → tâches bornées → contexte d'exécution → modifications → contrôles → validations déclarées → diff → revue locale | Les décisions, frontières, résultats par tâche, l'état des validations déclarées et les preuves locales |
| **Orchestré, partagé** — évolution du socle | Proposition d'impact → responsable identifié → travail séparé → modification → compatibilité → validations élargies → revue dédiée | Les consommateurs affectés, la transition et le rôle d'approbation |

Dans le parcours léger, l'agent peut maintenir lui-même le suivi. Celui-ci aide à reprendre et à relire le travail, mais il ne devient pas une attestation indépendante.

Dans le parcours orchestré, le workflow sépare davantage les rôles : l'agent propose et modifie ; le workflow contrôle les frontières, la présence et la forme des sorties ainsi que les validations déclarées ; l'humain décide si ces faits suffisent. L'absence de validation déclarée, comme toute validation déclarée mais non exécutée, doit rester visible. Les contrôles de chemins restent des contrôles après écriture, pas un sandbox.

## Trois cas qui trompent souvent

Le nombre de lignes reste un mauvais raccourci. Ces trois contre-exemples le montrent.

| Impression initiale | Fait dominant | Décision plus juste |
| --- | --- | --- |
| « Ce n'est qu'une condition d'autorisation sur trois lignes. » | Elle change qui peut voir ou modifier des données | Fonctionnalité structurée et décision de sécurité explicite ; évolution du socle si la règle est partagée |
| « Le renommage touche quarante fichiers, donc il faut tout orchestrer. » | Transformation mécanique dans une seule zone, sans contrat public ni donnée persistante | Codage guidé, parcours léger suivi, validations ciblées et diff mécanique relisible |
| « Il suffit d'ajouter un bouton Exporter en CSV. » | L'exploration révèle qu'aucune route d'export ni règle d'autorisation n'existe | Arrêt du travail guidé ; reclassification en fonctionnalité structurée avec décision produit et sécurité |

Une petite modification peut donc exiger une autorité forte. Un grand diff peut rester réversible et peu ambigu. Ce qui compte est l'effet du changement, pas son volume apparent dans Git.

## Le mode est une hypothèse révisable

La classification de départ n'est jamais une autorisation d'élargir le périmètre. L'exploration peut révéler une dépendance, un contrat externe, une migration ou une primitive partagée absente du ticket initial.

La quatrième situation illustre ce principe : la synchronisation dans l'URL exige `shared/routing/**`, déclaré hors du périmètre d'écriture. La tâche produit doit alors produire trois choses :

1. **le fait nouveau :** le routeur partagé ne couvre pas le besoin ;
2. **les options :** livrer la pagination avec un état local, ou ouvrir une évolution du socle ;
3. **la décision de reprise :** nouveau périmètre, nouveau responsable et nouvelles validations, ou maintien du non-objectif.

Pour la suite de la série, la décision est de conserver la synchronisation de l'URL comme **non-objectif**. La pagination peut continuer sans modifier le routeur. Une éventuelle évolution du socle restera un travail distinct.

Cette reclassification maîtrisée compte davantage qu'une taxonomie parfaite dès le départ. Une bonne grille n'essaie pas de prédire tout le code. Elle rend visibles les faits qui exigent une nouvelle décision.

## La fiche que l'article suivant va réellement recevoir

La décision peut maintenant être relue sans rouvrir la conversation. Pour la pagination, la fiche finale ressemble à ceci :

```markdown
# Décision — Pagination de l'annuaire clients

Demande : ajouter une pagination serveur à l'annuaire clients.

Résultats observables :
- l'API renvoie les éléments, la page courante et le nombre total ;
- l'annuaire charge la première page à l'ouverture ;
- l'utilisateur peut avancer et revenir sans dépasser les limites ;
- les états loading, empty et error restent distincts.

Constats de qualification et hypothèses de périmètre :
- écritures attendues dans backend/customers/** et frontend/customers/** ;
- contrat d'API interne à faire évoluer de manière coordonnée ;
- taille de page fixée à 25 par la convention existante ;
- page invalide traitée par une réponse HTTP 404 avec le code `pagination_page_invalide` ;
- aucun effet externe à annuler, mais un retour coordonné de l'API
  et de l'interface en cas d'abandon.

Non-objectifs :
- synchroniser la page dans l'URL ;
- modifier le routeur ou une autre primitive partagée ;
- ajouter une dépendance ;
- migrer ou restructurer les données.

Décision :
- mode : fonctionnalité structurée ;
- parcours : orchestré ;
- rôles à solliciter : responsable de la fonctionnalité et propriétaire de l'API ;
- entrée minimale : brief clarifié, critères d'acceptation et non-objectifs ;
- sortie minimale : tâches bornées, contrôles, résultats des validations
  déclarées, diff relisible et revue humaine.

Réévaluer si :
- une décision produit reste ouverte avant l'exécution ;
- un consommateur exige un contrat incompatible ;
- l'implémentation ne peut respecter l'un des non-objectifs.
```

Dans un autre repository, la taille de page ou le traitement d'une page invalide peuvent ne pas être définis. Ils deviennent alors des questions du brief : l'exécution attend leur résolution au lieu de transformer un silence en décision produit.

Cette fiche choisit le niveau de gouvernance. Elle ne remplace pas le contrat de tâche présenté dans l'article précédent : le contrat précisera ensuite les chemins, références, validations et conditions d'arrêt du travail exécutable.

Pour une autre demande, le modèle peut rester court :

```markdown
Demande et résultats observables :
Constats, hypothèses et non-objectifs :
Mode et parcours retenus :
Périmètre initial :
Entrée et sortie minimales :
Rôle d'approbation à solliciter :
Réévaluer si :
```

## Conclusion

Choisir un mode revient à préparer un ordre de mission proportionné. Pour le libellé, une zone, un test ciblé et un diff suffisent. Pour l'action locale, un brief et un mini-plan rendent le travail reprenable. Pour la pagination, plusieurs surfaces et un contrat commun justifient des tâches bornées, des contrôles persistants et une revue structurée. Pour le routeur partagé, le travail produit s'arrête et l'évolution du socle est traitée séparément.

Le repository fixe les règles du terrain. Le mode qualifie le changement. Le parcours organise le travail. Et la fiche désigne le rôle humain qui doit accepter les décisions et le risque résiduel.

La pagination est maintenant classée comme fonctionnalité structurée, son parcours est choisi et ses conditions de réévaluation sont écrites. [Le prochain article part de cette décision et suit la feature de bout en bout](../agentic-feature-end-to-end/index.md), du brief clarifié à la revue locale.

<div class="article-footer-contact">
  <p>Pour discuter de cet article ou me laisser un message public :</p>
  <a class="article-contact-link" href="https://github.com/velkouby/ai-based-development/issues/new?template=contact.yml">Message sur GitHub</a>
</div>
