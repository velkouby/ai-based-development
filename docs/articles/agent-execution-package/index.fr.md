---
title: "Ce que l'agent reçoit vraiment : anatomie d'un ordre de mission"
author: "Vincent El Kouby-Benichou, Baracoda"
company: "Baracoda"
company_url: "https://baracoda.com"
description: >-
  Un agent ne devrait pas recevoir un super-prompt, mais un paquet d'exécution compilé depuis le brief, le plan, les règles du repository, les décisions humaines et l'état Git de départ. Voici comment le construire sans perdre la provenance ni l'autorité de chaque information.
---

# Ce que l'agent reçoit vraiment : anatomie d'un ordre de mission { .article-title }

Un agent n'a pas besoin d'un super-prompt qui résume tout le projet. Il a besoin d'un ordre de mission borné : une compilation du résultat attendu, des tâches exécutables, des règles du repository, des décisions humaines, des validations et de l'état local au moment où le travail commence.
{ .article-lead }

<p class="article-meta">
  <span>Par <span class="article-author">Vincent El Kouby-Benichou</span>, <a class="article-company-link" href="https://baracoda.com">Baracoda</a></span>
  <a class="article-contact-link" href="https://www.linkedin.com/in/vincentelkoubybenichou/">LinkedIn</a>
</p>

