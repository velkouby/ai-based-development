---
title: "Quand la tâche doit s'arrêter : décisions, frontières et reprise"
author: "Vincent El Kouby-Benichou, Baracoda"
company: "Baracoda"
company_url: "https://baracoda.com"
description: >-
  Une décision manquante, une sortie de périmètre et un test en échec ne demandent pas la même réponse. Voici comment arrêter une tâche agentique proprement, conserver les faits utiles et reprendre sans effacer l'histoire.
---

# Quand la tâche doit s'arrêter : décisions, frontières et reprise { .article-title }

Une décision manquante, une sortie de périmètre et un test en échec ne demandent pas la même réponse. Un workflow agentique fiable doit savoir pourquoi il s'arrête, qui peut débloquer la situation et à partir de quels faits le travail pourra reprendre.
{ .article-lead }

<p class="article-meta">
  <span>Par <span class="article-author">Vincent El Kouby-Benichou</span>, <a class="article-company-link" href="https://baracoda.com">Baracoda</a></span>
  <a class="article-contact-link" href="https://www.linkedin.com/in/vincentelkoubybenichou/">LinkedIn</a>
</p>

Dans [l'article précédent](../agent-execution-package/index.md), le brief, le plan, les règles du repository et les décisions déjà prises devenaient un ordre de mission borné. Cet ordre indiquait à l'agent où écrire, quoi consulter, comment valider et dans quels cas ne pas continuer.

Les conditions d'arrêt ne sont pas une annexe prudente du paquet d'exécution. Elles en sont une partie opérationnelle. Sans elles, l'agent est incité à transformer toute incertitude en choix d'implémentation et tout obstacle en élargissement silencieux du périmètre.

Mais « la tâche est bloquée » reste une information insuffisante. Une question produit non tranchée avant le code, une modification observée dans une zone protégée et un test unitaire en échec n'ont ni le même responsable, ni la même réparation, ni le même point de reprise.

> Un arrêt utile ne dit pas seulement que le travail n'est pas terminé. Il établit ce qui s'est passé, ce qui manque, qui doit décider et ce qui devra être revérifié.

Les mécanismes présentés ici — état persistant, frontières d'écriture, historique des tentatives, décisions humaines et reprises contrôlées — forment un protocole qu'un framework appliquant ces principes peut matérialiser. Les artefacts qui suivent montrent comment rendre ce protocole actionnable.

<figure class="article-diagram">
  <img src="../../../articles/agent-task-stop-and-resume/task-stop-resume-paths.png" alt="Trois branches distinguent la décision manquante, la sortie de périmètre et l'échec réparable, avec pour chacune l'autorité, l'action et le point de reprise nécessaires avant une nouvelle tentative compilée." loading="lazy" />
  <figcaption>La cause de l'arrêt détermine l'autorité nécessaire et le point de reprise.</figcaption>
</figure>

## Trois arrêts, trois autorités différentes

Une taxonomie minimale suffit déjà à éviter de nombreuses mauvaises reprises.

| Situation | Fait déclencheur | Qui peut agir ? | Reprise légitime |
| --- | --- | --- | --- |
| **Décision manquante** | Une question change le résultat attendu ou engage une autorité absente | Responsable produit, architecture, sécurité ou propriétaire du domaine | Enregistrer la décision, mettre à jour l'entrée concernée, puis recompiler le travail |
| **Sortie de périmètre** | Les fichiers observés touchent une zone non autorisée, en lecture seule ou interdite | Pilote de la tâche et, si nécessaire, propriétaire du socle | Isoler ou retirer la modification, redécouper ou reclasser, puis repartir d'un périmètre valide |
| **Échec réparable** | Une validation ou une étape mécanique échoue sans ouvrir de nouvelle décision | Agent ou développeur, dans une politique de réparation bornée | Corriger la cause, relancer les contrôles affectés et conserver une nouvelle tentative |

La différence essentielle porte sur l'autorité. Un agent peut corriger une erreur de formatage si la commande et la solution sont déterministes. Il ne peut pas décider seul qu'une incompatibilité d'API est acceptable, qu'une primitive partagée peut changer ou qu'une permission doit être élargie.

Il faut aussi distinguer **arrêt** et **échec**. Attendre une décision produit est un arrêt normal du workflow, pas une panne. Détecter une sortie de périmètre signifie que le garde-fou a fonctionné, même si la tentative ne peut pas être acceptée. À l'inverse, répéter mécaniquement une validation qui échoue sans diagnostic n'est pas une reprise : c'est une boucle.

## Une décision manquante doit bloquer avant le code

Le meilleur moment pour arrêter une tâche est souvent avant que le runner agent ne soit lancé.

Supposons que le brief demande de paginer l'annuaire clients, mais ne précise pas le comportement lorsqu'une page supérieure au nouveau maximum est demandée. L'API doit-elle renvoyer une page vide, ramener la requête à la dernière page valide ou retourner une erreur explicite ? Ce choix influence l'expérience utilisateur, le contrat de l'interface et les tests.

Le planificateur peut proposer des options et signaler leurs conséquences. Il ne doit pas faire passer l'une d'elles pour une simple convention technique. Le workflow devrait alors conserver une intervention contenant au minimum :

- le problème formulé sans jargon inutile ;
- la question précise à trancher ;
- les options connues et leurs effets ;
- le rôle attendu pour décider ;
- les tâches et critères concernés ;
- la réponse, sa source et sa justification éventuelle.

Tant que cette intervention reste ouverte, aucune tâche dépendante ne devrait être exécutable. Une fois la réponse donnée, elle ne doit pas seulement être injectée dans une nouvelle conversation. Elle devient une décision persistante, reliée à l'intervention qui l'a provoquée, puis transmise dans le prochain paquet d'exécution. Si elle modifie le brief, le plan ou le périmètre, l'artefact concerné doit être mis à jour et le travail recompilé avant la reprise.

Cette séquence évite deux dérives. La première consiste à laisser l'agent coder une hypothèse, puis à présenter le diff comme une manière de « demander confirmation ». La seconde consiste à recevoir une réponse humaine sans mettre à jour l'artefact qui faisait autorité. Dans ce cas, le prochain agent peut reprendre l'ancienne ambiguïté.

> Répondre à une question ne suffit pas. La réponse doit modifier durablement la source qui gouverne l'exécution suivante.

Si la question révèle que le brief entier est instable, il ne faut pas reprendre la tâche. Il faut revenir à la définition du besoin. Si elle ne concerne qu'une décision locale déjà prévue par le plan, une mise à jour ciblée peut suffire. Le point de reprise dépend donc de l'endroit où l'incertitude est née.

## Une sortie de périmètre est un fait observé après l'écriture

Le deuxième cas est plus inconfortable : l'agent a déjà écrit, puis le workflow constate qu'un fichier modifié ne respecte pas l'ordre de mission.

Le contrôle utile compare deux sources : le périmètre déclaré pour les tâches exécutées et les chemins réellement observés dans la copie de travail. La liste de fichiers rapportée par l'agent peut aider au diagnostic, mais elle ne doit pas être la seule source. Un agent peut oublier un fichier, mal interpréter un renommage ou produire un résumé incomplet.

Pour l'annuaire clients, un contrat conceptuel pourrait autoriser l'écriture dans les zones produit du frontend et du backend, autoriser la lecture du routage commun et interdire sa modification :

```text
écriture autorisée
  frontend/customers/**
  backend/customers/**

lecture seule
  shared/routing/**

arrêter si
  la synchronisation avec l'URL exige de modifier le routage partagé
```

Ces chemins illustrent la répartition des responsabilités entre les zones produit et le routage partagé.

Si le diff observé contient un fichier sous `shared/routing/`, le résultat n'est pas « presque conforme ». La tentative a franchi une frontière. Les validations fonctionnelles ne doivent pas transformer ce franchissement en autorisation rétroactive : un test vert ne donne pas à la tâche produit le droit de modifier le socle.

Le workflow doit alors conserver le constat avant toute réparation : chemins concernés, règle violée, phase de détection, état connu au départ et validations déjà exécutées ou non. Cette chronologie compte. Elle permet de distinguer une modification produite pendant la tentative d'un changement qui existait avant son lancement.

Si la copie de travail était déjà modifiée, retirer automatiquement le fichier fautif peut détruire le travail de quelqu'un d'autre. La bonne réaction est alors de suspendre la réparation et de demander une attribution humaine. La restauration automatique n'est raisonnable que lorsque le système sait précisément quel état de référence il rétablit et quelles modifications appartiennent à la tentative.

## Variante pédagogique : la pagination et l'URL

Le scénario suivant sert d'exemple pédagogique pour suivre un arrêt de périmètre, la décision qui en découle et les conditions de reprise.

Dans cette variante, l'équipe étend la pagination avec une exigence supplémentaire : la page courante doit apparaître dans l'URL afin qu'un lien puisse être partagé. Comme cette synchronisation était un non-objectif du brief initial, la demande est d'abord requalifiée, le brief est révisé et un nouveau paquet d'exécution est compilé. Le routage partagé y reste en lecture seule, avec une condition d'arrêt explicite. Pendant l'implémentation, l'agent conclut néanmoins que l'interface publique du routeur est insuffisante et modifie une primitive partagée.

Le contrôle post-exécution observe alors deux catégories de changements : les fichiers produit attendus et un fichier du routage commun. Il classe la tentative comme sortie de périmètre et arrête la chaîne avant de considérer la tâche terminée.

Voici un dossier d'arrêt compact que l'on pourrait conserver :

```markdown
# Dossier d'arrêt — exemple pédagogique

Demande : synchroniser la page de l'annuaire avec l'URL
Phase : contrôle post-écriture
Résultat : arrêt sur frontière d'écriture

Éléments consignés dans cet exemple :
- des fichiers de la fonctionnalité ont été modifiés dans le périmètre autorisé ;
- un fichier du routage partagé a aussi été modifié ;
- cette zone était déclarée en lecture seule ;
- les validations prévues n'ont pas été lancées après l'échec du contrôle de périmètre.

Options soumises à décision :
1. retirer la synchronisation de l'URL et réviser les critères ;
2. trouver une adaptation locale utilisant l'interface publique existante ;
3. ouvrir une évolution séparée du socle, puis reprendre la fonctionnalité.

Décision humaine :
- maintenir l'exigence de partage par URL ;
- annuler la modification non autorisée ;
- traiter l'extension du routeur dans une unité de travail distincte ;
- reprendre la pagination après intégration de cette extension.
```

Ce dossier reste volontairement compact : il ne décrit pas toute la mécanique de reprise. Il conserve ce dont une équipe a besoin pour comprendre l'arrêt et autoriser la suite.

La décision choisie ne consiste pas à ajouter `shared/routing/**` aux chemins autorisés de la tâche existante. Ce serait maquiller la sortie de périmètre en élargissant le contrat après coup. Le changement partagé devient une **évolution du socle** avec sa propre intention, son analyse d'impact, ses consommateurs, ses validations et sa revue.

La fonctionnalité de pagination reste arrêtée tant que cette dépendance n'est pas disponible. Après intégration de l'extension partagée, son plan est réévalué : nouvelle révision de départ, nouvelle interface publique à réutiliser, périmètre produit inchangé et validations mises à jour. La tâche peut alors reprendre sans effacer la première tentative.

## Annuler, réessayer et redécouper ne sont pas synonymes

Une fois l'arrêt qualifié, le verbe de reprise doit être précis.

**Annuler une modification interdite** signifie revenir à un état de référence connu pour les seuls chemins concernés, puis relancer le contrôle de périmètre. Cette action ne valide pas le reste du diff. Elle retire un fait incompatible avec le contrat.

**Réessayer une tâche** signifie conserver le même objectif et la même autorité, mais produire une nouvelle tentative après une correction bornée. L'historique précédent reste visible : cause, actions prises, fichiers touchés et résultats de validation.

**Replanifier** signifie que l'entrée a changé. Une décision humaine, un nouveau contrat ou une dépendance intégrée modifie l'ordre de mission. Relancer exactement le même paquet serait incohérent ; il faut en compiler un nouveau.

**Redécouper ou reclasser** signifie que le changement découvert n'appartient plus au dispositif initial. Une évolution du socle doit rester séparée de la tâche produit. Une migration ou une décision de sécurité peut, selon sa portée, imposer une unité distincte ou une reclassification avec l'autorité correspondante.

Cette distinction protège la traçabilité. Si toutes les actions sont appelées « reprise », une équipe ne sait plus si l'agent a corrigé une faute, reçu une nouvelle décision ou obtenu un périmètre plus large.

## L'échec réparable : une boucle bornée, pas une carte blanche

Le troisième cas concerne un échec mécanique ou de validation. Par exemple, un test ciblé révèle que le bouton « page suivante » reste actif sur la dernière page. L'objectif, le contrat d'API et le périmètre ne changent pas. La cause est localisée dans une zone autorisée et la correction peut être vérifiée par le même test.

Une tentative de réparation est raisonnable si quatre conditions sont réunies :

1. l'échec est classé et son diagnostic est suffisamment précis ;
2. la correction n'exige ni nouvelle dépendance, ni décision produit, ni élargissement de chemins ;
3. les commandes à relancer sont connues ;
4. le nombre de tentatives est limité.

Après la correction, il ne suffit pas de relancer la seule commande rouge si d'autres contrôles peuvent avoir été affectés. Le workflow doit au minimum refaire le contrôle des frontières, puis les validations liées aux fichiers corrigés. Si la réparation a modifié le contrat backend, les tests de l'interface qui le consomme redeviennent pertinents même s'ils étaient verts avant.

Chaque tentative devrait conserver une mémoire compacte : raison initiale, diagnostic, actions, chemins touchés, validations relancées, résultat et prochaine action. Si la réparation cesse de progresser ou atteint la limite autorisée, la boucle s'arrête. Le système transmet alors les tentatives à un humain au lieu de continuer à consommer du temps tout en augmentant le diff.

Certains échecs ressemblent à tort à des réparations mécaniques. Un test échoue parce que le comportement attendu n'est pas défini : c'est une décision manquante. Une compilation échoue parce qu'il faudrait ajouter une dépendance : c'est une autorisation à obtenir. Une validation révèle une rupture de compatibilité : c'est potentiellement une décision d'architecture ou de migration. La sortie d'un outil ne détermine donc pas à elle seule la catégorie ; le changement nécessaire pour la résoudre compte davantage.

## Reprendre signifie reconstruire l'autorité de la tâche

Une reprise fiable ne consiste pas à envoyer « continue là où tu t'es arrêté » dans le même chat. Elle reconstruit explicitement l'état autorisé.

Avant de relancer le runner agent, le workflow devrait vérifier :

- que les interventions bloquantes sont résolues ;
- que la réponse humaine est enregistrée et reliée aux tâches concernées ;
- que les dépendances précédentes sont terminées ;
- que les modifications interdites ont été isolées ou retirées ;
- que le brief, le plan et les critères sont encore cohérents ;
- que le nouveau paquet contient la décision et le bon état Git de départ ;
- que les validations à refaire sont explicites.

La nouvelle tentative reçoit alors le contexte utile de la précédente, pas toute sa conversation. Elle sait ce qui a échoué, ce qui a été décidé, ce qui ne doit pas être reproduit et quelles preuves sont attendues. Les tâches déjà terminées peuvent rester terminées si leurs résultats sont encore valables ; la tâche arrêtée redevient exécutable seulement lorsque ses préconditions sont satisfaites.

Dans la variante pédagogique de l'URL, la reprise inclut la décision d'architecture, la nouvelle interface publique du routeur et l'interdiction maintenue de modifier le socle. Elle ne donne pas à l'agent un accès plus large. Au contraire, elle rend possible une implémentation produit plus étroite.

> Une bonne reprise ne supprime pas l'arrêt précédent. Elle en fait une entrée vérifiable de la tentative suivante.

## Ce que le contrôle de frontière ne garantit pas

Le contrôle décrit ici intervient après l'écriture dans le flux normal. Il peut détecter qu'un chemin observé sort du périmètre et empêcher l'acceptation du résultat. Un mécanisme séparé et explicitement autorisé peut ensuite restaurer un état connu ou demander une décision humaine. **Ce n'est pas un sandbox.**

Il ne prouve pas que le processus était techniquement incapable d'écrire ailleurs, d'accéder au réseau, de lire un secret ou d'exécuter une commande dangereuse. Ces garanties relèvent d'autres mécanismes : permissions du système, isolation du processus, gestion des secrets, politique réseau et environnement d'exécution.

Il ne détecte pas non plus une erreur sémantique dans un chemin autorisé. L'agent peut respecter parfaitement les dossiers et introduire un défaut métier. Enfin, la portée du contrôle Git doit être annoncée : fichiers suivis, non suivis, index, changements préexistants et renommages ne sont pas toujours observés de la même manière.

Le bénéfice du garde-fou est plus précis : comparer une politique d'écriture à un ensemble de modifications observées, puis rendre l'écart visible avant la revue. C'est déjà utile, à condition de ne pas lui attribuer une garantie de sécurité qu'il ne fournit pas.

## Le dossier d'arrêt minimal

Une équipe peut appliquer cette méthode sans orchestrateur complet. Pour toute tâche interrompue, conserver une fiche courte :

```markdown
# Arrêt et reprise

Catégorie : décision manquante / sortie de périmètre / échec réparable
Phase de détection :
Tentative concernée :

Faits observés :
-

Ce qui reste déclaré par l'agent :
-

Impact sur le résultat attendu :
Autorité nécessaire :

Options :
1.
2.

Décision et source :
Actions avant reprise :
Artefacts à mettre à jour :
Contrôles à relancer :
Risque résiduel :
```

La fiche force trois séparations utiles : faits et déclarations, options et décision, correction et validation. Elle empêche surtout qu'une reprise dépende de la mémoire de la personne qui assistait à l'exécution.

## Conclusion

Savoir s'arrêter est une capacité positive d'un workflow agentique. Une décision manquante doit remonter à la bonne autorité. Une sortie de périmètre doit rester visible, même si la modification est ensuite retirée. Un échec réparable peut déclencher une nouvelle tentative, mais seulement dans une boucle bornée et suivie de contrôles renouvelés.

Dans les trois cas, la reprise ne doit ni effacer l'histoire, ni élargir silencieusement le contrat. Elle relie un constat, une décision ou une réparation à un nouvel ordre de mission.

Il reste cependant une question : que vaut la preuve produite par ce workflow ? Un contrôle de chemins réussi et des commandes au vert ne disent pas encore à quelle révision ils se rapportent ni ce qu'ils ont réellement couvert. Pour l'étudier sans confondre le scénario principal avec la variante consacrée à l'URL, l'article suivant revient à l'exécution initiale de la pagination : [**« Les tests passent » : que prouve le workflow ?**](../local-proof-agent-workflow/index.md).

<div class="article-footer-contact">
  <p>Pour discuter de cet article ou me laisser un message public :</p>
  <a class="article-contact-link" href="https://github.com/velkouby/ai-based-development/issues/new?template=contact.yml">Message sur GitHub</a>
</div>
