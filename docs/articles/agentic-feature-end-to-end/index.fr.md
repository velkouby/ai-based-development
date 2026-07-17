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

Dans [l'article précédent](../agent-coding-modes/index.md), la pagination serveur de l'annuaire clients a été classée comme une **fonctionnalité structurée**. Elle touche l'API, l'interface, un contrat de réponse et plusieurs états d'interface. Le parcours retenu est donc orchestré.

Cette décision ne dit pas encore ce qui se passe entre le brief et la revue. Dans beaucoup de pratiques, cette partie reste enfermée dans une conversation. À la fin, le diff existe, mais la chaîne de décisions qui l'a produit s'est évaporée.

Un workflow durable doit produire autre chose qu'un historique de chat. Il doit permettre de reconstruire l'exécution sans demander à l'agent de raconter après coup ce qu'il pense avoir fait.

> L'agent produit une proposition. Le workflow établit des faits observables. L'humain décide si ces faits suffisent.

La méthode s'appuie sur un framework interne qui implémente et teste la planification, la préparation du contexte, le suivi des tâches, le contrôle des chemins, les validations, les tentatives et la synthèse de revue. L'article n'en publie ni la syntaxe, ni les schémas, ni les commandes.

Pour éviter de donner à l'exemple une valeur qu'il n'a pas, ses niveaux de vérité sont explicites :

| Statut | Ce qu'il qualifie dans cet article |
| --- | --- |
| **Vérifié** | Les capacités du workflow confirmées dans l'implémentation interne et ses tests |
| **Simplifié** | Les catégories d'artefacts et les champs renommés pour expliquer leur rôle sans documenter le framework |
| **Simulé** | Le contenu métier, les noms de fichiers, la chronologie et les résultats de la pagination présentés à des fins pédagogiques |
| **Observé** | Réservé à une exécution de référence archivée ; aucun résultat simulé ci-dessous n'est présenté sous ce statut |
| **Cible** | Les garanties souhaitables qui ne sont pas encore couvertes de bout en bout, notamment une preuve liée immuablement à une révision |

Les mécanismes sont implémentés, mais la trace publique qui suit est une reconstruction. Cette distinction permet de comprendre ce que le système peut honnêtement défendre.

## Étape 1 : transformer la demande en brief

La demande brute tient en une phrase :

> Ajouter une pagination serveur à l'annuaire clients.

Elle exprime une intention, pas encore un contrat de travail. Elle ne précise ni la forme de la réponse de l'API, ni la page initiale, ni les états de l'interface, ni ce qui doit rester hors périmètre. Laisser l'agent résoudre seul ces questions reviendrait à transformer des silences en décisions produit et techniques.

Le brief clarifié, ici **simulé et simplifié**, fixe le résultat sans imposer toute l'implémentation :

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

Pour notre exemple, le découpage public peut ressembler à ceci :

| Tâche | Résultat attendu | Dépend de | Écriture autorisée | Validation ciblée |
| --- | --- | --- | --- | --- |
| T-01 | Paginer la réponse de l'API et tester ses bornes | — | `backend/customers/**` | Tests de l'API clients |
| T-02 | Adapter le client et l'interface, avec les états existants | T-01 | `frontend/customers/**` | Tests de l'annuaire |
| T-03 | Vérifier l'intégration et la compatibilité attendue | T-01, T-02 | Aucune écriture produit supplémentaire prévue | Tests et compilation du projet |

Ces chemins sont **illustratifs**. Ils expriment une répartition des responsabilités et ne reproduisent pas l'arborescence du framework interne.

Le plan ajoute ce que le brief ne doit pas porter : dépendances, chemins modifiables, références en lecture seule, validations, conditions d'arrêt et exigences de preuve. Dans l'implémentation de référence, il ne peut pas être accepté sans une matrice des frontières d'écriture. Les tâches reçoivent des identifiants stables ; leurs dépendances et leur politique de chemins sont vérifiées. Ces capacités sont **vérifiées**.

Une question ouverte bloque la suite. Elle devient une intervention à résoudre ; la réponse est persistée puis transmise au prochain paquet d'exécution. Si elle modifie le découpage, le périmètre ou un autre élément structurant, le plan doit être recalculé avant la reprise. La décision ne disparaît donc pas entre la planification et l'exécution.

À la fin de cette étape, nous connaissons un chemin d'exécution possible. Nous n'avons toujours pas de code, et c'est une bonne chose : une incohérence de périmètre coûte moins cher à corriger dans un plan que dans un diff full-stack.

## La trace de bout en bout

La trace publique **simplifiée** peut maintenant être représentée comme une chaîne. Chaque maillon reçoit une entrée, produit un artefact et ajoute une connaissance limitée.

| Maillon | Entrée | Sortie persistante | Ce que l'on peut alors affirmer |
| --- | --- | --- | --- |
| Qualification | Demande brute | Fiche de décision | Le niveau de contrôle choisi est explicite |
| Clarification | Demande et décisions humaines | Brief | L'intention, les critères et les non-objectifs sont écrits |
| Planification | Brief et règles du repository | Plan et tâches bornées | Le travail est découpé et les frontières sont déclarées |
| Préparation | Brief, plan, contrat, réponses et état local | Paquet d'exécution | Le runner reçoit un ordre de mission reconstituable |
| Implémentation | Paquet d'exécution | Résultat structuré du runner et diff | L'agent déclare ce qu'il a tenté et le code a changé |
| Contrôles | État initial, état final et politiques | Résultats de périmètre | Les chemins observés respectent ou violent les frontières déclarées |
| Validations | Commandes prévues et copie de travail | Codes de retour et sorties | Ces commandes ont produit ces résultats localement |
| Preuve locale | Résultats du runner, Git et contrôles | Artefacts de tentative | L'exécution devient inspectable et reprenable |
| Revue locale | Brief, plan, tâches et preuves | Synthèse de revue | Les faits utiles sont rassemblés avant Git et la CI |

Cette table est le cœur du parcours. Aucune étape ne « prouve la feature » à elle seule. Chacune change seulement la nature de l'information disponible.

## Étape 3 : préparer ce que le runner reçoit

Lorsque les dépendances d'une tâche sont satisfaites et qu'aucune décision bloquante n'est ouverte, le workflow prépare un paquet d'exécution. Il réunit le brief, le plan, les tâches exécutables, le contrat du repository, les frontières d'écriture, les réponses humaines déjà obtenues, les références de contexte, les validations et un état Git local au départ.

Cette compilation est **vérifiée** dans le framework interne. Le runner n'a pas à reconstruire l'autorité de la tâche depuis tout l'historique du projet.

Dans la reconstruction publique, un paquet ne rend exécutable qu'une tâche à la fois. Les étapes de préparation, d'implémentation, de contrôle et de validation se répètent donc pour T-01, puis T-02 et enfin T-03. La tâche suivante ne reçoit son propre paquet qu'une fois ses dépendances satisfaites. La synthèse présentée plus bas agrège ces passages successifs ; elle n'est pas la réponse à un paquet unique.

Mais il ne faut pas confondre structure et pertinence. Un paquet bien formé peut encore contenir trop de contexte, manquer une référence décisive ou transporter une règle devenue obsolète. Il peut aussi compiler une intention humaine insuffisamment clarifiée. Le workflow vérifie la présence et la cohérence de certaines catégories ; il ne sait pas que leur sélection est optimale.

Nous ouvrirons ce paquet dans l'article suivant. Pour la vue de bout en bout, il suffit de retenir ceci : le runner ne reçoit pas seulement un prompt. Il reçoit une mission située dans une feature, un plan, un ensemble de tâches, un périmètre et un état de départ.

## Étape 4 : séparer le résultat de l'agent des faits du workflow

À chaque passage, le runner renvoie un résultat structuré : statut, résumé, résultat de la tâche, fichiers qu'il dit avoir modifiés, questions, blocages et avertissements. Le format est contrôlé. Une réponse incomplète ou impossible à raccorder à la tâche attendue peut faire échouer l'exécution avant les validations.

Supposons, dans notre scénario **simulé**, que la synthèse des trois passages contienne les déclarations suivantes :

```text
T-01 : terminée dans la première tentative
T-02 : terminée dans la tentative suivante
T-03 : terminée après les validations d'intégration
fichiers modifiés : cinq fichiers dans les zones clients
blocages : aucun
questions ouvertes : aucune
```

Cette synthèse est utile pour le suivi, mais elle agrège des **déclarations de l'agent**. Le workflow ne doit pas utiliser la liste déclarée comme seule source de vérité. Après chaque passage, il inspecte séparément l'état de la copie de travail et compare les fichiers observés aux politiques de la tâche concernée.

La nuance est essentielle : « l'agent dit avoir modifié cinq fichiers » et « le workflow a observé cinq chemins modifiés » sont deux phrases différentes. Si les listes divergent, la divergence elle-même doit devenir un fait de revue.

## Étapes 5 et 6 : contrôler avant de valider

Dans l'implémentation examinée, l'ordre des portes est **vérifié** : les validations prévues ne sont lancées que si le runner a terminé, si son suivi d'exécution existe, si tous les résultats attendus sont présents et complets, et si les contrôles de frontières et de politique de chemins réussissent.

L'ordre importe. Lancer des tests avant d'inspecter le périmètre peut produire un vert trompeur : le code fonctionne peut-être parce que l'agent a modifié une primitive qu'il n'avait pas le droit de toucher.

La trace **simulée** pourrait alors consigner :

| Contrôle | Résultat | Interprétation légitime |
| --- | --- | --- |
| Résultats attendus du runner | Présents pour chacune des trois tâches | Le contrat de sortie est complet pour les passages agrégés |
| Fichiers changés pendant l'exécution | Cinq chemins produit | Ces cinq chemins diffèrent entre les captures initiale et finale retenues |
| Frontières de tâche | Respectées | Aucun chemin observé n'est hors des zones autorisées |
| Tests de l'API clients | Code retour 0 | Cette commande a réussi dans l'environnement local |
| Tests de l'annuaire | Code retour 0 | Cette commande a réussi dans l'environnement local |
| Compilation du projet | Code retour 0 | La compilation demandée s'est terminée avec succès |
| Contrôle qualité global | Non lancé dans ce run | Aucune conclusion ne peut être tirée sur ce contrôle |

Le dernier résultat mérite d'être écrit aussi visiblement que les résultats verts. Dans l'état actuel de l'implémentation de référence, les validations déclarées pour les tâches peuvent être orchestrées après les contrôles de périmètre, tandis que le profil qualité global reste une étape séparée à lancer explicitement. Présenter cette étape comme implicitement réussie serait faux.

Le contrôle des chemins intervient après l'écriture et ne constitue pas un sandbox : il qualifie un écart de périmètre, pas la sécurité générale du processus. L'article consacré aux arrêts détaillera cette limite.

## Étape 7 : écrire une preuve locale

Après chaque passage, le workflow conserve un artefact de tentative. La revue locale peut ensuite les agréger. Dans la version publique **simplifiée**, cet ensemble peut être lu comme ce manifeste :

```yaml
execution:
  identite: "run-illustratif-01"
  tentatives:
    - tache: T-01
      resultat_agent: "termine"
    - tache: T-02
      resultat_agent: "termine"
    - tache: T-03
      resultat_agent: "termine"

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

Ce format n'est pas le schéma interne. Les champs sont renommés et le contenu est simulé. En revanche, la conservation des tentatives avec le résultat du runner, le suivi, l'état Git local, les fichiers changés pendant le run, les contrôles de frontières, les résultats de validation, les échecs et des métriques de base est **vérifiée**.

Cette preuve rend la tentative inspectable. Elle ne la rend pas automatiquement attribuable à une révision précise. Un état initial et un état final aident à distinguer ce qui a bougé pendant l'exécution, mais ne remplacent ni des identifiants de commit pour la base et la tête, ni une capture exhaustive de l'index, ni l'identification complète de l'environnement. Un working tree déjà modifié reste une source d'ambiguïté qui doit être signalée.

## Étape 8 : préparer la revue, sans décider à sa place

La revue locale rassemble le brief, le plan exécuté, les tâches et leur état, les fichiers observés, les tentatives, les validations, les risques et les questions restantes. Cette synthèse est **vérifiée** dans l'implémentation interne, de même que le refus de finaliser si une tâche reste incomplète ou si les contrôles requis échouent.

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

La **cible** la plus solide relierait explicitement l'identité de la tentative, le commit de base, le commit de tête, l'état de l'index, les versions d'outils, les validations locales, les résultats de CI et les critères d'acceptation. Le workflow étudié couvre déjà une part significative de la preuve locale ; il ne faut pas présenter toute cette cible comme acquise.

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