Dans [l'article précédent](../agentic-feature-end-to-end/index.md), nous avons suivi une fonctionnalité structurée du brief à la revue locale. Entre le plan et l'implémentation apparaissait une étape courte dans la chronologie, mais déterminante pour l'exécution : la construction du paquet transmis au runner agent.

La question est simple en apparence : **que reçoit réellement l'agent au moment de coder ?** La réponse ne devrait être ni « tout le repository », ni « toute la conversation », ni « un prompt très détaillé ». Ces solutions mélangent l'intention, les règles et les faits observés dans un texte dont l'origine devient difficile à reconstruire.

Un framework qui met ce principe en œuvre doit assembler plusieurs sources avant de confier un bloc de tâches à l'agent : brief, plan, tâches sélectionnées, contrat du repository, décisions enregistrées, références de contexte, validations et aperçu de l'état Git initial. L'exemple ci-dessous montre ce que cet ordre de mission devrait contenir pour préserver la provenance, l'autorité de chaque information et l'état de départ.

> Le paquet d'exécution n'est pas le texte qui convainc l'agent de bien travailler. C'est l'ordre de mission qui lui indique ce qu'il doit accomplir, d'où viennent ses contraintes et où s'arrête son autorité.

## Pourquoi ce n'est pas un super-prompt

Un prompt formule des instructions à un modèle. Un paquet d'exécution décrit une unité de travail pour un système : un bloc ordonné de tâches, leur contexte partagé et leurs contraintes propres.

Un super-prompt peut contenir un objectif, des règles et des extraits de documentation. Mais une fois tout fusionné en prose, leur rôle se brouille : une liste de fichiers peut être prise pour une autorisation, une suggestion du plan pour une règle du repository, ou une ancienne décision pour un fait actuel.

Un paquet d'exécution conserve ces distinctions. Il peut être transporté au runner sous une forme structurée, puis rendu partiellement en texte pour le modèle. Le format de transport n'est pas le sujet. Ce qui compte est que le workflow puisse, avant et après la session du runner :

- identifier la source de chaque contrainte importante ;
- sélectionner les tâches réellement exécutables ;
- distinguer les chemins modifiables des références en lecture seule ;
- repérer une décision humaine déjà prise ;
- enregistrer l'état local à partir duquel l'exécution commence ;
- comparer le résultat aux limites annoncées ;
- conserver les validations attendues indépendamment de ce que l'agent déclare avoir lancé.

Cette structure ne crée toutefois aucune permission système. Écrire « lecture seule » dans un paquet ne retire pas les droits d'écriture du processus. Le paquet décrit l'autorité accordée ; un sandbox peut la faire respecter en amont, ou un contrôle de diff peut détecter une violation en aval. Il faut toujours dire lequel des deux est en place.

## Quatre sources, quatre formes d'autorité

Le paquet de la pagination de l'annuaire clients est compilé depuis quatre familles de sources.

| Source | Ce qu'elle apporte | Autorité principale | Ce qu'elle ne peut pas décider |
| --- | --- | --- | --- |
| Humain | Objectif, non-objectifs, critères d'acceptation, réponses et arbitrages | Intention produit et décisions réservées | Les faits réellement présents dans le code ou dans Git |
| Repository | Architecture, responsabilités, frontières stables, commandes de référence | Règles techniques et politiques applicables au projet | Le résultat produit attendu pour ce paquet, sauf s'il est déjà contractuel |
| Planification | Découpage, dépendances, contexte utile, validations par tâche | Ordre opérationnel dérivé de l'intention et des règles | Élargir le brief ou contourner une politique du repository |
| Runtime | Tâches sélectionnées, tentative courante, état Git observé, emplacement du suivi | Faits de l'exécution présente | Inventer une intention ou approuver un risque métier |

Il ne s'agit pas d'une hiérarchie unique où une source gagnerait toujours contre les autres. L'autorité dépend du sujet.

L'humain fait autorité sur le résultat à obtenir. Le repository fait autorité sur la propriété des zones de code. Le plan ordonne le travail sans pouvoir réécrire ces deux contrats. Le runtime fait autorité sur ce qu'il observe maintenant, mais un fait Git ne dit pas si un changement est souhaitable.

Cette séparation permet de traiter les conflits proprement. Si le plan place un dossier protégé dans les chemins modifiables, le workflow ne doit pas présenter cette incohérence comme une autorisation valide. Si le brief demande un comportement qui exige une décision produit encore ouverte, le plan ne doit pas transformer cette lacune en choix technique implicite. Dans les deux cas, compiler l'ordre de mission devrait échouer ou produire un arrêt explicite.

> La provenance dit d'où vient l'information. L'autorité dit pour quelle décision elle fait foi. Les deux doivent survivre à la compilation.

## Compiler l'ordre de mission

La compilation peut être représentée sans dépendre d'un outil particulier :

```text
brief et décisions humaines ─┐
                             │
contrat du repository ───────┼─> sélection et résolution ─> paquet d'exécution ─> runner agent
                             │
plan, tâches et dépendances ─┤
                             │
état Git observé ────────────┘
```

Le mot « compilation » n'est pas décoratif. Comme un compilateur, cette étape transforme plusieurs entrées ayant des rôles différents en une représentation exécutable plus étroite. Elle peut aussi refuser une entrée incohérente.

Pour une fonctionnalité structurée, le workflow doit au minimum effectuer cinq opérations.

Premièrement, il sélectionne un bloc de tâches exécutables en séquence. La première est prête au début de la session ; les suivantes deviennent exécutables lorsque les tâches précédentes du bloc sont terminées. Une décision ouverte ou une dépendance extérieure au bloc continue, elle, de bloquer l'exécution.

Deuxièmement, il conserve les frontières prévues pour chaque tâche et construit l'enveloppe autorisée du paquet. Regrouper trois tâches ne donne pas à l'agent une autorisation générale sur le repository : le diff observé doit rester dans l'union contrôlée de ces frontières.

Troisièmement, il rattache les décisions déjà prises. Si la première page et la taille initiale ont été arbitrées, l'agent ne doit ni reposer la question, ni choisir d'autres valeurs.

Quatrièmement, il sélectionne un contexte commun au paquet, puis les références particulières à chaque tâche. Le brief, les règles stables et les décisions partagées ne sont chargés qu'une fois.

Enfin, il enregistre une observation de l'état de départ, avec sa couverture connue, pour ne pas attribuer au runner une modification préexistante.

## Un paquet pédagogique pour la pagination

Voici un ordre de mission pédagogique pour la même fonctionnalité que dans les articles précédents. Les chemins et les valeurs sont illustratifs. La représentation privilégie la lisibilité ; son format de transport peut varier selon les outils.

```yaml
# Exemple pédagogique.
paquet:
  objectif: >-
    Ajouter une pagination serveur à l'annuaire clients et permettre
    de changer de page depuis l'interface.
  non_objectifs:
    - "Ajouter des filtres persistants"
    - "Modifier le routeur ou les primitives d'interface partagées"
  criteres_acceptation:
    - "L'API renvoie les éléments, la page courante et le nombre total de résultats."
    - "L'interface conserve les états loading, empty et error."
    - "Une action de pagination charge la page demandée."

  taches:
    - id: T-01
      resultat: "Étendre la réponse et couvrir les limites de pagination."
      depend_de: []
      ecriture_autorisee: ["backend/customers/**"]
      references_lecture_seule: ["frontend/customers/**"]
      validations: ["Tests ciblés du contrat de pagination"]

    - id: T-02
      resultat: "Consommer le contrat et rendre les contrôles de page."
      depend_de: [T-01]
      ecriture_autorisee: ["frontend/customers/**"]
      references_lecture_seule:
        - "backend/customers/contracts.*"
        - "shared/ui/**"
      validations: ["Tests de comportement de l'annuaire"]

    - id: T-03
      resultat: "Relire la cohérence du contrat et de son intégration."
      depend_de: [T-01, T-02]
      ecriture_autorisee: []
      references_lecture_seule:
        - "backend/customers/**"
        - "frontend/customers/**"
      validations:
        - "Tests d'intégration de la pagination"
        - "Compilation du projet"

  decisions_humaines:
    - "La première page est numérotée 1."
    - "La taille par défaut est de 25 éléments."

  interdits_pour_tout_le_paquet:
    - "shared/routing/**"
    - "tooling/**"
    - "orchestration/**"

  arreter_si:
    - "Le contrat doit devenir incompatible avec un consommateur existant."
    - "Une nouvelle dépendance est nécessaire."
    - "La solution exige une modification du socle partagé."

  git_depart:
    depot_detecte: true
    branche_attendue: "<branche de travail>"
    etat_local_observe: "<statut relevé avant l'exécution>"
    revision_de_base: "non liée de façon immuable dans cet extrait"
    couverture_index: "à confirmer"
```

Dans un système réel, le paquet ou son manifeste associé devrait relier l'objectif et les critères au brief humain, le bloc de tâches à la planification, chaque frontière au contrat du repository, les décisions aux réponses conservées et l'état Git à une observation du runtime.

Les trois tâches sont présentes dans le même paquet, mais elles ne deviennent pas une liste plate. T-02 dépend de T-01 ; T-03 dépend des deux premières. Le runner reçoit cet ordre, exécute le bloc dans une même session et restitue un résultat distinct pour chaque tâche. Si T-01 révèle une incompatibilité ou une décision manquante, le paquet doit s'arrêter avant de présenter T-02 et T-03 comme terminées.

Ce regroupement évite trois chargements successifs du même brief, du même contrat et des mêmes décisions. Il permet aussi à l'agent de conserver la cohérence entre la forme de la réponse backend, son utilisation dans le frontend et les validations d'ensemble. Pour une fonctionnalité plus large, le plan peut naturellement produire plusieurs paquets cohérents plutôt qu'un seul lot démesuré.

Les frontières par tâche restent utiles pour préparer l'ordre de mission et interpréter le compte rendu du runner. En revanche, si le workflow ne prend qu'une capture Git avant et après la session, le fait indépendant porte sur le paquet : il montre quels chemins ont changé dans l'enveloppe autorisée globale. L'attribution d'un fichier précis à T-01 ou T-02 reste une déclaration du runner, sauf si des checkpoints intermédiaires sont ajoutés.

Les références de contexte ne sont pas non plus des chemins modifiables. Elles expliquent où chercher un contrat ou un pattern. La frontière d'écriture reste portée séparément. Cette distinction évite qu'un fichier recommandé à la lecture soit interprété comme une invitation à le modifier.

Enfin, les validations appartiennent à l'ordre de mission, pas au compte rendu final de l'agent. Leur présence signifie « ces contrôles sont attendus ». Elle ne signifie pas qu'ils ont été lancés. Le workflow devra enregistrer séparément les commandes réellement exécutées, leur résultat et les validations absentes.

## La provenance doit être inspectable

On peut rendre la provenance utile sans imposer un schéma complexe. Pour chaque élément décisif, quatre informations suffisent souvent :

| Information | Question de revue |
| --- | --- |
| Source | Quel document, quelle décision ou quelle observation a fourni cette valeur ? |
| Autorité | Cette valeur exprime-t-elle une intention, une règle, un plan ou un fait ? |
| Fraîcheur | À quelle version, décision ou tentative se rapporte-t-elle ? |
| Transformation | Est-elle copiée, résumée, dérivée ou ajoutée par le runtime ? |

Prenons la taille de page. Si elle vient d'une réponse humaine enregistrée après la rédaction du brief, le paquet doit transporter la décision la plus récente et garder le lien avec son origine. La recopier seulement dans le plan crée deux sources susceptibles de diverger.

Prenons maintenant les chemins modifiables. Ils peuvent être dérivés du contrat général du repository, puis resserrés par le plan. Le résultat effectif correspond à l'intersection des autorisations, pas à la liste la plus permissive. Le plan peut réduire l'autorité d'écriture ; il ne devrait pas pouvoir rendre modifiable une zone que le contrat protège.

Cette logique rend également l'ordre de mission auditable avant le run. Une personne peut relire non seulement le résultat attendu, mais aussi les décisions que le compilateur a prises en assemblant le contexte.

## L'état Git de départ est une entrée, pas une preuve finale

L'état Git initial mérite une place explicite dans le paquet, car le contrôle après exécution repose sur une comparaison. Au minimum, le workflow devrait savoir s'il se trouve dans un repository, sur quelle branche il travaille, quelle révision sert de point de départ et si la copie de travail contient déjà des modifications de fichiers suivis — indexées ou non — ainsi que des fichiers non suivis.

Un aperçu initial de l'état local et des chemins déjà modifiés suffit à réduire certaines confusions pendant une exécution locale. Il ne suffit pas à déclarer qu'un changement appartient sans ambiguïté à une tentative ou à une révision.

Plusieurs limites doivent rester visibles :

- un statut local ne lie pas à lui seul le paquet à un commit de base immuable ;
- une copie de travail sale complique l'attribution des changements au runner ;
- l'index et la copie de travail doivent être observés séparément ;
- des fichiers non suivis doivent être inclus explicitement dans le périmètre d'observation ;
- la branche attendue ne prouve pas que l'exécution complète s'y est déroulée ;
- un instantané pris au départ ne remplace pas l'état Git relevé à la fin.

La formulation correcte n'est donc pas « le paquet prouve que le repository était propre ». C'est : « le paquet enregistre tel aperçu de l'état initial, avec telle couverture ». Pour relier la preuve à une PR, il faudra aller plus loin : commits de base et de tête, état de l'index, environnement, puis validations exécutées sur la révision concernée. Nous y reviendrons dans l'article consacré à la preuve.

## Un paquet structuré peut encore contenir trop de contexte

La structure réduit l'amnésie et l'ambiguïté de provenance. Elle ne garantit pas la pertinence de la sélection.

Placer dans le paquet le brief complet, le plan, toutes les tâches, toutes les instructions et une large vue du repository semble prudent. Cela peut pourtant diluer le bloc exécutable, transporter des décisions obsolètes et multiplier les contradictions apparentes.

Avant d'inclure un élément, le workflow peut appliquer quatre questions :

1. Est-il nécessaire pour exécuter l'une des tâches du paquet ou décider de s'arrêter ?
2. Sa source est-elle suffisamment autoritaire et actuelle ?
3. Existe-t-il une représentation plus petite qui conserve le sens utile ?
4. Doit-il être inclus, ou seulement référencé avec une raison de le consulter ?

Le contexte minimal n'est pas le plus court. Retirer une condition d'arrêt serait une mauvaise compression ; recopier une documentation entière quand une référence précise suffit ajoute du bruit. Le paquet doit permettre d'agir et de reconnaître les décisions réservées, pas remplacer le repository dans la fenêtre de contexte.

## Ce que l'ordre de mission change réellement

Un paquet d'exécution bien construit améliore trois choses concrètes.

Il rend d'abord le run reconstructible : intention, décisions, périmètre et validations attendues restent accessibles sans relire la conversation.

Il rend ensuite les écarts qualifiables. Une zone en lecture seule touchée peut être comparée à une frontière explicite ; une validation manquante apparaît comme absente au lieu d'être absorbée dans un résumé optimiste.

Enfin, il sépare mieux les responsabilités. L'agent propose du code et un compte rendu structuré. Le workflow conserve l'état, contrôle le périmètre et lance les validations prévues. L'humain arbitre les décisions qui dépassent l'autorité des tâches du paquet et juge le risque résiduel.

Mais le paquet ne répare pas un brief instable. Il ne rend pas pertinente une sélection de contexte excessive. Il ne transforme pas une politique de chemins en sandbox. Il ne garantit pas que les tests choisis couvrent le comportement. Et il ne prouve pas, à lui seul, que le diff final correspond à une révision prête au merge.

> Un ordre de mission précis ne rend pas l'agent infaillible. Il rend ses instructions, ses limites et ses écarts inspectables.

## Auditer son propre paquet d'exécution

Avant d'automatiser davantage, une équipe peut prendre un paquet réel ou reconstruire celui d'une tâche récente et vérifier les points suivants :

- ☐ L'objectif et les non-objectifs viennent d'une source humaine identifiable.
- ☐ Chaque critère d'acceptation décrit un résultat observable.
- ☐ Les tâches exécutables sont distinguées des tâches visibles pour contexte.
- ☐ Les dépendances empêchent une exécution prématurée.
- ☐ Les chemins modifiables, en lecture seule et interdits ont des sens distincts.
- ☐ Une référence de contexte n'est jamais confondue avec une autorisation d'écriture.
- ☐ Les décisions humaines déjà prises sont conservées avec leur origine.
- ☐ Les conditions d'arrêt désignent la décision et le rôle attendus.
- ☐ Les validations attendues existent indépendamment du rapport de l'agent.
- ☐ L'état Git initial indique clairement ce qui a été observé et ce qui ne l'a pas été.
- ☐ Un conflit entre brief, plan et règles du repository bloque la compilation ou reste explicitement visible.
- ☐ Chaque bloc de contexte peut justifier sa présence dans le paquet courant.

Si l'un de ces éléments n'existe que dans le chat, le paquet est incomplet. S'il existe mais que son origine est impossible à retrouver, le paquet manque de provenance. S'il est présent sans contrôle possible, il reste une instruction et doit être présenté comme tel.

## Conclusion

Ce que l'agent reçoit avant de coder détermine moins sa capacité à générer du code que sa capacité à travailler dans l'autorité qui lui a été accordée.

Le brief apporte l'intention. Le repository apporte les règles. Le plan apporte le découpage et les dépendances. Les décisions humaines ferment les questions déjà arbitrées. Le runtime sélectionne un bloc cohérent de tâches exécutables en séquence, ajoute l'état local et confie au runner un ordre de mission borné.

La qualité de cet assemblage ne se mesure pas à sa longueur. Elle se mesure à la possibilité de répondre, pour chaque information importante : d'où vient-elle, pour quoi fait-elle autorité, est-elle encore actuelle et comment le résultat sera-t-il confronté à cette attente ?

Il reste alors à traiter le moment où l'exécution ne peut pas respecter cet ordre de mission : décision absente, frontière franchie ou validation en échec. C'est le sujet de l'article suivant : [**quand la tâche doit s'arrêter, et comment la reprendre sans perdre son histoire**](../agent-task-stop-and-resume/index.md).

<div class="article-footer-contact">
  <p>Pour discuter de cet article ou me laisser un message public :</p>
  <a class="article-contact-link" href="https://github.com/velkouby/ai-based-development/issues/new?template=contact.yml">Message sur GitHub</a>
</div>
