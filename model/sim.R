library(SimInf)
library(dplyr)

#-----------------------------------------------------------------
#-----------------------------------------------------------------
#-----------------------------------------------------------------
# This is a simple empidemiological model, simulating the spread of a virus 
# across a network. Thereby it creates and simulates four different compartents
# Survailancw (non infected), Infected, Recovered (Immune), Dead across n number of nodes
# The output of the model is a data.frame with the relative number of people within each of the
#compartments during t-time steps. 
# @input: g = recovery rate
# @ input beta_base: 
#...TBD

actlikeme = function(n=1000,g=0.1,h=0.05,dr = 0.005, beds=100,hout=0.05,beta_base=0.7,personalcontacts=5,washing_hands=5,offset=2,days=100,pub_transport=1){ 
  #Fixed parameter
  #------------------------------------
  #g equals recovery time. Set to 0.1 results in an expected value of 10 days to recover, which is 
  #also consistent with the approx. time a covid19 patient being ansteckend
  g = g
  
  #  #proportion of sick patients going into hospital (per day!!)

  h = h
  
  #probability of getting out of hospital
  hout=hout

  #probabbility of dying
  dr=dr
    #number of notes 
  n <- n

  beta_private = 0.7 #baseline - given you have PERSONAL contact with a infected person, 
  # how probable is it that you get infected
  
  beta_public = 0.1 #given that you are in the public, like e.g. in a park 
  
  
  beta_transport = 0.7 #using public transportatioin 
  #pub_transport verzicht auf PT
  
  public_contacts = 20 #amount of people you cross during a normal day in the par, food shooping
  
  node_members =public_contacts + personalcontacts
  
  beta_base = min(1,beta_private * (personalcontacts/(personalcontacts+public_contacts)) + 
                    beta_public *(public_contacts/(personalcontacts+public_contacts)) + (1/(pub_transport)*beta_transport))
  
  #Adjustable parameter by user
  #------------------------------------
  #number of healthy people in the note => how big is you circule of people 
  #you  personal meet during the last 7 days (business or private)
  
  offset = 2 #reducing impact of wahsing hands
  hygiene = min(offset/washing_hands,1)
  beta = min(1,max(0, beta_base - hygiene)) #keep beta between 0 and 1
  

  
  i = round(max(1, node_members/5))#infected within node
  s = node_members - i
  
  #hygiene proxies attempts of user to take care not getting infected while in contact with others
  #1-10 , e.g. amount of times user washes hands per day
  
  
  #beta equals prob that a single agent is getting infected at a specific time point. 
  
  
  transitions <- c("S -> beta*S*I/(S+I+R+D) -> I + Icum", "I -> g*I -> R", "I -> h*I -> H","H -> hout*H ->R","H -> H*dr -> D")
  compartments <- c("S", "I", "Icum", "R", "D", "H","H_out")
  
  #Setting up events for internal and external transfer
  #-------------------------------------
  
  #defining time span in weeks
  tspan <- seq(from = 1, to = days, by = 1)
  
  #Defining events for external transition
  extrans_events <- data.frame(event = "extTrans", time = rep(tspan,
                                                              each = node_members), node = sample(1:n,length(tspan)*node_members,replace=TRUE), dest = sample(1:n,length(tspan)*node_members,replace=TRUE), 
                               n = 1, proportion = 0,
                               select =1, shift = 0)
  
  #injecting a person with the virus
  intra_events <- data.frame(event = "intTrans", time = 3, node = 1, dest = 0, 
                             n = 5, proportion = 0,
                             select =2, shift = 1)
  #combining all events
  events <- rbind(intra_events,extrans_events)
  E <- matrix(c(1, 1, 0, 1, 0, 0,0,1, 0, 0, 0, 0,0,0, 0, 1,0,1,0,0,0), nrow = 7, 
              ncol = 3, dimnames = list(c("S", "I", "Icum", "R","D","H","H_out"),
                                        c("1", "2", "3")))
  N <- matrix(c(1, 0, 0, 0, 0,0,0), nrow = 7, ncol = 1,
              dimnames = list(c("S", "I", "Icum", "R","D","H","H_out"), "1"))
  
  u0 <- data.frame(S = rep(s, n), I = rep(i, n), Icum = rep(0, n),R = rep(0, n),D = rep(0, n),H=rep(0, n),H_out=rep(0, n))
  model <- mparse(transitions = transitions, compartments = compartments, 
                  gdata = c(beta = beta, g = g,dr=dr, h=h, hout=hout), u0 = u0,events = events, E = E, N = N, tspan = tspan)
  


  
  #MC with iter iterations
  # iter = 1
  # res = data.frame(matrix(rep(0,500),nrow=5))
  # 
  # set_num_threads(1)
  # 
  # counter = 1
  # for (i in 1:iter){  
  #   set_num_threads(1)
  #   result <- run(model = model)
  #   #apply function to all columns
  #   res = (res + x)/counter
  #   counter= counter + 1
  # }
  
  set_num_threads(1)
  result <- run(model = model)
  x = trajectory(result, compartments = NULL, node = NULL, as.is = FALSE)
   total <- node_members*n #total numbber in network
  S <- aggregate(x$S, by=list(Category=x$time), FUN=sum)$x/total
  I <- aggregate(x$I, by=list(Category=x$time), FUN=sum)$x/total
  R <- aggregate(x$R, by=list(Category=x$time), FUN=sum)$x/total
  D <- aggregate(x$D, by=list(Category=x$time), FUN=sum)$x/total
  H <- aggregate(x$H, by=list(Category=x$time), FUN=sum)$x/total
  H_out <- aggregate(x$H_out, by=list(Category=x$time), FUN=sum)$x/total

  return(data.frame(S,I,R,D,H,H_out))
  
}

