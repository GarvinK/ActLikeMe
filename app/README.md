# Act-Like-You

## WHAT IS IT?

Simulation to see how social distancing affects the spread of the famous curve.
Contains a fatality rate caluclator that takes into account how a overwhelmed healthcare system cannot treat every patient optimally and therefore increases the fatality rate.

## HOW IT WORKS

The agents are arranged in a network with five connections to the closest neighbours. Initially the agents are distributed randomly, given the connection logic, this will result in a local clustering (which seems at least somewhat more realistic than to have all agents distributed randomly). The agents then interact with a probability dependent on the input of "probability-of-contact" which simulates how well someone adhers to the social distancing guidelines (lower is better adherence). The model still contains many random parts which are sampled from a uniform, which is NOT how reality works. The model still illustrates how social distancing can help mititgate the effects of a virus. 

## HOW TO USE IT

Set the probability-of-contact variable. The best values are:
* 6 for a (unrealistic) total lockdown where EVERYONE only ever leaves the house for groceries
* 12 for a optimal social distancing scenario
* 24 for a scenario where many people still travel around in their free time
* 40 for a buiness as usual scenario

## THINGS TO NOTICE

There are some heavy assumptions, DO NOT TAKE THEM FOR GRANTED. This is an illustrative model WITHOUT ANY CLAIM TO CORRESPOND TO REALITY. The model aims merely to show how social distancing can help keeping the number of people infected (and therefore presumably the number of occupied hospital beds) within the capacity of the healthcare system. 

## THINGS TO TRY / EXTENDING THE MODEL

Get some more accurate realistic parameters. MonteCarlo the model many times to get mean or median estimates of the curves instead of curves apt for visualization. 

## RELATED MODELS

Interesting would be an extension such as the basic models from the library. Specifically:
* Virus in a Network
* HIV (which takes into account "closed-off" spaces for some time
