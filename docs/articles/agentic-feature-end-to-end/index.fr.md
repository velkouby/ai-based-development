---
title: "Du brief à la revue locale : une feature agentique de bout en bout"
author: "Vincent El Kouby-Benichou, Baracoda"
company: "Baracoda"
company_url: "https://baracoda.com"
description: >-
  Entre une demande en langage naturel et une pull request, un parcours agentique utile produit une chaîne d'artefacts, de contrôles et de preuves locales. Suivons une feature full-stack de bout en bout.
---

# Du brief à la revue locale : une feature agentique de bout en bout { .article-title }

Entre « ajoute la pagination de l'annuaire clients » et une pull request, il ne devrait pas y avoir une boîte noire appelée « l'agent a codé ». Un parcours agentique utile transforme la demande en tâches bornées, observe l'exécution, lance des contrôles et prépare une revue qui sépare les faits des déclarations.
{ .article-lead }

<p class="article-meta">
  <span>Par <span class="article-author">Vincent El Kouby-Benichou</span>, <a class="article-company-link" href="https://baracoda.com">Baracoda</a></span>
  <a class="article-contact-link" href="https://www.linkedin.com/in/vincentelkoubybenichou/">LinkedIn</a>
</p>

Dans [l'article précédent](../agent-coding-modes/index.md), l'exemple de la pagination serveur de l'annuaire clients a été classé comme une **fonctionnalité structurée**. Elle touche l'API, l'interface, un contrat de réponse et plusieurs états d'interface. Le parcours retenu est donc orchestré.

Cette décision ne dit pas encore ce qui se passe entre le brief et la revue. Dans beaucoup de pratiques, cette partie reste enfermée dans une conversation. À la fin, le diff existe, mais la chaîne de décisions qui l'a produit s'est évaporée.

Un workflow durable doit produire autre chose qu'un historique de chat. Il doit permettre de reconstruire l'exécution sans demander à l'agent de raconter après coup ce qu'il pense avoir fait.

> L'agent produit une proposition. Le workflow établit des faits observables. L'humain décide si ces faits suffisent.

Un framework qui met cette méthode en œuvre doit rendre explicites la planification, la préparation du contexte, le suivi des tâches, le contrôle des chemins, les validations, les tentatives et la synthèse de revue. Les artefacts présentés ici montrent comment un tel framework peut rendre le parcours inspectable.

## Étape 1 : transformer la demande en brief

La demande brute tient en une phrase :

> Ajouter une pagination serveur à l'annuaire clients.

Elle exprime une intention, pas encore un contrat de travail. Elle ne précise ni la forme de la réponse de l'API, ni la page initiale, ni les états de l'interface, ni ce qui doit rester hors périmètre. Laisser l'agent résoudre seul ces questions reviendrait à transformer des silences en décisions produit et techniques.

Voici un exemple pédagogique de brief clarifié. Il fixe le résultat sans imposer toute l'implémentation :

```markdown
## Objectif

Paginer côté serveur l'annuaire clients et permettre à l'utilisateur
de naviguer entre les pages depuis l'interface.

## Inclus

- faire évoluer la réponse de l'API avec la page courante et le nombre total de résultats ;
- charger la première page à l'ouverture ;
- conserver les états loading, empty et error ;
- tester les limites et le changement de page.

## Non-objectifs

- synchroniser la page dans l'URL ;
- modifier une primitive partagée ;
- ajouter une dépendance ;
- migrer ou restructurer les données existantes.

## Arrêter si

- le contrat doit devenir incompatible avec un consommateur existant ;
- une décision produit reste ouverte ;
- la solution exige une modification du socle partagé.
```

Le brief ne cherche pas à prédire chaque fichier. Il stabilise l'intention, les critères observables et l'autorité de décision. Les non-objectifs sont aussi importants que l'objectif : ils empêchent la solution techniquement la plus directe de redéfinir silencieusement la demande.

À cette étape, nous savons **ce qui est attendu**. Nous ne savons pas encore **comment le repository permet de le réaliser**, ni quelles tâches peuvent être confiées séparément à l'agent.

## Étape 2 : compiler un plan exécutable

Un plan agentique n'est pas une liste de verbes vagues comme « faire le backend », « faire le frontend » et « ajouter les tests ». Il doit produire des unités qui puissent être sélectionnées, exécutées, contrôlées et reprises.

Pour notre exemple, le découpage peut ressembler à ceci :

| Tâche | Résultat attendu | Dépend de | Écriture autorisée | Validation ciblée |
| --- | --- | --- | --- | --- |
| T-01 | Paginer la réponse de l'API et tester ses bornes | — | `backend/customers/**` | Tests de l'API clients |
| T-02 | Adapter le client et l'interface, avec les états existants | T-01 | `frontend/customers/**` | Tests de l'annuaire |
| T-03 | Relire la cohérence du contrat et de son intégration avant les contrôles | T-01, T-02 | Aucune écriture produit supplémentaire prévue | Tests et compilation du projet |


Le plan ajoute ce que le brief ne doit pas porter : dépendances, chemins modifiables, références en lecture seule, validations, conditions d'arrêt et exigences de preuve. Pour devenir exécutable, il doit contenir une matrice des frontières d'écriture. Le framework doit aussi attribuer des identifiants stables aux tâches, vérifier leurs dépendances et valider leur politique de chemins avant toute exécution.

Une question ouverte bloque la suite. Elle devient une intervention à résoudre ; la réponse est persistée puis transmise au prochain paquet d'exécution. Si elle modifie le découpage, le périmètre ou un autre élément structurant, le plan doit être recalculé avant la reprise. La décision ne disparaît donc pas entre la planification et l'exécution.

À la fin de cette étape, nous connaissons un chemin d'exécution possible. Nous n'avons toujours pas de code, et c'est une bonne chose : une incohérence de périmètre coûte moins cher à corriger dans un plan que dans un diff full-stack.

## La trace de bout en bout

Le parcours peut maintenant être représenté comme une chaîne. Chaque maillon reçoit une entrée, produit un artefact et ajoute une connaissance limitée.

| Maillon | Entrée | Sortie persistante | Ce que l'on peut alors affirmer |
| --- | --- | --- | --- |
| Qualification | Demande brute | Fiche de décision | Le niveau de contrôle choisi est explicite |
| Clarification | Demande et décisions humaines | Brief | L'intention, les critères et les non-objectifs sont écrits |
| Planification | Brief et règles du repository | Plan et tâches bornées | Le travail est découpé et les frontières sont déclarées |
| Préparation | Brief, plan, contrat, réponses et état local | Paquet d'exécution | Le runner reçoit un ordre de mission reconstituable |
| Implémentation | Paquet d'exécution | Résultat structuré du runner et diff | L'agent déclare ce qu'il a tenté et le code a changé |
| Contrôles | État initial, état final et politiques | Résultats de périmètre | Les chemins observés respectent ou violent les frontières déclarées |
| Validations | Commandes prévues et copie de travail | Codes de retour et sorties | Ces commandes ont produit ces résultats localement |
| Preuve locale | Résultats du runner, Git et contrôles | Artefact de tentative | L'exécution devient inspectable et reprenable |
| Revue locale | Brief, plan, tâches et preuves | Synthèse de revue | Les faits utiles sont rassemblés avant Git et la CI |

Cette table est le cœur du parcours. Aucune étape ne « prouve la feature » à elle seule. Chacune change seulement la nature de l'information disponible.

## Étape 3 : préparer ce que le runner reçoit

Le plan vient de découper la fonctionnalité en tâches précises. Chaque tâche décrit un résultat attendu, ses dépendances, son contexte utile, ses frontières d'écriture et ses validations. Ces tâches sont des unités de planification, de contrôle et de revue ; elles ne correspondent pas nécessairement à autant de sessions distinctes du runner.

Lorsque aucune décision bloquante n'est ouverte, le workflow sélectionne un **bloc cohérent de tâches** dont les dépendances peuvent être respectées pendant la même exécution. Il compile ce bloc dans un paquet d'exécution. Pour la pagination, T-01, T-02 et T-03 forment une chaîne cohérente : faire évoluer le contrat backend, adapter l'interface qui le consomme, puis relire leur cohérence avant les contrôles indépendants du workflow.

```text
plan de la fonctionnalité
  T-01 contrat backend
    -> T-02 intégration frontend
      -> T-03 revue de cohérence

bloc cohérent : [T-01, T-02, T-03]
  -> paquet d'exécution chargé une fois
  -> une session du runner
  -> un résultat structuré pour chaque tâche
```

Le paquet réunit deux niveaux de contexte :

- un contexte commun au bloc — brief, plan, décisions humaines, contrat du repository et état Git de départ ;
- un contexte propre à chaque tâche — résultat attendu, dépendances, chemins modifiables, références en lecture seule, validations et conditions d'arrêt.

Le runner charge ce paquet une seule fois et exécute le bloc dans son ensemble. Il peut ainsi raisonner sur la continuité du changement, passer du contrat backend à son consommateur frontend et conserver les mêmes décisions techniques pendant toute l'exécution. Le workflow évite de recharger le brief, les règles et les mêmes références pour chaque micro-tâche.

Ce regroupement réduit le nombre de sessions distinctes du runner, amortit le coût de préparation du contexte et laisse l'agent de code exploiter ses capacités de planification sur une modification cohérente couvrant plusieurs fichiers. Les agents de code savent déjà explorer une base de code, ordonner des modifications et coordonner plusieurs surfaces lorsqu'ils reçoivent un objectif et un contexte de qualité. Le workflow ne cherche donc pas à leur dicter chaque édition : il leur prépare un problème suffisamment précis et borné pour qu'ils puissent organiser efficacement l'implémentation détaillée.

> Le workflow planifie le travail au niveau des tâches. L'agent planifie l'implémentation à l'intérieur du paquet.

Un paquet n'est donc ni une tâche unique, ni toute la fonctionnalité par principe. Un plan plus large peut produire plusieurs paquets. Le bon paquet regroupe les tâches qui partagent une intention, des dépendances et un contexte, sans réunir des travaux indépendants dans un diff devenu difficile à contrôler.

Un framework qui adopte ce modèle doit compiler le paquet et exiger un résultat distinct pour chaque tâche. Mais il ne faut pas confondre structure et pertinence : un paquet bien formé peut encore contenir trop de contexte, manquer une référence décisive ou compiler une intention humaine insuffisamment clarifiée.

Nous ouvrirons ce paquet dans l'article suivant. Pour la vue de bout en bout, il suffit de retenir ceci : le runner ne reçoit pas seulement un prompt. Il reçoit un bloc de tâches ordonné, son contexte commun, les contraintes propres à chaque tâche et un état de départ.

## Étape 4 : séparer le résultat de l'agent des faits du workflow

À la fin du paquet, le runner renvoie un résultat structuré : statut global, résumé, résultat de chaque tâche, fichiers qu'il dit avoir modifiés, questions, blocages et avertissements. Le format est contrôlé. Une réponse incomplète ou impossible à raccorder aux tâches attendues peut faire échouer l'exécution avant les validations.

Supposons que, dans cet exemple pédagogique, le runner déclare :

```text
statut du paquet : terminé
T-01 : terminée
T-02 : terminée
T-03 : terminée
fichiers modifiés : cinq fichiers dans les zones clients
blocages : aucun
questions ouvertes : aucune
```

Ce résultat est utile pour le suivi, mais il reste une **déclaration de l'agent**. Le workflow ne doit pas utiliser la liste déclarée comme seule source de vérité. Après l'exécution du paquet, il inspecte séparément l'état de la copie de travail et compare les fichiers observés à l'enveloppe autorisée pour l'ensemble du paquet.

Sans captures intermédiaires entre T-01, T-02 et T-03, Git permet d'établir quels fichiers ont changé pendant le paquet, pas quelle tâche a produit chaque modification. La répartition par tâche vient du résultat structuré du runner et reste donc déclarative. Si cette attribution doit devenir indépendante, le workflow doit ajouter des checkpoints entre les tâches ou les exécuter dans des paquets séparés.

La nuance est essentielle : « l'agent dit avoir modifié cinq fichiers » et « le workflow a observé cinq chemins modifiés » sont deux phrases différentes. Si les listes divergent, la divergence elle-même doit devenir un fait de revue.

## Étapes 5 et 6 : contrôler avant de valider

Dans ce modèle, l'ordre des portes est déterminant : les validations prévues ne doivent être lancées que si le runner a terminé, si son suivi d'exécution existe, si tous les résultats attendus sont présents et complets, et si les contrôles de frontières et de politique de chemins réussissent.

L'ordre importe. Lancer des tests avant d'inspecter le périmètre peut produire un vert trompeur : le code fonctionne peut-être parce que l'agent a modifié une primitive qu'il n'avait pas le droit de toucher.

Le journal de la tentative pourrait alors consigner :

| Contrôle | Résultat | Interprétation légitime |
| --- | --- | --- |
| Résultats attendus du runner | Présents pour chacune des trois tâches | Le contrat de sortie du paquet est complet |
| Fichiers changés pendant l'exécution | Cinq chemins produit | Ces cinq chemins diffèrent entre les captures initiale et finale retenues |
| Frontières du paquet | Respectées | Aucun chemin observé n'est hors de l'enveloppe autorisée du paquet |
| Tests de l'API clients | Code retour 0 | Cette commande a réussi dans l'environnement local |
| Tests de l'annuaire | Code retour 0 | Cette commande a réussi dans l'environnement local |
| Compilation du projet | Code retour 0 | La compilation demandée s'est terminée avec succès |
| Contrôle qualité global | Non lancé dans ce run | Aucune conclusion ne peut être tirée sur ce contrôle |

Le dernier résultat mérite d'être écrit aussi visiblement que les résultats verts. Dans ce modèle, les validations déclarées pour les tâches sont orchestrées après les contrôles de périmètre, tandis que le profil qualité global reste une étape séparée à lancer explicitement. Tant qu'il n'a pas été lancé, le présenter comme implicitement réussi serait faux.

Le contrôle des chemins intervient après l'écriture et ne constitue pas un sandbox : il qualifie un écart de périmètre, pas la sécurité générale du processus. L'article consacré aux arrêts détaillera cette limite.

## Étape 7 : écrire une preuve locale

Après l'exécution et les contrôles, le workflow doit conserver un artefact pour la tentative du paquet. Voici un exemple pédagogique de manifeste :

```yaml
tentative:
  identite: "run-illustratif-01"
  resultat_agent: "termine"
  taches_attendues: [T-01, T-02, T-03]
  resultats_recus: [T-01, T-02, T-03]

git_local:
  etat_initial: "capture"
  etat_final: "capture"
  fichiers_changes_pendant_execution: 5

controles:
  frontieres: "reussies"
  politique_de_chemins: "respectee"
  validations_ciblees: "3 sur 3 reussies"
  qualite_globale: "non_executee"

limites:
  - "preuve locale, non liee immuablement a un commit"
  - "couverture des tests non evaluee automatiquement"
  - "acceptation metier encore humaine"
```

Ce manifeste montre les informations qu'un framework devrait conserver : le résultat du runner, le suivi, l'état Git local, les fichiers changés pendant l'exécution, les contrôles de frontières, les résultats de validation, les échecs et quelques métriques de base.

Cette preuve rend la tentative inspectable. Elle ne la rend pas automatiquement attribuable à une révision précise. Un état initial et un état final aident à distinguer ce qui a bougé pendant l'exécution, mais ne remplacent ni des identifiants de commit pour la base et la tête, ni une capture exhaustive de l'index, ni l'identification complète de l'environnement. Un working tree déjà modifié reste une source d'ambiguïté qui doit être signalée.

## Étape 8 : préparer la revue, sans décider à sa place

La revue locale devrait rassembler le brief, le plan exécuté, les tâches et leur état, les fichiers observés, les tentatives, les validations, les risques et les questions restantes. Le framework doit refuser de finaliser si une tâche reste incomplète ou si les contrôles requis échouent.

La synthèse ne doit toutefois pas aplatir la provenance. Une phrase comme « les tests passent » est trop vague si elle ne nomme pas les commandes, le lieu d'exécution et les validations absentes. De même, un résumé rédigé par un agent peut améliorer la lisibilité, mais il ne doit pas remplacer les résultats structurés dont il dérive.

À ce stade, une personne peut répondre sans rouvrir le chat :

- quelle intention a été clarifiée ;
- quelles tâches ont été planifiées, rendues exécutables puis exécutées ;
- quelles zones étaient modifiables ;
- quels chemins ont été observés ;
- quelles commandes ont réellement été lancées ;
- quelles limites et questions restent ouvertes.

Elle doit encore relire le diff, juger la pertinence des choix, confronter le comportement aux critères d'acceptation et décider si le risque résiduel est acceptable. L'automatisation prépare la décision ; elle ne reçoit pas l'autorité de la prendre.

## La revue locale n'est pas encore la PR

Le parcours décrit ici s'arrête volontairement avant le commit, la CI et la pull request. La preuve locale concerne une copie de travail et une tentative. La CI concerne une révision envoyée dans un environnement défini. La PR ajoute un espace de discussion, des contrôles de branche et une décision de merge.

Ces couches doivent être reliées, pas confondues :

```text
preuve locale
  -> diff relu
  -> commit identifié
  -> validations CI sur cette révision
  -> pull request
  -> décision humaine de merge
```

La **cible** la plus solide relierait explicitement l'identité de la tentative, le commit de base, le commit de tête, l'état de l'index, les versions d'outils, les validations locales, les résultats de CI et les critères d'acceptation. Tant que ces informations ne sont pas effectivement produites et reliées, il ne faut pas présenter cette cible comme acquise.

## Reproduire le protocole avec ses propres outils

Il n'est pas nécessaire d'adopter un framework particulier pour obtenir l'essentiel de cette chaîne. Une équipe peut commencer avec des fichiers versionnés et quelques scripts stables :

1. conserver la demande brute et écrire un brief avec des non-objectifs ;
2. découper le travail en tâches avec dépendances, chemins et validations ;
3. enregistrer l'état Git avant de confier la tâche à l'agent ;
4. exiger un résultat structuré, sans le traiter comme une preuve indépendante ;
5. inspecter l'état Git complet : modifications indexées, non indexées et fichiers non suivis ;
6. refuser de lancer ou d'accepter les validations si le périmètre est violé ;
7. enregistrer chaque commande, son code de retour et ce qui n'a pas été exécuté ;
8. produire une synthèse qui conserve les risques et les questions ;
9. relier ensuite cette trace au commit et aux résultats de CI.

Le premier gain est de pouvoir reprendre le travail, expliquer un arrêt et contester une conclusion à partir d'artefacts persistants.

## Conclusion

Une feature agentique de bout en bout n'est pas une conversation plus longue. C'est une succession de transformations : la demande devient un brief, le brief devient un plan, le plan devient un ordre de mission, le runner produit une proposition, le workflow observe le périmètre et les validations, puis la preuve locale alimente la revue.

Pour la pagination de l'annuaire clients, ce parcours rend la proposition reconstructible avant Git et la CI. Il ne prouve encore ni la couverture suffisante, ni la justesse métier, ni l'acceptabilité du merge. Ces décisions restent humaines.

La prochaine étape consiste à ouvrir la boîte noire située juste avant le runner : [**ce que l'agent reçoit vraiment, et comment construire un ordre de mission utile**](../agent-execution-package/index.md).

<div class="article-footer-contact">
  <p>Pour discuter de cet article ou me laisser un message public :</p>
  <a class="article-contact-link" href="https://github.com/velkouby/ai-based-development/issues/new?template=contact.yml">Message sur GitHub</a>
</div>
