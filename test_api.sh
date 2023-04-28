#!/bin/bash

### Test de l'API ###

## STATUS   
# test status ==> 200
echo curl -X GET -i localhost:5000/status
curl -X GET -i localhost:5000/status 
echo ------------------------------------------------------------------------------------------------------------------
## WELCOME
# test welcome ==> 200
echo curl -X GET -i localhost:5000/welcome/Emeric
curl -X GET -i localhost:5000/welcome/Emeric
echo ------------------------------------------------------------------------------------------------------------------
# test welcome avec / dans le nom ==> 400
echo curl -X GET -i localhost:5000/welcome/Emeric/Henry
curl -X GET -i localhost:5000/welcome/Emeric/Henry
echo ------------------------------------------------------------------------------------------------------------------

## PERMISSIONS
# test avec header au mauvais format ==> 400
echo curl -X POST -i -H 'Authentication: `python3 cypher.py emeric:mot_de_passe`' localhost:5000/permissions
curl -X POST -i -H "Authentication: `python3 cypher.py emeric=mot_de_passe`" localhost:5000/permissions 
echo ------------------------------------------------------------------------------------------------------------------
# test avec header au bon format mais utilisateur inexistant ==> 403
echo curl -X POST -i -H 'Authentication: `python3 cypher.py emeric:mot_de_passe`' localhost:5000/permissions
curl -X POST -i -H "Authentication: `python3 cypher.py emeric:mot_de_passe`" localhost:5000/permissions 
echo ------------------------------------------------------------------------------------------------------------------
# test avec header au bon format et utilisateur existant, mais mauvais mot de passe ==> 403
echo curl -X POST -i -H 'Authentication: `python3 cypher.py Steven:mot_de_passe`' localhost:5000/permissions
curl -X POST -i -H "Authentication: `python3 cypher.py Steven:mot_de_passe`" localhost:5000/permissions 
echo ------------------------------------------------------------------------------------------------------------------
# test avec header au bon format, utilisateur existant, et bon mot de passe ==> 200
echo curl -X POST -i -H 'Authentication: `python3 cypher.py Steven:5998`' localhost:5000/permissions
curl -X POST -i -H "Authentication: `python3 cypher.py Steven:5998`" localhost:5000/permissions 
echo ------------------------------------------------------------------------------------------------------------------

## SENTIMENT V1
# test avec header correct, mais body sans sentence ==> 400
echo curl -X POST -i -H 'Content-Type: application/json' -H 'Authentication: `python3 cypher.py Steven:5998`' -d '{}' localhost:5000/v1/sentiment
curl -X POST -i -H 'Content-Type: application/json' -H "Authentication: `python3 cypher.py Steven:5998`" -d '{}' localhost:5000/v1/sentiment 
echo ------------------------------------------------------------------------------------------------------------------
# test avec header correct, et body avec sentence ==> 200
echo curl -X POST -i -H 'Content-Type: application/json' -H 'Authentication: `python3 cypher.py Steven:5998`' -d '{"sentence":"test sentence"}' localhost:5000/v1/sentiment
curl -X POST -i -H 'Content-Type: application/json' -H "Authentication: `python3 cypher.py Steven:5998`" -d '{"sentence":"test sentence"}' localhost:5000/v1/sentiment 
echo ------------------------------------------------------------------------------------------------------------------
# test avec tout correct, mais utilisateur sans les droits ==> 403
echo curl -X POST -i -H 'Content-Type: application/json' -H 'Authentication: `python3 cypher.py Anika:8944`' -d '{"sentence":"test sentence"}' localhost:5000/v1/sentiment
curl -X POST -i -H 'Content-Type: application/json' -H "Authentication: `python3 cypher.py Anika:8944`" -d '{"sentence":"test sentence"}' localhost:5000/v1/sentiment
echo ------------------------------------------------------------------------------------------------------------------
# test avec tout correct, utilisateur avec les droits mais mauvais mot de passe ==> 403
echo curl -X POST -i -H 'Content-Type: application/json' -H 'Authentication: `python3 cypher.py Steven:8944`' -d '{"sentence":"test sentence"}' localhost:5000/v1/sentiment
curl -X POST -i -H 'Content-Type: application/json' -H "Authentication: `python3 cypher.py Steven:8944`" -d '{"sentence":"test sentence"}' localhost:5000/v1/sentiment 
echo ------------------------------------------------------------------------------------------------------------------

## SENTIMENT V2
# test avec phrase positive ==> 200
echo curl -X POST -i -H 'Content-Type: application/json' -H 'Authentication: `python3 cypher.py Steven:5998`' -d '{"sentence":"what a beautiful day"}' localhost:5000/v2/sentiment
curl -X POST -i -H 'Content-Type: application/json' -H "Authentication: `python3 cypher.py Steven:5998`" -d '{"sentence":"what a beautiful day"}' localhost:5000/v2/sentiment 
echo ------------------------------------------------------------------------------------------------------------------
# test avec phrase neutre ==> 200
echo curl -X POST -i -H 'Content-Type: application/json' -H 'Authentication: `python3 cypher.py Steven:5998`' -d '{"sentence":"the sun is a star"}' localhost:5000/v2/sentiment
curl -X POST -i -H 'Content-Type: application/json' -H "Authentication: `python3 cypher.py Steven:5998`" -d '{"sentence":"the sun is a star"}' localhost:5000/v2/sentiment 
echo ------------------------------------------------------------------------------------------------------------------
# test avec phrase négative ==> 200
echo curl -X POST -i -H 'Content-Type: application/json' -H 'Authentication: `python3 cypher.py Steven:5998`' -d '{"sentence":"i am depressed"}' localhost:5000/v2/sentiment
curl -X POST -i -H 'Content-Type: application/json' -H "Authentication: `python3 cypher.py Steven:5998`" -d '{"sentence":"i am depressed"}' localhost:5000/v2/sentiment 
echo ------------------------------------------------------------------------------------------------------------------
