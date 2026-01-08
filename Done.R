setwd("E:/PhD_Thesis/Presentation 2023/Revise/Dataset Xerophyta/wanga/Phylogeny/Divergence time")
getwd()

install.packages("BMMtools")
install.packages("devtools", dependencies=TRUE)
install.packages("ape")        # Phylogenetic analysis
install.packages("phytools")  # Phylogenetic tools
install.packages("BAMMtools") # Diversification rate analysis
install.packages("ggtree")    # Visualization
library(ape)
library(phytools)
library(BAMMtools)
library(ggtree)

# Load the tree
tree <- read.tree("gggg.newick")

# Check the tree
plot(tree)




require(devtools)
install_github("macroevolution/bammtools/BAMMtools")
1

library(BAMMtools)

tree <- read.tree("view.TRE")

tree =((((Pandanus_amaryllifolius_NC_070105:3.69093062,(Benstonea_copelandii_NC_057311:2.06768520,Pandanus_tectorius_NC_042747:2.06768520)0.963:1.62324543)0.963:4.44977088,((Stemona_tuberosa_MW246829:3.48203133,(Stemona_japonica_NC_039675:1.62586357,Stemona_mairei_NC_039676:1.62586357)0.892:1.85616777)0.857:3.13791947,((Croomia_japonica_NC_039672:0.94824375,Croomia_heterosepala_NC_039673:0.94824375)0.972:1.27003745,Croomia_pauciflora_NC_039674:2.21828120)0.972:4.40166961)0.704:1.52075069)0.633:40.72540034,Carludovica_palmata_NC_026786:48.86610184)0.548:23.95043711,(Acanthochlamys_bracteata_MW727487:42.91859766,(((Barbacenia_involucrata:6.74044433,Vellozia_sp_:6.74044433)0.896:16.20171288,Barbaceniopsis_castillonii:22.94215721)0.59:3.97072195,((((Xerophyta_squarrosa__W042:1.50076653,Xerophyta_capillaris__W008:1.50076653)1:10.89964233,(((Xerophyta_spekei__W032:0.50639878,Xerophyta_spekei_MN663122:0.50639878)0.854:5.01709396,(((((Xerophyta_villosa__W062:0.77681261,Xerophyta_retinervis_MW580856:0.77681261)0.845:1.55376681,(((Xerophyta_equisetoides_var__setosa__W035:0.64152733,Xerophyta_equisetoides_var__trichophylla__W055:0.64152733)0.353:0.33444423,(Xerophyta_trichophylla__W054:0.27932698,(Xerophyta_wetzeliana__W053:0.03952844,Xerophyta_suaveolens__W064:0.03952844)0.972:0.23979853)0.931:0.69664459)0.758:0.67033658,Xerophyta_equisetoides_var__trichophylla__W056:1.64630814)0.599:0.68427128)0.23:0.49715387,Xerophyta_argentea__W040:2.82773329)0.202:0.91830607,((Xerophyta_viscosa__W030:1.35877457,(Xerophyta_splendens__W051:0.12958917,Xerophyta_kirkii__W007:0.12958917)0.95:1.22918540)0.761:1.79926652,Xerophyta_retinervis__W014:3.15804106)0.23:0.58799827)0.604:0.87346435,(Xerophyta_scabrida__W028:1.94738212,Xerophyta_scabrida__W026:1.94738212)0.742:2.67212159)0.883:0.90398902)0.661:0.72180249,Xerophyta_retinervis__W017:6.24529522)0.858:6.15511365)0.858:6.46842435,((Xerophyta_rippsteinii__W002:0.58868452,(Xerophyta_schnizleinia__W031:0.27744279,Xerophyta_schnizleinia__W037:0.27744279)0.408:0.31124173)0.943:13.05193531,(Xerophyta_simulans__W046:7.37493439,Xerophyta_simulans__W061:7.37493439)0.959:6.26568544)0.943:5.22821338)0.858:5.70339483,(((Xerophyta_viscosa__W043:10.00418791,((Xerophyta_viscosa_BK018544:0.06806539,Xerophyta_schlechteri_NC_043880:0.06806539)0.997:1.47042575,(Xerophyta_acuminata__W013:0.78510406,Xerophyta_arabica__W038:0.78510406)0.939:0.75338708)0.997:8.46569676)0.63:7.36703211,(Xerophyta_elegans__W047:1.25741965,Xerophyta_elegans__W001:1.25741965)0.998:16.11380037)0.858:3.15633255,(((Xerophyta_cf__pectinata__SAJIT_11013:3.85117491,Xerophyta_dasylirioides_SAJIT_1101:3.85117491)0.999:7.60262415,(Xerophyta_dasylirioides__W050:8.29905039,((((Xerophyta_sp___SAJIT_11021_1:0.27029602,Xerophyta_sessiliflora__SAJIT_11110_1:0.27029602)0.979:1.15591014,Xerophyta_sessiliflora__SAJIT_11012:1.42620616)0.979:1.15762090,(Xerophyta_pinifolia__SAJIT_11037_1:1.28163807,Xerophyta_pinifolia__W049:1.28163807)0.998:1.30218899)0.979:2.49687297,Xerophyta_eglandulosa__SAJIT_11017:5.08070002)0.979:3.21835036)0.96:3.15474867)0.96:5.30325286,(Xerophyta_humilis__W024:2.12267018,(Xerophyta_humilis__W023:0.27961750,Xerophyta_humilis__W044:0.27961750)0.988:1.84305267)0.988:14.63438173)0.96:3.77050065)0.858:4.04467549)0.812:2.34065111)0.74:16.00571850)0.74:29.89794129)1:49.28222326;)))k

