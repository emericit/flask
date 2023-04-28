#!/bin/bash

### Test de l'API ###

## STATUS   
# test status ==> 200
curl -X GET -i localhost:5000/status 

## WELCOME
# test welcome ==> 200
curl -X GET -i localhost:5000/welcome/Emeric
# test welcome avec / dans le nom ==> 400
curl -X GET -i localhost:5000/welcome/Emeric/Henry

## PERMISSIONS
# test avec header au mauvais format ==> 400
curl -X POST -i -H "Authentication: `python3 cypher.py emeric=mot_de_passe`" localhost:5000/permissions 
# test avec header au bon format mais utilisateur inexistant ==> 403
curl -X POST -i -H "Authentication: `python3 cypher.py emeric:mot_de_passe`" localhost:5000/permissions 
# test avec header au bon format et utilisateur existant, mais mauvais mot de passe ==> 403
curl -X POST -i -H "Authentication: `python3 cypher.py Steven:mot_de_passe`" localhost:5000/permissions 
# test avec header au bon format, utilisateur existant, et bon mot de passe ==> 200
curl -X POST -i -H "Authentication: `python3 cypher.py Steven:5998`" localhost:5000/permissions 

## SENTIMENT V1
# test avec header correct, mais body sans sentence ==> 400
curl -X POST -i -H 'Content-Type: application/json' -H "Authentication: `python3 cypher.py Steven:5998`" -d '{}' localhost:5000/v1/sentiment 
# test avec header correct, et body avec sentence ==> 200
curl -X POST -i -H 'Content-Type: application/json' -H "Authentication: `python3 cypher.py Steven:5998`" -d '{"sentence":"test sentence"}' localhost:5000/v1/sentiment 
# test avec tout correct, mais utilisateur sans les droits ==> 403
curl -X POST -i -H 'Content-Type: application/json' -H "Authentication: `python3 cypher.py Anika:8944`" -d '{"sentence":"test sentence"}' localhost:5000/v1/sentiment 
# test avec tout correct, utilisateur avec les droits mais mauvais mot de passe ==> 403
curl -X POST -i -H 'Content-Type: application/json' -H "Authentication: `python3 cypher.py Steven:8944`" -d '{"sentence":"test sentence"}' localhost:5000/v1/sentiment 

## SENTIMENT V2
# test avec phrase positive ==> 200
curl -X POST -i -H 'Content-Type: application/json' -H "Authentication: `python3 cypher.py Steven:5998`" -d '{"sentence":"what a beautiful day"}' localhost:5000/v2/sentiment 
# test avec phrase neutre ==> 200
curl -X POST -i -H 'Content-Type: application/json' -H "Authentication: `python3 cypher.py Steven:5998`" -d '{"sentence":"the sun is a star"}' localhost:5000/v2/sentiment 
# test avec phrase négative ==> 200
curl -X POST -i -H 'Content-Type: application/json' -H "Authentication: `python3 cypher.py Steven:5998`" -d '{"sentence":"i am depressed"}' localhost:5000/v2/sentiment 
