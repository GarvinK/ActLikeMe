# Act-Like-Me

## WHAT IS IT?

A multi-agent based simulation to show how social distancing affects the spread of a virus. Among other things it evaluates the evolution of infection rates, immunity and death rates. Thereby, takes into account how a potentially overwhelmed healthcare system cannot treat every patient optimally.



## HOW IT WORKS

The agents are arranged in a network with five connections to the closest neighbours. Initially the agents are distributed randomly, given the connection logic, this will result in a local clustering (which seems at least somewhat more realistic than to have all agents distributed randomly). The agents interact according to an adjustable probability,  which simulates how well someone acts according to the social distancing guidelines. The model still contains many random parts which are sampled from a uniform, which is NOT how reality works. The model still illustrates how social distancing can help mitigate the effects of a virus. 

![](images/actlikeme.gif)

## HOW TO USE IT

Set the probability-of-contact variable. 

## THINGS TO NOTE

The underlying parameters have been chosen according to current COVID-19 statistics. However, this is an illustrative model only! The model aims to show how social distancing can help keeping the number of people infected (and therefore presumably the number of occupied hospital beds) within the capacity of the healthcare system. 

## COMING UP

- Improve accuracy of input-parameters. 
- Parameter estimates using sampling based methods (MC). 
- include additional behavioural based parameters
- improved performance / multi-core-processing

## RESSOURCES

Current input-parameters are based on the following sources:

- https://smw.ch/article/doi/smw.2020.20203
- http://www.euro.who.int/__data/assets/pdf_file/0010/293689/Switzerland-HiT.pdf
- https://www.epicentro.iss.it/coronavirus/bollettino/Report-COVID-2019_17_marzo-v2.pdf