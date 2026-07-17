---
title: "« Les tests passent » : que prouve le workflow ?"
author: "Vincent El Kouby-Benichou, Baracoda"
company: "Baracoda"
company_url: "https://baracoda.com"
description: >-
  Un code de retour nul n'est pas un verdict sur une feature. Voici comment lire une preuve locale, rendre ses lacunes visibles et préparer son raccord à Git, à la CI et à la décision humaine.
---

# « Les tests passent » : que prouve le workflow ? { .article-title }

Un test vert est un fait utile. Ce n'est pas encore une conclusion sur la feature. Pour savoir ce qu'il prouve, il faut connaître la commande exécutée, son périmètre, la révision concernée, l'environnement utilisé et tout ce qui n'a pas été vérifié.
{ .article-lead }

<p class="article-meta">
  <span>Par <span class="article-author">Vincent El Kouby-Benichou</span>, <a class="article-company-link" href="https://baracoda.com">Baracoda</a></span>
  <a class="article-contact-link" href="https://www.linkedin.com/in/vincentelkoubybenichou/">LinkedIn</a>
</p>

Dans [l'article précédent](../agent-task-stop-and-resume/index.md), une branche simulée autour de la synchronisation URL servait à étudier l'arrêt et la reprise. Pour analyser la preuve sans mélanger ce scénario pédagogique avec l'exécution principale, revenons ici à la pagination initiale décrite dans la [trace de bout en bout](../agentic-feature-end-to-end/index.md), sans l'extension URL. Supposons que ses tâches soient terminées, que les fichiers observés restent dans le périmètre autorisé et que toutes les commandes lancées retournent `0`.

Peut-on écrire « la pagination de l'annuaire clients est validée » ?

Pas encore. On peut affirmer quelque chose de plus précis : dans un contexte local donné, certaines commandes se sont terminées sans erreur sur l'état de travail observé. Cette phrase paraît moins spectaculaire. Elle est surtout beaucoup plus utile à la personne qui doit relire le changement.

Le framework interne qui sert de laboratoire à cette série conserve déjà une partie de ces faits : tentatives, fichiers détectés, contrôles de périmètre, commandes exécutées, codes de retour et synthèse de revue. J'ai vérifié ces capacités dans son implémentation et dans ses tests. Cela ne transforme pas pour autant son artefact local en attestation complète d'une pull request.

> La couleur d'un contrôle résume un résultat. La preuve doit permettre d'en reconstruire la portée.

## « Vert » n'est pas une propriété du code

Dire qu'un test passe omet presque toujours le complément de la phrase : quel test, lancé où, quand, sur quoi et avec quelles hypothèses ?

Un résultat de validation peut être représenté comme un tuple :

```text
résultat = (
  révision ou état de travail,
  environnement,
  commande,
  périmètre couvert,
  instant,
  code de retour,
  sortie utile,
  limites connues
)
```

Retirer l'un de ces éléments ne rend pas nécessairement le résultat faux. Cela réduit ce qu'une autre personne peut en conclure.

Une commande de tests unitaires backend qui retourne `0` établit que les cas présents dans cette suite n'ont pas échoué dans cet environnement. Elle ne démontre pas que l'interface sait consommer le nouveau contrat. Un contrôle de types frontend ne démontre pas que les boutons de pagination se comportent correctement. Un build réussi ne démontre pas que les états `loading`, `empty` et `error` sont lisibles pour un utilisateur.

Même une suite end-to-end ne « prouve pas la feature » au sens absolu. Elle exerce les parcours qu'elle contient, avec les données et l'environnement qu'on lui fournit. Sa valeur peut être élevée ; sa portée reste bornée.

La bonne question n'est donc pas :

> Les tests sont-ils verts ?

Mais :

> Quelles hypothèses le vert permet-il d'écarter, et lesquelles restent ouvertes ?

## Quatre sources de vérité à séparer

Une exécution agentique mélange facilement plusieurs catégories d'informations. Pour la revue, elles doivent rester distinctes.

| Source | Exemple | Ce que l'on peut affirmer | Limite principale |
| --- | --- | --- | --- |
| **Déclaration de l'agent** | « J'ai ajouté la pagination et les tests passent » | L'agent rapporte avoir terminé et décrit son résultat | La déclaration n'est pas un contrôle indépendant |
| **Observation du workflow** | Une commande a retourné `0` entre deux horodatages | Cette commande s'est achevée sans erreur détectée par son code de retour | Le workflow ne sait pas, par défaut, si la commande est suffisante |
| **État rapporté par Git** | Des chemins sont modifiés dans le working tree | Git voit ces différences au moment de l'inspection | Sans base et tête identifiées, l'attribution à une révision reste incomplète |
| **Décision humaine** | « Ces contrôles suffisent pour proposer le merge » | Une personne autorisée accepte le niveau de risque résiduel | La décision dépend de la qualité des faits mis à sa disposition |

Ces quatre sources peuvent être cohérentes sans être interchangeables. L'agent peut rapporter un fichier modifié ; le workflow peut observer une autre liste dans Git. En cas de divergence, la différence elle-même devient un fait à examiner.

De même, un outil peut enregistrer « terminé » parce que toutes les commandes déclarées ont réussi. Ce statut ne dit pas si une validation importante a été oubliée. L'absence d'une commande n'a pas de code de retour rouge.

> Une validation omise ne doit jamais apparaître comme un contrôle réussi. Elle doit apparaître comme une information absente, un choix explicite ou un risque résiduel.

## Ouvrir la preuve locale

Pour le fil rouge de la pagination, imaginons l'artefact public suivant. Il est **simplifié** dans sa structure et **simulé** dans son contenu : ses noms de champs sont pédagogiques et ne reproduisent pas le format du framework interne. Il représente le type d'informations que le workflow sait actuellement conserver, pas un dump natif d'une exécution publiée.

```yaml
tentative:
  identifiant: run-002
  creee_a: 2026-07-17T09:42:18Z

agent:
  resultat_declare: completed
  resume: >-
    Contrat de pagination ajouté côté API et intégré dans l'annuaire.

git_observe:
  avant:
    fichiers_deja_modifies: []
  apres:
    fichiers_modifies:
      - backend/customers/api.py
      - backend/customers/tests/test_pagination.py
      - frontend/customers/customer-list.tsx
      - frontend/customers/customer-list.test.tsx
  modifies_pendant_la_tentative:
    - backend/customers/api.py
    - backend/customers/tests/test_pagination.py
    - frontend/customers/customer-list.tsx
    - frontend/customers/customer-list.test.tsx

frontieres:
  statut: passed
  violations: []

validations:
  - commande: backend-tests customers
    code_de_retour: 0
    debut: 2026-07-17T09:43:02Z
    fin: 2026-07-17T09:43:07Z
  - commande: frontend-tests customer-list
    code_de_retour: 0
    debut: 2026-07-17T09:43:07Z
    fin: 2026-07-17T09:43:13Z

qualite_globale:
  statut: non_executee
```

Les chemins et commandes sont illustratifs. L'extrait permet néanmoins de poser des questions concrètes :

- les fichiers présents avant l'exécution étaient-ils réellement absents, ou seulement mal capturés ?
- la liste finale inclut-elle les modifications indexées, non indexées et non suivies ?
- les commandes ont-elles été choisies depuis le contrat du repository, depuis le plan ou par l'agent ?
- leur sortie complète est-elle conservée ailleurs, ou seulement un extrait ?
- pourquoi le contrôle de qualité global n'a-t-il pas été lancé ?
- quel critère d'acceptation chaque commande exerce-t-elle ?
- sur quel commit cette tentative peut-elle être rejouée ?

Une preuve utile ne fait pas disparaître ces questions. Elle les rend visibles assez tôt pour que la revue puisse les traiter.

## Ce que l'implémentation de référence établit déjà

Dans le framework interne, plusieurs capacités sont **vérifiées** par le code et les tests conservés dans le repository privé :

- une tentative possède un identifiant, un horaire et un lien vers son résultat détaillé ;
- l'état Git est inspecté avant et après le passage du runner ;
- le workflow calcule les fichiers dont le contenu a changé pendant l'exécution afin de ne pas confondre automatiquement tout le working tree avec le travail de l'agent ;
- les chemins observés sont confrontés aux frontières déclarées ;
- les validations configurées ne sont lancées qu'après certains contrôles structurels ;
- chaque commande conserve son code de retour, ses horaires et une portion de ses sorties standard et d'erreur ;
- les tentatives précédentes restent disponibles lorsqu'une correction puis une nouvelle validation sont nécessaires ;
- une synthèse rassemble les fichiers, contrôles, risques et questions restantes pour préparer la revue.

Cette liste défend une affirmation précise : le workflow rend une partie significative de l'exécution locale inspectable.

Elle ne défend pas les affirmations suivantes :

- la capture Git couvre nécessairement tous les états possibles de l'index et du working tree ;
- l'état initial était propre ou accepté explicitement ;
- l'artefact désigne un commit de base et un commit de tête immuables ;
- les versions du système, du runtime, des dépendances et des outils sont toutes enregistrées ;
- les commandes lancées couvrent chaque critère d'acceptation ;
- la CI a répété les contrôles dans un environnement isolé ;
- la sortie conservée est exhaustive ;
- le comportement métier est correct.

Ces lacunes ne disqualifient pas la preuve locale. Elles empêchent simplement de lui attribuer une portée qu'elle n'a pas.

## Une commande ne vaut qu'avec son périmètre

Pour la pagination, les validations peuvent être classées par la question à laquelle elles répondent.

| Contrôle | Question effectivement testée | Ce qu'il ne couvre pas à lui seul |
| --- | --- | --- |
| Tests unitaires backend | Le calcul des limites et des métadonnées respecte-t-il les cas codés ? | Sérialisation réelle, base de données, consommateurs |
| Test d'intégration de l'API | La route renvoie-t-elle le contrat attendu avec les données de test ? | Rendu de l'interface et compatibilité de tous les clients |
| Contrôle de types frontend | L'interface et ses appels respectent-ils les types connus à la compilation ? | Comportement à l'exécution et qualité visuelle |
| Tests du composant | Les actions « précédent » et « suivant » ainsi que les états codés réagissent-ils aux scénarios simulés ? | Navigation complète, réseau réel, accessibilité exhaustive |
| Test end-to-end | Le parcours représenté fonctionne-t-il dans l'environnement de test ? | Cas absents du scénario, charge, production |
| Revue visuelle | Les principaux états paraissent-ils corrects avec les données observées ? | Régression automatisée et comportements non parcourus |

Cette table évite deux dérives opposées. La première consiste à exiger mécaniquement toutes les validations possibles. La seconde consiste à prendre quelques contrôles verts comme une couverture implicite de toute la feature.

Le niveau de validation doit rester proportionné au [mode choisi pour le changement](../agent-coding-modes/index.md). Une fonctionnalité structurée full-stack demande une combinaison de contrôles sur ses surfaces et ses contrats. Elle ne demande pas nécessairement de tester tout le monorepo à chaque tentative locale. En revanche, ce qui n'est pas lancé doit être reporté vers une étape identifiée ou assumé comme risque.

## Relier les critères d'acceptation aux validations

Le brief de la pagination peut contenir quatre critères observables :

| Critère d'acceptation | Validation prévue | Source du résultat | Lacune ou complément humain |
| --- | --- | --- | --- |
| L'API renvoie les éléments, la page courante et le nombre total de résultats | Tests unitaires et test d'intégration API | Workflow local, puis CI | Vérifier la compatibilité avec les consommateurs existants |
| L'utilisateur peut avancer et revenir sans dépasser les limites | Tests de composant et parcours end-to-end | Workflow local ou CI selon l'environnement | Vérifier le comportement clavier et le focus |
| Les états `loading`, `empty` et `error` restent distincts | Tests de composant | Workflow local | Revue visuelle sur des données représentatives |
| L'annuaire charge la première page à l'ouverture | Test de composant ciblé | Workflow local | Confirmer la valeur par défaut dans le brief et le contrat |

Cette matrice ne garantit pas que les tests sont bons. Elle permet de voir qu'un critère ne possède aucune validation, qu'un test prétend couvrir trop de choses ou qu'une décision produit se cache derrière un scénario technique.

Elle révèle aussi la place de la revue manuelle. « Revue manuelle effectuée » n'est ni honteux ni équivalent à `passed`. Une preuve correcte enregistre qui a vérifié quoi, sur quelle version et avec quel résultat. Si cette information n'est pas disponible, le statut doit rester « à faire » ou « inconnu ».

## Les lacunes doivent être des données

Une interface de workflow est tentée de ne montrer que le vert et le rouge. La preuve a besoin d'au moins deux états supplémentaires : **non exécuté** et **inconnu**.

- **Non exécuté** signifie que le contrôle était identifié mais n'a pas été lancé. La raison peut être légitime : environnement indisponible, coût, contrôle reporté à la CI ou validation manuelle prévue.
- **Inconnu** signifie que l'information nécessaire pour conclure n'a pas été capturée. Par exemple, l'état initial de l'index ou la version exacte d'un outil.
- **Tronqué** doit être explicite lorsque seule une portion de la sortie est conservée. Le code de retour reste disponible, mais l'analyse détaillée peut demander l'artefact complet.
- **Instable** indique qu'un contrôle a échoué puis réussi sans cause comprise. Le dernier vert n'efface pas la tentative précédente.

Une exécution peut donc être globalement acceptable tout en contenant des lacunes. Le rôle du manifeste n'est pas de tout transformer en échec. Il est de permettre à la personne qui relit de distinguer une absence prévue d'une absence invisible.

## De la preuve locale à la preuve liée à une révision

La [trace de bout en bout](../agentic-feature-end-to-end/index.md) prépare le passage à Git ; elle ne le remplace pas. Tant que la preuve décrit un working tree mutable, une autre modification peut être ajoutée, retirée ou indexée après sa production.

Pour rattacher les résultats à une proposition de changement, il faut au minimum identifier :

- le commit de base depuis lequel le travail a commencé ;
- le commit de tête qui contient exactement le changement revu ;
- la branche ou la référence de la pull request ;
- l'état du working tree et de l'index au moment pertinent ;
- la source du résultat : poste local, environnement éphémère ou CI ;
- les versions essentielles de l'environnement ;
- les artefacts ou journaux permettant de retrouver les sorties.

Git fournit alors une identité de contenu et un diff stable entre deux révisions. La CI peut exécuter les contrôles sur la tête de la pull request, dans un environnement décrit par le pipeline. Aucun des deux ne décide que la couverture est suffisante. Ils rendent le lien entre une révision et des résultats beaucoup plus solide.

Il reste aussi un problème de temporalité. Si un correctif est ajouté après un passage vert, la validation précédente ne s'applique pas automatiquement au nouveau commit. Une interface de revue devrait rendre ce décalage visible plutôt que conserver un badge vert détaché de sa révision.

## Le manifeste cible

L'exemple suivant est une **cible de conception**. Il ne décrit pas le schéma actuel du framework interne et ne prétend pas être déjà produit intégralement. Son intérêt est de montrer les informations nécessaires pour passer d'un résultat local inspectable à une provenance liée à la révision.

```yaml
preuve:
  execution:
    identifiant: stable-run-id
    tentative: 2
    source: local  # local | ci
    debut: 2026-07-17T09:42:18Z
    fin: 2026-07-17T09:43:19Z

  revision:
    commit_base: abc123
    commit_tete: def456
    branche: feature/customer-pagination
    working_tree_propre_avant: true
    index_propre_avant: true

  changements:
    fichiers_observes: []
    fichiers_autorises: []
    violations: []

  environnement:
    systeme: linux
    runtime: version-identifiee
    dependances: lockfile-identifie

  validations:
    - identifiant: backend-pagination
      commande: commande-stable-du-repository
      statut: passed
      code_de_retour: 0
      revision_validee: def456
      index_au_moment_du_controle: propre
      copie_de_travail_au_moment_du_controle: propre
      criteres: [AC-1]
      sortie: artifact://validation/backend-pagination

  controles_non_executes:
    - identifiant: end-to-end
      raison: reporte_a_la_ci
      risque: integration_navigateur_non_verifiee_localement

  declarations_agent:
    resultat: completed

  revue_humaine:
    statut: pending
    risques_residuels: []
```

Quelques détails comptent :

- `passed`, `non_executed` et `unknown` sont distincts ;
- la déclaration de l'agent reste séparée des observations du workflow ;
- la matrice critères-validations est lisible sans interpréter le nom des commandes ;
- le risque d'une validation reportée ne disparaît pas ;
- la revue humaine reste `pending` même lorsque toutes les commandes sont vertes.

Le manifeste peut être plus court pour une correction locale et plus riche pour une évolution du socle. Sa fonction ne change pas : exposer la provenance, la portée et les lacunes avant la décision.

## Ce que la CI ajoute — et ce qu'elle n'ajoute pas

La CI apporte trois propriétés importantes : une exécution rattachée à une révision, un environnement davantage reproductible et une visibilité partagée par l'équipe. Elle peut aussi imposer une matrice de versions, conserver des artefacts et empêcher le merge lorsque certains contrôles échouent.

Elle ne corrige pas automatiquement un mauvais choix de validations. Un pipeline peut être parfaitement vert tout en ignorant un critère d'acceptation. Il peut aussi réussir sur une commande devenue trop permissive ou sur une suite qui n'exerce pas le nouveau comportement.

Le workflow local et la CI ne sont donc pas concurrents :

```text
preuve locale
  -> prépare la relecture et détecte tôt les problèmes
  -> se rattache à un commit
  -> la CI répète ou complète les contrôles sur cette révision
  -> la PR rassemble diff, résultats, décisions et risques
  -> un humain accepte, demande une reprise ou refuse
```

Le meilleur passage de relais n'est pas « tout était vert chez moi ». C'est un manifeste de preuve qui indique quels contrôles peuvent être rejoués, lesquels sont réservés à la CI et quelles vérifications restent humaines.

## Une checklist de revue qui résiste au vert

Avant d'accepter la phrase « les tests passent », la personne qui relit peut poser dix questions :

1. La révision exacte ou l'état de travail contrôlé est-il identifiable ?
2. L'état initial était-il propre, ou ses modifications préexistantes sont-elles connues ?
3. Les commandes réellement exécutées sont-elles visibles ?
4. Leurs codes de retour, horaires et sorties utiles sont-ils disponibles ?
5. Leur périmètre correspond-il aux surfaces modifiées ?
6. Chaque critère d'acceptation possède-t-il un contrôle ou une décision explicite ?
7. Les validations non exécutées et inconnues sont-elles visibles ?
8. Une tentative rouge, une reprise ou un résultat instable a-t-il été conservé ?
9. La CI a-t-elle contrôlé le commit actuellement proposé ?
10. Qui possède l'autorité pour accepter le risque résiduel ?

Si les réponses sont accessibles sans rouvrir la conversation avec l'agent, le workflow a déjà gagné en valeur. Si elles sont reliées à la révision et aux artefacts de CI, la pull request devient réellement plus facile à contester et à accepter.

## Conclusion

« Les tests passent » n'est ni inutile ni suffisant. C'est le début d'une démonstration : une ou plusieurs commandes se sont terminées sans erreur dans un contexte donné.

La preuve locale rend ce contexte inspectable. Git rattache le changement à des révisions. La CI rejoue ou complète les contrôles sur une tête identifiée. La matrice critères-validations montre la couverture attendue. La revue humaine décide enfin si les faits et les lacunes sont compatibles avec le risque.

Le framework interne couvre déjà une part substantielle de la première étape. Le manifeste cible montre le chemin restant sans faire passer une intention de conception pour une capacité acquise.

Une question demeure alors : combien de décisions peut-on raisonnablement stabiliser dans un brief avant que ses zones floues ne deviennent plus coûteuses que la rédaction d'une spécification ? Ce sera le sujet du prochain article : **Quand le brief ne suffit plus : introduire une spec sans bureaucratie**.

<div class="article-footer-contact">
  <p>Pour discuter de cet article ou me laisser un message public :</p>
  <a class="article-contact-link" href="https://github.com/velkouby/ai-based-development/issues/new?template=contact.yml">Message sur GitHub</a>
</div>
