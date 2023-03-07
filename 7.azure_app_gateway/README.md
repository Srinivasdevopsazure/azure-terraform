# Need dedicated subnet

<!--
Application gateway is - later 7 LBn or controller

1. provide ssl termination and offloading
2. supports http-https redirection
3. path or url based routing
4. supports WAS integration
5. can use as ingress controller for azure kubernetes services -->

<!--
2 servers--homepage
1 movies
1 songs -->

1. application gateway
2. create dns record set
3. backend pools
4. health probes
5. backend settings
6. listeners
7. routing rules
8. assign certificates to listeners
   i.load certificates or
   ii.get certificate from key vault -> need autherization to access certificates from vault
   for this we need managed identities to give permissions
9. need to redirect http traffic to https --> need to add listeners - redirect

---

Lab:
2vm's

1. homepage
2. movies

subnet 
agw -> basics -> frontends -> backend pool( assign backedn targets) -> configuration( add rules -> listeners and backend targets)

