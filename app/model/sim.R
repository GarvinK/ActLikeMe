library(SimInf)
library(dplyr)

#-----------------------------------------------------------------
#-----------------------------------------------------------------
#-----------------------------------------------------------------
# This is a simple empidemiological model, simulating the spread of a virus 
# across a network. Thereby it creates and simulates four different compartents
# susceptible (non infected), Infected, Recovered (Immune), Dead across n number of nodes
# The output of the model is a data.frame with the relative number of people within each of the
#compartments during t-time steps. 
# @input: g = recovery rate
# @ input beta_base: 
#...TBD
# hospitalisation rate approximated from https://www.ecdc.europa.eu/en/current-risk-assessment-novel-coronavirus-situation 

actlikeme = function(n=1000,g=0.1,h=0.032,dr = 0.005,
                     beds=100,hout=0.05,beta_base=0.7,
                     personalcontacts=5,washing_hands=5,
                     offset=2,days=100,pub_transport=0,
                     node_interaction=4, local_connections_only=FALSE,mask=0,social_distancing=2){ 
  #Fixed parameter
  #------------------------------------
  #g equals recovery time. Set to 0.1 results in an expected value of 10 days to recover, which is 
  #also consistent with the approx. time a covid19 patient being infectious 
  g = g
  
  #  #proportion of sick patients going into hospital (per day!!)

  h = h
  
  #probability of getting out of hospital
  hout=hout

  #probabbility of dying
  dr=dr
  #number of notes 
  n <- n

  beta_private = 0.9 #baseline - given you have PERSONAL contact with a infected person, 
  # how probable is it that you get infected
  
  beta_public = 0.05 #given that you are in the public, like e.g. in a park 
  
  
  beta_transport = 0.4 #using public transportatioin 
  #pub_transport verzicht auf PT
  if (pub_transport ==1) {
    trans_beta = beta_transport
  } else {
    trans_beta = 0
  }
  
  #wearing a mask
  if (mask ==1) {
    mask_beta = 0.25
  } else {
    mask_beta = 0
  }
  
#ToDo: -> fix transporation because it is always inf
  
  public_contacts = 20 #amount of people you cross during a normal day in the par, food shooping
  
  node_members = public_contacts + personalcontacts
  
  beta_base = min(1,beta_private * (personalcontacts/(personalcontacts+public_contacts)) + 
                    beta_public *(public_contacts/(personalcontacts+public_contacts)) + trans_beta)
  
  #Adjustable parameter by user
  #------------------------------------
  #number of healthy people in the node => how big is you circle of people 
  # you met in persone during the last 7 days (business or private)
  
  offset = 2 #reducing impact/10 of wahsing hands
  hygiene = max(washing_hands/70,0) + mask_beta
  social_distancing_ = social_distancing/30
  beta = min(1,max(0, beta_base - hygiene-social_distancing_)) #keep beta between 0 and 1
  
  i = 1#round(max(1, node_members/5)) #infected within node
  s = node_members - i
  
  #hygiene proxies attempts of user to take care not getting infected while in contact with others
  #1-10 , e.g. amount of times user washes hands per day
  
  
  #beta equals prob that a single agent is getting infected at a specific time point. 
  
  
  transitions <- c("S -> beta*S*I/(S+I+R+D) -> I + Icum", "I -> g*I -> R", "I -> h*I -> H","H -> hout*H ->R","H -> H*dr -> D")
  compartments <- c("S", "I", "Icum", "R", "D", "H","H_out")
  
  #Setting up events for internal and external transfer
  #-------------------------------------
  
  #defining time span in days
  tspan <- seq(from = 1, to = days, by = 1)
  
  #Defining events for external transition
  
  extrans_events <- data.frame(event = "extTrans", time = rep(tspan,
                                                              each = node_members),
                               node = sample(1:n,length(tspan)*node_members,
                                             replace=TRUE),
                               dest = sample(1:n,length(tspan)*node_members,replace=TRUE),
                               n = 1, proportion = 0,
                               select =1, shift = 0)
  
  # If local conntections is true, only make connections to the 
  # numerically closest nodes
  if (local_connections_only == TRUE) {
    # only connect to closes nodenumbers (not really clustering but better than nothing)
    set.seed(42)
    dir_sample = sample(c(-1,1), length(tspan)*node_members, replace = T)
    change_sample = sample(1:as.integer(node_interaction/2), length(tspan)*node_members, replace = T)
    
    # Create node-difference
    nodes_sample = dir_sample * change_sample
    t = extrans_events$node + nodes_sample
    t_1 <- ifelse(t <= 0, max(extrans_events$node) + t, t)
    t_2 <- ifelse( t_1 > max(extrans_events$node), t_1 - max(extrans_events$node), t_1)
    extrans_events$dest = t_2
  }
  
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
